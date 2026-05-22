#!/bin/bash
# ============================================================
#  Ibiza Mi Vida — Server Setup Script
#  Run once on a fresh Ubuntu 22.04 / 24.04 VPS
#  Usage: bash server-setup.sh
# ============================================================

set -euo pipefail

echo ""
echo "╔══════════════════════════════════════╗"
echo "║   Ibiza Mi Vida — Server Setup       ║"
echo "╚══════════════════════════════════════╝"
echo ""

# ── 1. Update system ─────────────────────────────────────
echo "📦 Updating system packages..."
apt-get update -qq && apt-get upgrade -y -qq

# ── 2. Install Docker ────────────────────────────────────
echo "🐳 Installing Docker..."
if ! command -v docker &>/dev/null; then
  curl -fsSL https://get.docker.com | sh
  usermod -aG docker "$USER"
  echo "✅ Docker installed"
else
  echo "✅ Docker already installed: $(docker --version)"
fi

# ── 3. Install Docker Compose plugin ────────────────────
echo "🔧 Installing Docker Compose..."
if ! docker compose version &>/dev/null; then
  apt-get install -y docker-compose-plugin
fi
echo "✅ $(docker compose version)"

# ── 4. Create app directory ──────────────────────────────
echo "📁 Creating /opt/ibiza-cms..."
mkdir -p /opt/ibiza-cms
cd /opt/ibiza-cms

# ── 5. Create .env from template ─────────────────────────
if [ ! -f .env ]; then
  echo ""
  echo "⚠️  No .env file found."
  echo "   Copy .env.template to /opt/ibiza-cms/.env and fill in your values."
  echo "   Then run: docker compose --profile prod up -d"
  echo ""
fi

# ── 6. Configure UFW firewall ────────────────────────────
echo "🔒 Configuring firewall..."
if command -v ufw &>/dev/null; then
  ufw allow 22/tcp   comment "SSH"
  ufw allow 80/tcp   comment "HTTP"
  ufw allow 443/tcp  comment "HTTPS"
  ufw --force enable
  echo "✅ Firewall configured"
fi

# ── 7. Install certbot for SSL ───────────────────────────
echo "🔐 Installing Certbot (Let's Encrypt)..."
if ! command -v certbot &>/dev/null; then
  apt-get install -y certbot
fi
echo "✅ Certbot ready"
echo "   After DNS is pointed, run:"
echo "   certbot certonly --standalone -d cms.ibizamivida.com"

# ── 8. Create systemd service for auto-restart ───────────
echo "⚙️  Creating systemd service..."
cat > /etc/systemd/system/ibiza-cms.service << 'EOF'
[Unit]
Description=Ibiza Mi Vida CMS
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/ibiza-cms
ExecStart=/usr/bin/docker compose --profile prod up -d
ExecStop=/usr/bin/docker compose --profile prod down
TimeoutStartSec=60

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable ibiza-cms.service
echo "✅ Systemd service created (ibiza-cms)"

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║   ✅ Server setup complete!                      ║"
echo "╠══════════════════════════════════════════════════╣"
echo "║  Next steps:                                     ║"
echo "║  1. Copy your files to /opt/ibiza-cms/           ║"
echo "║     scp docker-compose.yml nginx.conf .env ...   ║"
echo "║  2. Fill in /opt/ibiza-cms/.env                  ║"
echo "║  3. Start: docker compose --profile prod up -d   ║"
echo "║  4. Add GitHub Secrets (see README.md)           ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""
