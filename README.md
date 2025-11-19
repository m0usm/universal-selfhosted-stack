🌌 UNIVERSAL SELFHOSTED STACK
Nextcloud • Paperless-ngx • Traefik v3 • n8n • OnlyOffice • Zero-Knowledge Backups • SFTP-Scanner
<div align="center"> <img src="https://img.shields.io/badge/Status-Stable-00e5ff?style=for-the-badge&logo=hackthebox&logoColor=00e5ff" /> <img src="https://img.shields.io/badge/Docker-Ready-0aff9d?style=for-the-badge&logo=docker&logoColor=0aff9d" /> <img src="https://img.shields.io/badge/Traefik-v3-00e5ff?style=for-the-badge&logo=traefikproxy&logoColor=00e5ff" /> <img src="https://img.shields.io/badge/N8N-Automation-0aff9d?style=for-the-badge&logo=n8n&logoColor=0aff9d" /> <img src="https://img.shields.io/badge/Backups-Encrypted-00e5ff?style=for-the-badge&logo=protonvpn&logoColor=00e5ff" /> </div>
🧬 Überblick

Ein kompletter Dark-Mode Homelab-Stack, der sich in 1 Command selbst installiert:
Reverse Proxy, SSL, Cloud, Dokumentenmanagement, Office, Workflows, OCR, PDF-Engine, Backups, Zero-Knowledge Encryption — alles automatisch.

Keine manuelle Konfiguration. Keine YAML-Hölle. Keine Passworteingaben.

🔥 Features
🧩 Core Services
Service	Beschreibung
Traefik v3	TLS, Routing, Dashboard (bcrypt geschützt)
Nextcloud 31	Private Cloud, Files, Kalender
Paperless-ngx	Dokumentenmanagement + OCR
OnlyOffice	Online Office Suite
n8n	Automationen & Workflows
Redis	Cache für NC + Paperless
Tika / Gotenberg	OCR + PDF Rendering
SFTP-Scanner	Scanner-Upload → Paperless „consume“
🔷 Neon-DevOps Architecture (Diagramm)

(Dark Mode • Cyan • Homelab Style)

                     ┌───────────────────────────┐
                     │      🔐 Traefik v3        │
                     │  TLS • Routing • ACME     │
                     └─────────────┬─────────────┘
                                   │
         ┌─────────────────────────┼─────────────────────────┐
         │                         │                         │
┌────────▼────────┐     ┌──────────▼──────────┐    ┌────────▼────────┐
│   Nextcloud     │     │     Paperless       │    │      n8n         │
│  + MariaDB      │     │+ Redis + Tika/Gotenb│    │ Workflows / API  │
└────────┬────────┘     └──────────┬──────────┘    └────────┬────────┘
         │                          │                       │
         │                    ┌─────▼───────┐               │
         │                    │  SFTP Upload │               │
         │                    └──────────────┘               │
         │                          │                       │
         └──────────────────────────┴────────────────────────┘

                🔒 Backups (Zero-Knowledge, rclone crypt)
              latest • archive/Δ • snapshots/YYYY-MM-DD

⚡ Installation (1 Command)
wget https://raw.githubusercontent.com/m0usm/UNIVERSAL-SELFHOSTED-STACK/main/setup.sh -O setup.sh
chmod +x setup.sh
sudo ./setup.sh

📝 Setup-Assistent (automatisch)

Das Script fragt:

Basis-Installationspfad

Domains

Let’s Encrypt Mail

PostgreSQL für Paperless

StorageBox Zugang

Optional: Synology Backup

Snapshot-Intervalle

Traefik BasicAuth

Alles wird automatisch generiert → keine manuellen Änderungen.

🔐 Generierte Zugangsdaten

Am Ende zeigt das Script alle Logins übersichtlich in Cyan/Green:

🔹 Traefik Dashboard (User + Passwort)
🔹 Nextcloud Admin
🔹 Paperless Admin
🔹 n8n BasicAuth
🔹 SFTP Scanner
🔹 StorageBox Zugang
🔹 Rclone Crypt Key
🔹 DB-Passwörter

Gespeichert in:

/opt/stack/.env


(automatisch chmod 600)

📦 Backup Engine (Encrypted)

Zero-Knowledge Encryption (rclone crypt)

/latest → vollständiger Stand

/archive/YYYY-MM-DD → Deltas

/snapshots/YYYY-MM-DD → Voll-Snapshots

Optional: zweites Ziel → Synology

Backup starten:
./maintenance.sh backup

Snapshots anzeigen:
./maintenance.sh snapshots

Restore:
./maintenance.sh restore YYYY-MM-DD

🛠️ Projektstruktur
/opt/stack/
├── docker-compose.yml
├── .env
├── maintenance.sh
├── setup.sh
├── data/
│   ├── nextcloud/
│   ├── paperless/
│   ├── traefik/
│   ├── n8n/
│   └── sftp/
└── backup/
    ├── Dockerfile
    ├── entrypoint.sh
    └── .dockerignore

🛡️ Security

Traefik Dashboard geschützt durch bcrypt BasicAuth

StorageBox Backups vollständig verschlüsselt

.env → automatisch 600 gesetzt

acme.json → automatisch 600

Kein Service ist ohne Traefik öffentlich erreichbar

🧰 maintenance.sh

Ein Kommando-Tool:

./maintenance.sh backup
./maintenance.sh snapshots
./maintenance.sh restore YYYY-MM-DD
./maintenance.sh start
./maintenance.sh stop

❤️ Author

m0usm
Selfhosted. DevOps. Hacker-Style.
Für Homelabs & professionelle Setups.
