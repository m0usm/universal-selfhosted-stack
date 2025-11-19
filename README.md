# universial-stack-init

> Production-ready Bash installer that deploys a complete Traefik + Nextcloud + Paperless + n8n stack with healthchecks, SFTP, backups & secure defaults.

`universial-stack-init.sh` ist ein One-Shot-Installer für einen vollständigen Self-Hosted-Stack:

- ✅ Traefik v3 mit Let's Encrypt & BasicAuth-Dashboard  
- ✅ Nextcloud 29 + MariaDB 11  
- ✅ Paperless-ngx mit Tika, Gotenberg & Redis  
- ✅ n8n mit BasicAuth & korrekt gesetzten URLs  
- ✅ OnlyOffice Document Server  
- ✅ SFTP-Scanner für Paperless (z. B. für MFPs/Scanner)  
- ✅ Backup-Container mit verschlüsselter Hetzner Storage Box (rclone `crypt`) & optionaler Synology-Spiegelung  
- ✅ Wartungs-Skript `maintenance.sh` für Backup/Restore/Start/Stop  

Alles in **einem Bash-Script**, reproduzierbar und nachvollziehbar.

---

## Features

### 🧩 Core-Services

- **Traefik v3.1**
  - HTTP/HTTPS (Ports 80/443)
  - Automatisches Let's Encrypt (HTTP-01)
  - Dashboard hinter BasicAuth (bcrypt)
  - Rate-Limit-Middleware fürs Dashboard
  - Zertifikate in `data/traefik/acme.json` (chmod 600)

- **Nextcloud 29**
  - MariaDB 11 als DB
  - Eigener Datenordner `data/nextcloud`
  - PHP Limits:
    - `PHP_MEMORY_LIMIT=1024M`
    - `PHP_UPLOAD_LIMIT=1024M`
  - Ready für OnlyOffice Integration

- **Paperless-ngx**
  - Apache Tika 3 & Gotenberg 8 für OCR & PDF-Handling
  - Redis-Queue
  - DB:
    - Standard: SQLite  
    - Optional: PostgreSQL 16 (`PAPERLESS_USE_POSTGRES=yes`)
  - Datenverzeichnisse:
    - `data/paperless/data`
    - `data/paperless/media`
    - `data/paperless/export`
    - `data/paperless/consume` (+ `done`/`fail`)

- **OnlyOffice DocumentServer**
  - Läuft hinter Traefik
  - Einfach in Nextcloud als Document Server URL eintragen (`https://office.deinedomain.tld`)

- **n8n**
  - BasicAuth aktiviert
  - `N8N_ENCRYPTION_KEY` wird automatisch generiert und im Setup angezeigt
  - Korrekte URLs:
    - `WEBHOOK_URL`
    - `N8N_EDITOR_BASE_URL`
  - Persistente Daten in `data/n8n`

### 📥 SFTP-Scanner für Paperless

- Container: `atmoz/sftp`
- Generierter User `scanner` (User + Passwort in `.env`)
- Port: `2222`
- Verknüpfte Verzeichnisse:
  - `/home/scanner/upload` → `data/paperless/consume`
  - `/home/scanner/done`
  - `/home/scanner/fail`
- Ideal für Multifunktionsdrucker/Scanner, die per SFTP ablegen können.

### 💾 Backup & Restore

Dedizierter `backup`-Container (Alpine + rclone + mysql-client + postgresql-client + dcron):

- Backups nach **verschlüsselter Hetzner Storage Box**:
  - Verbindung per SFTP (Port 23)
  - rclone Remote:
    - `StorageBoxBase` (SFTP)
    - `StorageBox` (rclone `crypt` darüber)
  - Struktur auf Storage Box:
    ```txt
    StorageBox:
    ├─ latest/                 # aktueller Stand (voll)
    ├─ archive/                # tägliche Deltas
    │   ├─ YYYY-MM-DD/
    │   └─ …
    └─ snapshots/              # Vollsnapshots
        ├─ YYYY-MM-DD/
        └─ …
    ```

- Optionaler **Synology-Mirror** (SFTP Port 22)
  - Remote: `SYNOLOGY:${SYNOLOGY_PATH}/snapshots/…`

- Backuptypen:
  - `latest`: Vollsync aktueller Stand
  - `archive/YYYY-MM-DD`: Deltas pro Tag
  - `snapshots/YYYY-MM-DD`: vollständiger Stand als Snapshot

- Aufbewahrung:
  - `KEEP_DAYS` → wie lange Archive (`archive/*`) behalten werden
  - `SNAPSHOT_KEEP_DAYS` → wie lange Snapshots (`snapshots/*`) behalten werden
  - `WEEKLY_SNAPSHOT`:
    - `0` → täglicher Snapshot
    - `1` → nur sonntags Snapshot

- Cron:
  - Im Backup-Container: `0 2 * * * /entrypoint.sh backup` (täglich 02:00 Uhr)

### 🛠 Wartungs-Skript

`maintenance.sh` wird automatisch im `BASE_DIR` erzeugt:

```bash
./maintenance.sh              # Übersicht + Diagramm
./maintenance.sh backup       # Sofort-Backup
./maintenance.sh snapshots    # Liste Archive & Snapshots
./maintenance.sh restore 2025-11-16  # Restore auf Datumssnapshot
./maintenance.sh stop         # Alle Container stoppen
./maintenance.sh start        # Alle Container starten
Voraussetzungen
Server mit:

Debian / Ubuntu (andere können gehen, Installer versucht aber nur bei Debian/Ubuntu Docker automatisch zu installieren)

Root oder sudo

Offen:

TCP 80 (HTTP)

TCP 443 (HTTPS)

Domain mit DNS-Einträgen für:

traefik.<deinedomain>

cloud.<deinedomain>

paperless.<deinedomain>

n8n.<deinedomain>

office.<deinedomain>

Hetzner Storage Box (oder kompatible SFTP-Box)

Host, User, Passwort

Optional: Synology mit SFTP-Zugriff

Quick Start
⚠️ URL anpassen! Ersetze <DEIN-USER> und <DEIN-REPO> durch deinen GitHub-Namen und Reponamen.

bash
Code kopieren
cd /opt
git clone https://github.com/<DEIN-USER>/<DEIN-REPO>.git
cd <DEIN-REPO>

# Script herunterladen (direkt aus Raw, z. B. im README verlinkt)
curl -fsSL https://raw.githubusercontent.com/<DEIN-USER>/<DEIN-REPO>/main/universial-stack-init.sh -o universial-stack-init.sh

chmod +x universial-stack-init.sh
sudo ./universial-stack-init.sh
Das Script fragt dich interaktiv nach:

Basis-Verzeichnis für den Stack (/opt/stack default)

Let’s-Encrypt E-Mail

Basis-Domain (z. B. example.com)

Subdomains für Traefik / Nextcloud / Paperless / n8n / OnlyOffice

Paperless DB: PostgreSQL (empfohlen) oder SQLite

Hetzner Storage Box Zugang:

User, Host, Passwort, Pfad (z. B. /backup)

Optional Synology Backup:

Host, User, Passwort, Pfad, Port

Backup-Parameter:

KEEP_DAYS (Standard: 180)

WEEKLY_SNAPSHOT (0=täglich, 1=sonntags)

SNAPSHOT_KEEP_DAYS (Standard: 30)

Nach dem Setup
Das Script zeigt dir am Ende:

Traefik Dashboard:
https://traefik.<deinedomain>
→ BasicAuth-User wie eingegeben

Nextcloud:
https://cloud.<deinedomain>

Paperless-ngx:
https://paperless.<deinedomain>
→ Default-User/Pass:

User: admin

Passwort: wird im Setup-Output angezeigt

n8n:
https://n8n.<deinedomain>
→ BasicAuth-User admin + Passwort aus Output
→ Wichtig: N8N_ENCRYPTION_KEY sichern

OnlyOffice:
https://office.<deinedomain>

SFTP-Scanner:

Host: deine Server-IP oder Domain

Port: 2222

User: scanner

Passwort: im Setup-Output

Restore-Beispiele
1. Restore auf bestimmten Snapshot (Datum)
bash
Code kopieren
cd /opt/stack   # oder dein BASE_DIR
./maintenance.sh restore 2025-11-16
Ablauf:

Alle Container werden gestoppt.

Backup-Container zieht StorageBox:snapshots/2025-11-16 → /data.

DB-Dumps (nextcloud.sql und optional paperless.sql) werden eingespielt.

Container werden wieder gestartet.

2. Restore ohne Datum (aktueller Stand)
bash
Code kopieren
./maintenance.sh restore latest
Script interpretiert das als:

Sync von StorageBox:latest → /data

Optional Overlay von StorageBox:archive/<Datum> wenn angegeben

(In deinem Script ist REQ_DATE frei wählbar – du kannst z. B. restore 2025-11-10 für Archiv + latest nutzen.)

Sicherheit
Traefik-Dashboard ist:

Hinter BasicAuth (bcrypt)

Mit Rate-Limit gesichert

acme.json hat chmod 600

Alle wichtigen Secrets:

werden automatisch generiert (genpw)

werden in .env geschrieben (Permissions 600)

Storage Box:

Zugriff per SFTP mit Passwort

Daten werden via rclone crypt verschlüsselt abgelegt

Synology:

Verbindung per SFTP (optionale zweite Kopie deiner Daten)

FAQ (Kurz)
Q: Kann ich Paperless ohne PostgreSQL nutzen?
A: Ja. Standard ist SQLite. PostgreSQL kannst du beim Setup explizit aktivieren (empfohlen für größere Setups).

Q: Kann ich Domains wie cloud.meinefirma.de statt cloud.example.com nutzen?
A: Ja. Du gibst beim Setup einfach deine echte Basisdomain ein und passt die Subdomains an. Wichtiger Punkt: DNS-Einträge müssen passen.

Q: Muss Docker schon installiert sein?
A: Nicht zwingend. Auf Debian/Ubuntu versucht das Script Docker automatisch zu installieren. Auf anderen Distros musst du Docker/Compose vorher selbst installieren.

Lizenz
Hinweis: Wähle im GitHub-Dialog eine Lizenz und trage sie hier ein.
Übliche Wahl: MIT oder Apache-2.0.

Beispiel:

txt
Code kopieren
MIT License

Copyright (c) 2025 ...

Permission is hereby granted, free of charge, to any person obtaining a copy ...
TODO / Roadmap (Ideen)
 Beispiel-docker-compose.override.yml für Anpassungen

 Optionaler Mail-Stack (SMTP Relay, Mailserver)

 Zusätzliche Dienste (z. B. Jellyfin, Paperless-Import von IMAP)

 Automatische Hardening-Tipps für SSH / Firewall

Wenn du mir deine echte GitHub-URL gibst (user/repo), kann ich dir den curl-Einzeiler oben direkt mit der richtigen Raw-URL fertig machen.






