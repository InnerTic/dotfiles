#!/usr/bin/env bash
# bootstrap-watchtower-stack.sh — Installs AI Watchtower stack inside the LXC
# Run inside the container after bootstrap-watchtower-lxc.sh from Proxmox host.
set -euo pipefail

echo "[+] Updating system"
apt update && apt upgrade -y

echo "[+] Installing base packages"
apt install -y \
  git curl wget rsync ca-certificates unzip build-essential \
  python3 python3-pip python3-venv python3-dev \
  sqlite3 \
  jq tree htop

echo "[+] Creating directory layout"
mkdir -p /opt/ai-watchtower/{app/{collectors,parsers,analyzers,reports,prompts,exporters},config,data/{raw/{reuters,trendforce,tomshardware,filings,reddit,youtube},processed,exports,prices,sqlite},logs,scripts,services}

echo "[+] Creating Python virtual environment"
python3 -m venv /opt/ai-watchtower/.venv
source /opt/ai-watchtower/.venv/bin/activate
pip install --upgrade pip

# Core dependencies — add as needed
# pip install requests beautifulsoup4 feedparser pyyaml

echo "[+] Initializing SQLite database"
sqlite3 /opt/ai-watchtower/data/sqlite/watchtower.db <<'SQL'
CREATE TABLE IF NOT EXISTS sources (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    url TEXT,
    priority INTEGER DEFAULT 0,
    enabled INTEGER DEFAULT 1,
    created_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS articles (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_id INTEGER REFERENCES sources(id),
    title TEXT NOT NULL,
    url TEXT,
    published_at TEXT,
    captured_at TEXT DEFAULT (datetime('now')),
    raw_text_path TEXT,
    summary TEXT,
    evidence_level INTEGER,
    topic TEXT,
    tags TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS claims (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    article_id INTEGER REFERENCES articles(id),
    claim_text TEXT NOT NULL,
    claim_type TEXT,
    company TEXT,
    product TEXT,
    region TEXT,
    direction TEXT,
    confidence TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS topics (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    description TEXT
);

CREATE TABLE IF NOT EXISTS price_snapshots (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    captured_at TEXT DEFAULT (datetime('now')),
    component_type TEXT NOT NULL,
    component_name TEXT NOT NULL,
    price REAL,
    currency TEXT DEFAULT 'USD',
    source TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS watch_events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    event_at TEXT DEFAULT (datetime('now')),
    event_type TEXT NOT NULL,
    description TEXT NOT NULL,
    severity TEXT DEFAULT 'info',
    article_id INTEGER REFERENCES articles(id)
);

CREATE TABLE IF NOT EXISTS weekly_reports (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    week_start TEXT NOT NULL,
    week_end TEXT,
    generated_at TEXT DEFAULT (datetime('now')),
    report_path TEXT,
    summary TEXT
);
SQL

echo "[+] Setting permissions"
chown -R root:root /opt/ai-watchtower
chmod -R 755 /opt/ai-watchtower

echo "[+] Creating systemd service directory"
mkdir -p /etc/systemd/system/

echo "[+] Creating collector timer (placeholder)"
cat > /etc/systemd/system/watchtower-collector.service <<'UNIT'
[Unit]
Description=AI Watchtower — source collector
After=network-online.target

[Service]
Type=oneshot
ExecStart=/opt/ai-watchtower/.venv/bin/python /opt/ai-watchtower/app/collectors/run-all.py
WorkingDirectory=/opt/ai-watchtower
User=root
UNIT

cat > /etc/systemd/system/watchtower-collector.timer <<'UNIT'
[Unit]
Description=AI Watchtower — daily collection
Requires=watchtower-collector.service

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
UNIT

echo "[+] Done."
echo ""
echo "  Layout:  /opt/ai-watchtower/"
echo "  DB:      /opt/ai-watchtower/data/sqlite/watchtower.db"
echo "  Venv:    /opt/ai-watchtower/.venv"
echo ""
echo "Next: create collector scripts in /opt/ai-watchtower/app/collectors/"
echo "Enable timers:  systemctl enable --now watchtower-collector.timer"
echo "Manual run:     systemctl start watchtower-collector.service"
