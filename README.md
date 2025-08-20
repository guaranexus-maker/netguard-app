# 🛡️ NetGuard Security Platform

Sistema de segurança e firewall de código aberto, desenvolvido para a Prefeitura de Guaramirim - SC.

## 🚀 Funcionalidades Principais

- **Firewall de Nova Geração**: Controle avançado de tráfego de rede.
- **Proxy Transparente**: Filtragem de conteúdo web com Squid.
- **WAF (Web Application Firewall)**: Proteção para aplicações web.
- **IDS/IPS**: Detecção e prevenção de intrusões.
- **VPN WireGuard**: Acesso remoto seguro e rápido.
- **Gerenciador de DNS/DHCP**: Controle total sobre a rede local.
- **Integração com Active Directory**: Autenticação centralizada.
- **Análise de Tráfego em Tempo Real**: Monitoramento e dashboards.

## 📋 Requisitos de Sistema

- **Hardware**: Servidor com no mínimo 2 interfaces de rede (WAN e LAN), 4GB de RAM e 50GB de disco.
- **Software**: Docker e Docker Compose instalados em um sistema Linux (Debian, Ubuntu, Fedora, etc.).

## 🔧 Guia de Instalação Rápida

1.  **Clone o repositório:**
    ```bash
    git clone https://github.com/SEU_USUARIO/netguard-app.git
    cd netguard-app
    ```

2.  **Configure o ambiente:**
    Crie um arquivo `.env` a partir do exemplo e ajuste as variáveis conforme sua necessidade.
    ```bash
    cp .env.example .env
    nano .env
    ```

3.  **Inicie os serviços com Docker Compose:**
    ```bash
    sudo docker-compose up -d
    ```

4.  **Acompanhe os logs para verificar a inicialização:**
    ```bash
    sudo docker-compose logs -f
    ```

5.  **Acesse a interface de gerenciamento:**
    Abra o navegador e acesse o endereço IP do seu servidor: `http://<IP_DO_SEU_SERVIDOR>`

## 🔐 Primeiro Acesso

-   **Usuário padrão:** `admin`
-   **Senha padrão:** `admin123`

⚠️ **IMPORTANTE:** É crucial alterar a senha do administrador no primeiro login por questões de segurança.

## 📊 Monitoramento e Status

O sistema expõe endpoints para monitoramento da saúde dos serviços:

-   `/health` - Status geral da aplicação.
-   `/api/status` - Status detalhado dos serviços integrados (Firewall, Proxy, etc.).

## 🔄 Atualizações

Para atualizar o sistema para a versão mais recente:

```bash
cd netguard-app
git pull
sudo docker-compose pull
sudo docker-compose up -d
🆘 Suporte e Contato
Para suporte técnico, sugestões ou relatar problemas, entre em contato com o Departamento de T.I. da Prefeitura de Guaramirim.

Email: ti@guaramirim.sc.gov.br
Responsável: Geverson dal Pra
Versão Atual: 2.0.0
