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
wget https://raw.githubusercontent.com/m0usm/universal-selfhosted-stack/main/setup.sh -O setup.sh
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

# 🚀 Universal Selfhosted Stack  
### Nextcloud • Paperless-ngx • Traefik v3 • n8n • OnlyOffice • Zero-Knowledge Backups • SFTP Scanner

Ein vollautomatischer Dark-Mode Homelab-Stack: Reverse Proxy, SSL, Cloud, Dokumentenmanagement, Office-Suite, Workflows, OCR-Engine, PDF-Engine, Backups, Zero-Knowledge Encryption.  
Komplett installiert mit **einem einzigen Befehl**. Keine manuelle Konfiguration nötig.

---

## 🧩 Features

### **Core Services**
- **Traefik v3** – HTTPS, Routing, Dashboard, ACME
- **Nextcloud 31** – Cloud, Files, Kalender, Kontakte
- **Paperless-ngx** – Dokumentenverwaltung (mit Redis, Tika, Gotenberg)
- **OnlyOffice DocumentServer** – Online Office Suite
- **n8n Automations** – Workflows, Automatisierung
- **SFTP Scanner** – Dateien direkt in Paperless importieren
- **Zero-Knowledge Backups** – Verschlüsselt via rclone crypt

### **Built-In Extras**
- Automatische Let's Encrypt Zertifikate  
- Healthchecks für alle Container  
- Vollautomatische Backups (daily/weekly)  
- Encrypted Snapshots + Delta-Backups  
- Vollständiges Restore-System  
- Firewall-freundlich  
- Keine manuelle Bearbeitung von Config-Dateien  
- Alle Passwörter werden automatisch generiert

---

## ⚡ Installation (3 Befehle)

```bash


![Universal Selfhosted Stack Banner](images/universal-selfhosted-stack-banner.png)

# Universal Selfhosted Stack

Vollautomatischer Docker-Stack für Nextcloud, Paperless-ngx, Traefik v3, n8n, OnlyOffice, verschlüsselte Backups und SFTP-Scanner – alles mit einem einzigen Setup-Skript.

Fully automated Docker stack for Nextcloud, Paperless-ngx, Traefik v3, n8n, OnlyOffice, encrypted backups and an SFTP scanner – all from a single setup script.

---

# Deutsch

## Funktionen

- Ein-Kommando-Setup für kompletten Selfhosted-Stack
- Traefik v3 als Reverse Proxy mit HTTPS und Dashboard
- Nextcloud 31 als zentrale Cloud-Plattform
- Paperless-ngx mit Redis, Tika und Gotenberg für OCR & PDF-Verarbeitung
- OnlyOffice DocumentServer für Online-Office
- n8n für Automatisierungen und Workflows
- SFTP-Scanner für direkten Dokumenten-Upload nach Paperless
- Vollautomatische Backups (latest + Delta-Archive + Snapshots)
- Zero-Knowledge Backups via rclone crypt (Hetzner Storage Box)
- Optional: zweites Backup-Ziel auf Synology per SFTP

## Services

- **Traefik v3** – Routing, HTTPS, Let’s Encrypt, Dashboard (BasicAuth)
- **Nextcloud 31** – Files, Kalender, Kontakte
- **Paperless-ngx** – Dokumentenmanagement mit OCR, Tika und Gotenberg
- **OnlyOffice** – Webbasierte Office-Suite
- **n8n** – Workflow-Automation im Browser
- **SFTP-Scanner** – Upload-Verzeichnis direkt an Paperless-Consume
- **Backup-Container** – Dumps + rclone-Sync + Snapshots (StorageBox + optional Synology)

## Voraussetzungen

- Linux-Server (Debian/Ubuntu oder kompatibel)
- root oder sudo-Zugriff
- Docker + Docker Compose (wird bei Bedarf automatisch installiert)
- Eine Domain (z. B. `example.com`) mit DNS-Einträgen für:
  - `traefik.example.com`
  - `cloud.example.com`
  - `paperless.example.com`
  - `n8n.example.com`
  - `office.example.com`
- Hetzner Storage Box (für verschlüsselte Backups, SFTP/SSH aktiviert)
- Optional: Synology mit SFTP/SSH für zweites Backup-Ziel

## Installation

```bash
wget https://raw.githubusercontent.com/m0usm/universal-selfhosted-stack/main/setup.sh -O setup.sh
chmod +x setup.sh
sudo ./setup.sh

wget https://raw.githubusercontent.com/m0usm/universal-selfhosted-stack/main/setup.sh -O setup.sh
chmod +x setup.sh
sudo ./setup.sh

