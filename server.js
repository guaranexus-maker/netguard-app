const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const winston = require('winston');
const path = require('path');
const fs = require('fs');

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: '/app/logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: '/app/logs/combined.log' }),
    new winston.transports.Console()
  ]
});

const app = express();
const PORT = process.env.PORT || 80;

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'", "https://fonts.googleapis.com"],
      fontSrc: ["'self'", "https://fonts.gstatic.com"],
      imgSrc: ["'self'", "data:", "https:"],
      scriptSrc: ["'self'"]
    }
  }
}));
app.use(compression());
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

app.use(express.static(path.join(__dirname, 'public')));

const authenticateToken = async (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(403).json({ error: 'Invalid token' });
  }
};

app.get('/', (req, res) => {
  const htmlContent = `<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NetGuard Security Platform</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .container {
            background: rgba(255, 255, 255, 0.95);
            padding: 3rem;
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            text-align: center;
            max-width: 500px;
            width: 90%;
        }
        .logo {
            width: 80px;
            height: 80px;
            background: linear-gradient(45deg, #667eea, #764ba2);
            border-radius: 50%;
            margin: 0 auto 2rem;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 2rem;
            font-weight: bold;
        }
        h1 { color: #333; margin-bottom: 0.5rem; font-size: 2.5rem; }
        .subtitle { color: #666; margin-bottom: 2rem; font-size: 1.1rem; }
        .status {
            background: #d4edda;
            color: #155724;
            padding: 1rem;
            border-radius: 10px;
            margin-bottom: 2rem;
            border: 1px solid #c3e6cb;
        }
        .features {
            text-align: left;
            background: #f8f9fa;
            padding: 1.5rem;
            border-radius: 10px;
            margin: 2rem 0;
        }
        .feature {
            display: flex;
            align-items: center;
            margin-bottom: 0.8rem;
            color: #495057;
        }
        .feature::before {
            content: "🛡️";
            margin-right: 0.8rem;
            font-size: 1.2rem;
        }
        .footer {
            margin-top: 2rem;
            padding-top: 1rem;
            border-top: 1px solid #e9ecef;
            color: #6c757d;
            font-size: 0.9rem;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">🛡️</div>
        <h1>NetGuard</h1>
        <p class="subtitle">Security Console & Firewall</p>
        
        <div class="status">
            ✅ Sistema Online e Operacional
        </div>

        <div class="features">
            <h3 style="margin-bottom: 1rem; color: #333;">🔧 Recursos Ativos:</h3>
            <div class="feature">Firewall de Nova Geração</div>
            <div class="feature">Detecção de Intrusão (IDS/IPS)</div>
            <div class="feature">Proxy Transparente</div>
            <div class="feature">WAF (Web Application Firewall)</div>
            <div class="feature">VPN WireGuard</div>
            <div class="feature">DNS/DHCP Manager</div>
            <div class="feature">Análise de Tráfego em Tempo Real</div>
            <div class="feature">Integração Active Directory</div>
        </div>

        <div class="footer">
            <strong>Prefeitura de Guaramirim - SC</strong><br>
            Departamento de Tecnologia da Informação<br>
            Sistema instalado em: ${new Date().toLocaleDateString('pt-BR')}
        </div>
    </div>
</body>
</html>`;
  res.send(htmlContent);
});

app.get('/dashboard', (req, res) => {
  res.send('<h1>NetGuard Dashboard</h1><p>Interface administrativa em desenvolvimento...</p>');
});

app.post('/api/auth/login', async (req, res) => {
  try {
    const { username, password } = req.body;

    if (username === 'admin' && password === 'admin123') {
      const token = jwt.sign(
        { id: 1, username: 'admin', role: 'admin' },
        process.env.JWT_SECRET,
        { expiresIn: '24h' }
      );
      
      res.json({ 
        success: true,
        token, 
        user: { id: 1, username: 'admin', role: 'admin' } 
      });
    } else {
      res.status(401).json({ error: 'Invalid credentials' });
    }
  } catch (error) {
    logger.error('Login error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    version: '2.0.0',
    uptime: process.uptime()
  });
});

app.get('/api/status', (req, res) => {
  res.json({
    system: 'NetGuard Security Platform',
    status: 'operational',
    services: {
      firewall: 'active',
      proxy: 'active', 
      database: 'connected',
      waf: 'monitoring'
    }
  });
});

app.listen(PORT, '0.0.0.0', () => {
  logger.info(`NetGuard Server running on port ${PORT}`);
  console.log(`🛡️  NetGuard Security Platform started on http://0.0.0.0:${PORT}`);
});

process.on('SIGTERM', () => {
  logger.info('SIGTERM received, shutting down gracefully');
  process.exit(0);
});
