Traefik • Nextcloud 31 • Paperless-ngx • n8n • OnlyOffice • Redis • SFTP-Scanner • Automated Backups

Dieses Projekt ist ein vollständiger, automatischer Setup-Wizard für einen modernen Self-Hosted-Stack.
Das Bash-Script richtet komplett selbstständig ein:

🚀 Features
🖥️ Core Services

Traefik v3 – Reverse Proxy + automatische Let’s Encrypt Zertifikate

Nextcloud 31 – Datei-Cloud, Kalender, Kontakte

OnlyOffice Document Server – Online-Dokumentbearbeitung für Nextcloud

Paperless-ngx – Dokumentenmanagement (OCR, Tags, Automatisierung)

n8n – Automationsplattform

Redis – Caching (für Nextcloud & Paperless)

MariaDB – Nextcloud-Datenbank

PostgreSQL (optional) – Paperless-Datenbank

SFTP-Scanner – Upload-Eingang für Paperless

💾 High-End Backup System

Backup-Container mit:

✔ Täglicher automatischer Backup-Job
✔ Dump von:

Nextcloud-DB (MariaDB)

Paperless-DB (PostgreSQL)

✔ Vollverschlüsselte Backups via rclone crypt
✔ Hetzner StorageBox als Ziel
✔ Synology optional als zweites Ziel
✔ Backup-Stufen:

/latest – kompletter Stand

/archive/YYYY-MM-DD – Deltas

/snapshots/YYYY-MM-DD – Vollsnapshots (täglich oder wöchentlich)

✔ Restore System:

Vollsnapshot wiederherstellen

Latest + Delta wiederherstellen

Datenbank-Wiederherstellung inklusive

🔧 Voraussetzungen

Ubuntu / Debian Server

Domain + DNS A-Records

Root-Zugriff

(Optional) Hetzner StorageBox

(Optional) Synology SFTP-Zugang

🛠️ Installation
1. Script herunterladen
wget https://raw.githubusercontent.com/m0usm/<DEIN-REPO>/main/stack-setup.sh
chmod +x stack-setup.sh

2. Setup starten
sudo ./stack-setup.sh


Das Script fragt automatisch nach:

Basisverzeichnis

Domains

Let’s Encrypt E-Mail

StorageBox Zugang

Synology Zugang (optional)

PostgreSQL ja/nein

Aufbewahrungszeiten

Snapshot-Typ (täglich / wöchentlich)

📦 Wartung

Nach dem Setup erzeugt das Script das Tool:

maintenance.sh

Verfügbare Befehle
Befehl	Funktion
./maintenance.sh backup	Sofort-Backup
./maintenance.sh snapshots	Liste aller Archive + Snapshots
./maintenance.sh restore YYYY-MM-DD	Restore auf ein Datum
./maintenance.sh stop	Stoppt Stack
./maintenance.sh start	Startet Stack
🔐 Logins & Credentials

Das Script zeigt am Ende automatisch alle wichtigen Logins an:

Traefik Dashboard

Nextcloud Admin

Paperless Admin

n8n BasicAuth

SFTP-Scanner Benutzer + Passwort

Rclone Crypt Passwort

DB-Passwörter

Alle Passwörter werden beim Setup generiert und in .env gespeichert.

📁 Projektstruktur
/opt/stack/
│
├── docker-compose.yml
├── .env
├── maintenance.sh
│
├── data/
│   ├── nextcloud/
│   ├── paperless/
│   ├── traefik/
│   ├── n8n/
│   └── sftp/
│
└── backup/
    ├── Dockerfile
    ├── entrypoint.sh
    └── .dockerignore

🔒 Sicherheitshinweise

Die StorageBox-Backups sind verschlüsselt (rclone crypt).

.env unbedingt schützen (chmod 600).

Zugriff auf Traefik Dashboard ist geschützt durch BasicAuth (bcrypt).

Nutzung hinter Firewall oder Fail2Ban empfohlen.

🧩 Warum dieses Projekt?

Kein manuelles Basteln von 20 Config-Dateien

Vollautomatische Einrichtung in 1 Command

Failsafe Backups mit Delta + Snapshots

Zero-Knowledge Backups durch rclone crypt

Ideal für Homeserver (Proxmox / Hetzner / Rootserver)

🐭 Author

m0usm
Gaming + Dev + Self-Hosting Enthusiast
GitHub: https://github.com/m0usm
