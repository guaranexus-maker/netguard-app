-- NetGuard Security Platform Database Schema
-- Prefeitura de Guaramirim - SC

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);

-- Firewall rules table
CREATE TABLE firewall_rules (
    id SERIAL PRIMARY KEY,
    rule_name VARCHAR(100) NOT NULL,
    rule_type VARCHAR(20) NOT NULL, -- wan, lan, nat_inbound, nat_outbound
    action VARCHAR(10) NOT NULL, -- pass, block, reject
    interface_name VARCHAR(20),
    protocol VARCHAR(10) DEFAULT 'any',
    source_address VARCHAR(100),
    source_port VARCHAR(20),
    destination_address VARCHAR(100),
    destination_port VARCHAR(20),
    description TEXT,
    enabled BOOLEAN DEFAULT true,
    priority INTEGER DEFAULT 100,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER REFERENCES users(id)
);

-- Network interfaces table
CREATE TABLE network_interfaces (
    id SERIAL PRIMARY KEY,
    interface_name VARCHAR(20) NOT NULL,
    interface_type VARCHAR(20) DEFAULT 'physical',
    zone VARCHAR(10) DEFAULT 'LAN',
    ip_address INET,
    netmask VARCHAR(15),
    gateway INET,
    status VARCHAR(10) DEFAULT 'up',
    description TEXT,
    enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- DHCP configuration table
CREATE TABLE dhcp_config (
    id SERIAL PRIMARY KEY,
    interface_name VARCHAR(20) NOT NULL,
    enabled BOOLEAN DEFAULT true,
    range_start INET NOT NULL,
    range_end INET NOT NULL,
    subnet_mask VARCHAR(15) NOT NULL,
    gateway INET,
    dns_servers TEXT[],
    domain_name VARCHAR(100),
    lease_time INTEGER DEFAULT 3600,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- DNS records table
CREATE TABLE dns_records (
    id SERIAL PRIMARY KEY,
    domain VARCHAR(255) NOT NULL,
    record_type VARCHAR(10) NOT NULL,
    record_value VARCHAR(255) NOT NULL,
    ttl INTEGER DEFAULT 3600,
    priority INTEGER,
    enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- System logs table
CREATE TABLE system_logs (
    id SERIAL PRIMARY KEY,
    log_level VARCHAR(10) NOT NULL,
    service VARCHAR(50) NOT NULL,
    message TEXT NOT NULL,
    source_ip INET,
    details JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- VPN users table
CREATE TABLE vpn_users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) NOT NULL,
    public_key TEXT,
    private_key TEXT,
    assigned_ip INET,
    enabled BOOLEAN DEFAULT true,
    last_connection TIMESTAMP,
    data_sent BIGINT DEFAULT 0,
    data_received BIGINT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Proxy rules table
CREATE TABLE proxy_rules (
    id SERIAL PRIMARY KEY,
    source_domain VARCHAR(255) NOT NULL,
    destination_url VARCHAR(500) NOT NULL,
    rule_type VARCHAR(20) DEFAULT 'redirect',
    enabled BOOLEAN DEFAULT true,
    ssl_enabled BOOLEAN DEFAULT false,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- WAF rules table
CREATE TABLE waf_rules (
    id SERIAL PRIMARY KEY,
    rule_id VARCHAR(50) UNIQUE NOT NULL,
    description TEXT NOT NULL,
    severity VARCHAR(20) DEFAULT 'medium',
    pattern TEXT,
    action VARCHAR(20) DEFAULT 'block',
    enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Certificates table
CREATE TABLE certificates (
    id SERIAL PRIMARY KEY,
    cert_name VARCHAR(100) NOT NULL,
    domain VARCHAR(255) NOT NULL,
    issuer VARCHAR(100),
    valid_from DATE,
    valid_until DATE,
    cert_data TEXT,
    private_key TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- System metrics table
CREATE TABLE system_metrics (
    id SERIAL PRIMARY KEY,
    metric_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    cpu_usage DECIMAL(5,2),
    memory_usage DECIMAL(5,2),
    disk_usage DECIMAL(5,2),
    network_in BIGINT,
    network_out BIGINT,
    active_connections INTEGER
);

-- Insert default admin user
INSERT INTO users (username, email, password_hash, role) VALUES 
('admin', 'admin@guaramirim.sc.gov.br', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin');

-- Insert default network interfaces
INSERT INTO network_interfaces (interface_name, zone, ip_address, netmask, description) VALUES 
('eth0', 'LAN', '192.168.1.1', '255.255.255.0', 'Interface LAN principal'),
('eth1', 'WAN', '216.24.57.251', '255.255.255.0', 'Interface WAN');

-- Insert default firewall rules
INSERT INTO firewall_rules (rule_name, rule_type, action, interface_name, protocol, source_address, destination_address, description, created_by) VALUES 
('Allow LAN to Internet', 'lan', 'pass', 'LAN', 'any', '192.168.1.0/24', 'any', 'Permitir acesso da LAN para internet', 1),
('Block All WAN', 'wan', 'block', 'WAN', 'any', 'any', 'any', 'Bloquear todo tráfego WAN por padrão', 1);

-- Create indexes for performance
CREATE INDEX idx_firewall_rules_enabled ON firewall_rules(enabled);
CREATE INDEX idx_firewall_rules_type ON firewall_rules(rule_type);
CREATE INDEX idx_system_logs_timestamp ON system_logs(created_at);
CREATE INDEX idx_system_logs_service ON system_logs(service);
CREATE INDEX idx_dns_records_domain ON dns_records(domain);
CREATE INDEX idx_network_interfaces_zone ON network_interfaces(zone);

COMMENT ON DATABASE netguard_db IS 'NetGuard Security Platform Database - Prefeitura de Guaramirim';
