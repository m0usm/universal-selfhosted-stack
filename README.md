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
wget https://raw.githubusercontent.com/m0usm/universal-selfhosted-stack/main/setup.sh -O setup.sh
chmod +x setup.sh
sudo ./setup.sh
Das Setup führt dich durch alle Fragen (Domains, Backups, StorageBox, Synology, usw.).

🔑 Wichtige Zugangsdaten (werden automatisch generiert)
Nach dem Setup werden dir alle Logins & Passwörter angezeigt:

Dienst	Zugang
Traefik Dashboard	Benutzer + Passwort (BasicAuth)
Nextcloud Admin	Benutzer: admin / Passwort generiert
Paperless-ngx Admin	Benutzer: admin / Passwort generiert
n8n BasicAuth	Benutzer + Passwort generiert
SFTP-Scanner	Benutzer: scanner / Passwort generiert
DB-Passwörter	MySQL / PostgreSQL / Redis – automatisch generiert
rclone crypt Key	Zero-Knowledge Verschlüsselung

Alles wird in deiner .env gespeichert (600-Berechtigungen).

🗂 Projektstruktur
bash
Code kopieren
/opt/stack/
│── docker-compose.yml
│── .env
│── maintenance.sh
│
├── data/
│   ├── traefik/
│   ├── nextcloud/
│   ├── paperless/
│   ├── n8n/
│   └── sftp/
│
├── backup/
│   ├── Dockerfile
│   ├── entrypoint.sh
│   └── .dockerignore
🔐 Sicherheitshinweise
Alle Backups sind zero-knowledge verschlüsselt (rclone crypt).

.env unbedingt schützen:

bash
Code kopieren
chmod 600 .env
Traefik Dashboard ist per bcrypt BasicAuth gesichert.

Nutzung hinter Firewall oder Fail2Ban empfohlen.

💾 Backup & Restore
Der Backup-Container erstellt automatisch:

✔ /latest – aktueller vollständiger Stand
✔ /archive/YYYY-MM-DD – Delta-Backups
✔ /snapshots/YYYY-MM-DD – komplette Vollkopien
Alle Backups sind verschlüsselt.

➤ Manuelles Backup
bash
Code kopieren
./maintenance.sh backup
➤ Liste der Snapshots
bash
Code kopieren
./maintenance.sh snapshots
➤ Wiederherstellung (Beispiel)
bash
Code kopieren
./maintenance.sh restore 2025-01-15
🧰 Wartungsskript (maintenance.sh)
Enthält vereinfachte Befehle:

backup – Sofort-Backup

snapshots – Liste anzeigen

restore YYYY-MM-DD – Wiederherstellen

stop – Stack stoppen

start – Stack starten

🎯 Warum dieser Stack?
One-Command Installation

Keine manuelle Konfiguration

Optimiertes Docker-Setup

Zero-Knowledge Backups

Snapshots + Delta-Backups

Homelab-Ready (Proxmox, Hetzner, Rootserver, Unraid)

Extraharte Sicherheit durch minimale Oberfläche und gute Defaults

📜 Lizenz
MIT License — frei verwendbar, anpassbar, kommerziell nutzbar.

✨ Autor
m0usm
GitHub: https://github.com/m0usm
Project: Universal Selfhosted Stack
