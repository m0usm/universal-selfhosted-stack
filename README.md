# universial-stack-init

> Production-ready Bash installer that deploys a complete Traefik + Nextcloud + Paperless + n8n stack with healthchecks, SFTP, backups & secure defaults.

`universial-stack-init` ist ein einmal auszuführendes Bash-Script, das dir einen kompletten Self-Host-Stack aufsetzt:

- **Traefik v3** (Reverse Proxy, Let’s Encrypt, BasicAuth, Rate-Limits)
- **Nextcloud 29** + **MariaDB 11**
- **Paperless-ngx** + optional **PostgreSQL 16**
- **OnlyOffice Document Server**
- **n8n** (Automation / Workflows)
- **SFTP-Scanner** für Paperless-Uploads (z. B. Multifunktionsdrucker)
- **Backup-Container** mit
  - `rclone` → Hetzner Storage Box (SFTP Port 23, *rclone crypt*)
  - optionalem Synology-Remote (SFTP Port 22)
  - täglichen Backups + Deltas + Voll-Snapshots
- **maintenance.sh** für Backups, Restore & Start/Stop

Alles wird in einem Rutsch erledigt: Verzeichnisstruktur, `.env`, `docker-compose.yml`, Backup-Container, Cronjob und ein kleines Wartungs-Tool.

---

## Features

- 🧩 **Ein Script, kompletter Stack**  
  Keine 10 Copy/Paste-Snippets – du beantwortest ein paar Fragen und bekommst ein konsistentes Setup.

- 🔐 **Sichere Defaults**
  - Starke, zufällig generierte Passwörter
  - Traefik-Dashboard hinter BasicAuth (`.htpasswd` mit bcrypt)
  - Let’s Encrypt mit eigener Mailadresse
  - `acme.json` mit `chmod 600`
  - Rate-Limit für das Traefik-Dashboard

- 📦 **Backups mit Strategie**
  - Täglicher Cronjob um 02:00 Uhr
  - `latest/` – aktueller vollständiger Stand
  - `archive/YYYY-MM-DD/` – tägliche Deltas
  - `snapshots/YYYY-MM-DD/` – Vollsnapshots (täglich oder wöchentlich)
  - optionaler Synology-Mirror

- 🗃️ **Paperless-ngx ready**
  - OCR via Apache Tika
  - PDF-Konvertierung via Gotenberg
  - SQLite *oder* Postgres – frei wählbar im Setup

- 🔁 **Wartungsscript**
  - Manuelles Backup
  - Snapshots auflisten
  - Restore auf beliebiges Datum
  - Start/Stop aller Container

---

## Voraussetzungen

- Linux-Server (getestet: Debian/Ubuntu)
- Root oder `sudo`-Zugriff
- Öffentlich erreichbare Ports **80** und **443**
- Eine Domain mit passenden DNS-Einträgen für:
  - `traefik.<deine-domain>`
  - `cloud.<deine-domain>`
  - `paperless.<deine-domain>`
  - `n8n.<deine-domain>`
  - `office.<deine-domain>`
- Hetzner Storage Box (SFTP, Port 23) für Backups  
  _(optional)_ Synology-NAS mit SFTP für zusätzliche Kopie

> Falls Docker noch nicht installiert ist:  
> Für Debian/Ubuntu kümmert sich das Script automatisch darum (`get.docker.com`).

---

## Quickstart

### 1. Script herunterladen

```bash
curl -fsSL https://raw.githubusercontent.com/m0usm/universial-stack-init/main/universial-stack-init.sh -o universial-stack-init.sh
chmod +x universial-stack-init.sh
2. Script ausführen
bash
Code kopieren
sudo ./universial-stack-init.sh
Du wirst u. a. nach Folgendem gefragt:

Basis-Verzeichnis (z. B. /opt/stack)

Let’s-Encrypt-Mailadresse

Basisdomain (z. B. example.com)

Subdomains für Traefik, Nextcloud, Paperless, n8n, OnlyOffice

Paperless-Datenbank: PostgreSQL (empfohlen) oder SQLite

Hetzner Storage Box Zugang (Host, User, Passwort, Pfad)

Optional: Synology-Backup (Host, User, Passwort, Pfad, Port)

Aufbewahrungsdauer für Archive & Snapshots

Dienste & URLs (Default-Schema)
Wenn du als Basisdomain example.com angibst, sehen die Standards so aus:

Traefik Dashboard: https://traefik.example.com

Nextcloud: https://cloud.example.com

Paperless: https://paperless.example.com

n8n: https://n8n.example.com

OnlyOffice: https://office.example.com

Die tatsächlichen Subdomains kannst du beim Setup anpassen.

Backup-Konzept
Backups laufen in einem eigenen Container (backup) auf Basis Alpine + rclone + mysql/psql.

Storage Box (verschlüsselt)
text
Code kopieren
StorageBox:
├─ latest/                 # aktueller kompletter Stand von /data
├─ archive/                # tägliche Deltas
│   ├─ 2025-11-10/
│   ├─ 2025-11-11/
│   └─ …
└─ snapshots/              # Vollsnapshots
    ├─ 2025-11-16/
    ├─ 2025-11-23/
    └─ …
Wartung (maintenance.sh)
bash
Code kopieren
./maintenance.sh          # Hilfe / Übersicht
./maintenance.sh backup   # Sofort-Backup
./maintenance.sh snapshots
./maintenance.sh restore 2025-11-16
Sicherheit
Traefik-Dashboard nur über BasicAuth

Passwörter werden zur Laufzeit zufällig generiert und in .env geschrieben

Let’s-Encrypt-Zertifikate werden in data/traefik/acme.json mit chmod 600 gehalten

SFTP-Scanner läuft auf Port 2222

Backups auf der Storage Box sind durch rclone crypt verschlüsselt
