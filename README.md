🌌 UNIVERSAL SELFHOSTED STACK
Nextcloud • Paperless-ngx • Traefik v3 • n8n • OnlyOffice • Zero-Knowledge Backups • SFTP-Scanner
<div align="center"> <img src="https://img.shields.io/badge/Status-Stable-00e5ff?style=for-the-badge&logo=hackthebox&logoColor=00e5ff" /> <img src="https://img.shields.io/badge/Docker-Ready-0aff9d?style=for-the-badge&logo=docker&logoColor=0aff9d" /> <img src="https://img.shields.io/badge/Traefik-v3-00e5ff?style=for-the-badge&logo=traefikproxy&logoColor=00e5ff" /> <img src="https://img.shields.io/badge/N8N-Automation-0aff9d?style=for-the-badge&logo=n8n&logoColor=0aff9d" /> <img src="https://img.shields.io/badge/Backups-Encrypted-00e5ff?style=for-the-badge&logo=protonvpn&logoColor=00e5ff" /> </div>

# 🌌 Universal Selfhosted Stack
### Nextcloud • Paperless-ngx • Traefik v3 • n8n • OnlyOffice • Zero-Knowledge Backups • SFTP-Scanner

---

<div align="center">
  <img src="https://img.shields.io/badge/Status-Stable-00e5ff?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Docker-Ready-0aff9d?style=for-the-badge&logo=docker&logoColor=0aff9d" />
  <img src="https://img.shields.io/badge/Traefik-v3-00e5ff?style=for-the-badge&logo=traefikproxy&logoColor=00e5ff" />
  <img src="https://img.shields.io/badge/Backups-Encrypted-0aff9d?style=for-the-badge&logo=protonvpn&logoColor=0aff9d" />
</div>

---

## 🧬 Überblick
Ein kompletter Dark-Mode Homelab-Stack: Reverse Proxy, SSL, Cloud, Dokumentenmanagement, Office, Workflows, OCR, PDF-Engine, Backups, Zero-Knowledge Encryption – alles automatisch.  
Ein Kommando. Kein manuelles Editing.

---

## 🔥 Features
### Core Services
- Traefik v3 (TLS, Routing, Dashboard, ACME)
- Nextcloud 31
- Paperless-ngx (mit Redis + Tika + Gotenberg)
- OnlyOffice
- n8n Automations
- SFTP-Scanner Upload
- Zero-Knowledge Backups (rclone crypt)

---

## ⚡ Installation
```bash
wget https://raw.githubusercontent.com/m0usm/UNIVERSAL-SELFHOSTED-STACK/main/setup.sh -O setup.sh
chmod +x setup.sh
sudo ./setup.sh
```

---

## 📝 Setup-Assistent
Das Script fragt automatisch:
- Domain-Einstellungen
- TLS/Let’s Encrypt Mail
- PostgreSQL für Paperless
- Hetzner StorageBox Zugang
- Synology Backup optional
- Snapshot-Intervall
- Traefik BasicAuth

Alle Secrets werden generiert und gespeichert.

---

## 🔐 Login & Zugangsdaten
Nach Installation bekommst du automatisch:
- Traefik Dashboard Login
- Nextcloud Admin
- Paperless Admin Login
- n8n BasicAuth
- SFTP Scanner Zugang
- StorageBox Zugang
- Rclone Crypt Key
- Datenbankpasswörter

Gespeichert in:
```
/opt/stack/.env
```

---

## 📦 Backups (Zero-Knowledge)
- latest → vollständiger Stand
- archive/YYYY-MM-DD → Delta Backups
- snapshots/YYYY-MM-DD → Vollsnapshots

### Backup starten
```bash
./maintenance.sh backup
```

### Snapshots anzeigen
```bash
./maintenance.sh snapshots
```

### Wiederherstellen
```bash
./maintenance.sh restore YYYY-MM-DD
```

---

## 📁 Projektstruktur
```
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
```

---

## 🛡️ Security
- Traefik Dashboard via bcrypt geschützt
- Backups vollständig verschlüsselt (rclone crypt)
- .env automatisch chmod 600
- acme.json automatisch chmod 600
- Keine Services ohne Reverse Proxy erreichbar

---

## 🧰 maintenance.sh
Kommando-Werkzeug:
```
./maintenance.sh backup
./maintenance.sh snapshots
./maintenance.sh restore YYYY-MM-DD
./maintenance.sh start
./maintenance.sh stop
```

---

## 👤 Author
**m0usm** – Homelab • DevOps • Selfhosting
