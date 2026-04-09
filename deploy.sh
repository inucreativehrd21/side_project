#!/bin/bash
set -e

REPO_URL="https://github.com/inucreativehrd21/side_project.git"
APP_DIR="/home/ubuntu/mysite"
SERVER_IP="3.38.128.130"

# System packages
sudo apt-get update -y
sudo apt-get install -y git python3 python3-pip python3-venv nginx curl

# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"

# Clone or pull
if [ -d "$APP_DIR/.git" ]; then
    cd "$APP_DIR"
    git pull
else
    git clone "$REPO_URL" "$APP_DIR"
    cd "$APP_DIR"
fi

cd "$APP_DIR"

# Install dependencies from lockfile
uv sync

# Prepare directories
mkdir -p "$APP_DIR/logs"
mkdir -p "$APP_DIR/staticfiles"

# Django setup
DJANGO_SETTINGS_MODULE=config.settings.prod uv run python manage.py migrate --noinput
DJANGO_SETTINGS_MODULE=config.settings.prod uv run python manage.py collectstatic --noinput

# Gunicorn systemd service
sudo tee /etc/systemd/system/gunicorn.service > /dev/null <<EOF
[Unit]
Description=gunicorn daemon for mysite
After=network.target

[Service]
User=ubuntu
Group=www-data
WorkingDirectory=$APP_DIR
ExecStart=$APP_DIR/.venv/bin/gunicorn \\
    --workers 3 \\
    --bind unix:$APP_DIR/gunicorn.sock \\
    config.wsgi:application
Environment="DJANGO_SETTINGS_MODULE=config.settings.prod"
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable gunicorn
sudo systemctl restart gunicorn

# Nginx config
sudo tee /etc/nginx/sites-available/mysite > /dev/null <<EOF
server {
    listen 80;
    server_name $SERVER_IP;

    location /static/ {
        alias $APP_DIR/staticfiles/;
    }

    location / {
        include proxy_params;
        proxy_pass http://unix:$APP_DIR/gunicorn.sock;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/mysite /etc/nginx/sites-enabled/mysite
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl enable nginx
sudo systemctl restart nginx

echo "Deployed at http://$SERVER_IP"
