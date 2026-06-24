#!/usr/bin/env bash
# bootstrap-quartz-stack.sh — Installs Quartz stack inside the LXC
set -euo pipefail

echo "[+] Updating system"
apt update && apt upgrade -y

echo "[+] Installing base packages"
apt install -y git curl wget rsync ca-certificates unzip build-essential nginx

echo "[+] Installing Node.js 22 LTS"
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt install -y nodejs
node -v
npm -v

echo "[+] Creating directory layout"
mkdir -p /srv/{vault,quartz,backups}

echo "[+] Cloning Quartz"
cd /srv
git clone https://github.com/jackyzha0/quartz.git quartz
cd quartz
npm install
mkdir -p /srv/quartz/content

echo "[+] Creating nginx config"
cat > /etc/nginx/sites-available/quartz << 'NGINX'
server {
    listen 80;
    server_name _;

    root /srv/quartz/public;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /status {
        alias /srv/quartz/public/status.json;
        default_type application/json;
        add_header Access-Control-Allow-Origin *;
    }
}
NGINX

rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/quartz /etc/nginx/sites-enabled/quartz
nginx -t && systemctl reload nginx

echo "[+] Creating update script"
cat > /srv/quartz/update-wiki.sh << 'EOF'
#!/usr/bin/env bash
# update-wiki.sh — pull vault, rebuild site, emit /status
set -euo pipefail

cd /srv/vault
git pull

rsync -av --delete /srv/vault/docs/ /srv/quartz/content/

cd /srv/quartz
npx quartz build
EOF

chmod +x /srv/quartz/update-wiki.sh

echo "[+] DONE"
echo "Next steps:"
echo "  1. Clone vault:  git clone <vault-repo> /srv/vault"
echo "  2. Run update:   /srv/quartz/update-wiki.sh"
echo "  3. Verify:       curl http://localhost/"
echo "                   curl http://localhost/status"
