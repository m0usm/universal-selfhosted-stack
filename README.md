🖥️ Preview

🔧 Vollautomatisches Setup
🔐 Zero-Knowledge Backups (rclone crypt)
📦 Delta-Backups + Vollsnapshots
☁️ Traefik Reverse Proxy + SSL + Dashboard
📄 Nextcloud + Paperless-NGX + OnlyOffice
⚙️ n8n Automations
📨 SFTP-Scanner für Paperless (Scanner-Upload)
🛡️ Best Practices: acme.json 600, .env 600, bcrypt BasicAuth

📑 Inhalt

⭐ Features

⚡ Installation (1 Command)

🔧 Konfiguration

🔐 Login & Zugangsdaten

📁 Projektstruktur

🔒 Sicherheitshinweise

📦 Backup System (Delta + Snapshots)

🧰 Wartung (maintenance.sh)

💬 FAQ

👤 Author

⭐ Features
🧰 Komplett-Automatischer Server-Stack

Installiert Docker / Compose (falls nicht vorhanden)

Erstellt Ordnerstruktur vollständig automatisch

Generiert alle Passwörter inklusive DB, Admin, Rclone Crypt, SFTP

Erstellt .env, docker-compose.yml, maintenance.sh und Backup-Container

🔐 Sicherheit & Encryption

Traefik Dashboard gesichert via bcrypt BasicAuth

StorageBox-Backups vollständig verschlüsselt (rclone crypt)

.env wird automatisch auf 600 gesetzt

acme.json automatisch geschützt

📦 Apps
Dienst	Beschreibung
Traefik v3	Reverse Proxy + SSL + Dashboard
Nextcloud 31	Private Cloud
Paperless-ngx	Dokumentenmanagement
OnlyOffice	Online-Office Suite
n8n	Workflow Automation
Redis	Cache für Nextcloud / Paperless
Tika + Gotenberg	OCR + PDF Verarbeitung
SFTP-Scanner	Scanner-Upload direkt ins Paperless „consume“
💾 Backup System

Delta-Backups → /archive/YYYY-MM-DD

Vollsnapshots verschlüsselt → /snapshots/YYYY-MM-DD

latest → vollständiger aktueller Stand

Optional: Upload zu Synology (SFTP)

⚡ Installation (1 Command)
wget https://raw.githubusercontent.com/m0usm/UNIVERSAL-SELFHOSTED-STACK/main/setup.sh -O setup.sh
chmod +x setup.sh
sudo ./setup.sh

🧩 Konfiguration

Das Script fragt beim Start:

Basis-Verzeichnis (/opt/stack)

Domains

Let’s Encrypt E-Mail

PostgreSQL für Paperless (ja/nein)

StorageBox Zugang

Optional Synology Backup

Aufbewahrungszeiten

Dashboard BasicAuth

Alles wird automatisch übernommen.

🔐 Login & Zugangsdaten

Der Installer zeigt am Ende ALLE generierten Zugangsdaten farblich sortiert an:

Dienst	Zugang
Traefik Dashboard	Benutzer + Passwort
Nextcloud Admin	Web-Setup beim ersten Login
Paperless Admin	Benutzer + Passwort
n8n BasicAuth	Benutzer + Passwort
SFTP-Scanner	Benutzer + Passwort
StorageBox	User + Pfad
Rclone Crypt Password	Secret Key
DB Passwörter	MariaDB + Postgres (falls aktiviert)

Alle Passwörter stehen zusätzlich in:

/opt/stack/.env


⚠️ Dateirechte 600!

📁 Projektstruktur
/opt/stack/
├── docker-compose.yml
├── .env
├── setup.sh
├── maintenance.sh
├── data/
│   ├── traefik/
│   ├── nextcloud/
│   ├── paperless/
│   ├── n8n/
│   ├── sftp/
├── backup/
│   ├── Dockerfile
│   ├── entrypoint.sh
│   └── .dockerignore

🔒 Sicherheitshinweise

Backups sind vollständig verschlüsselt via rclone crypt

.env → unbedingt mit 600 schützen

Traefik Dashboard ist geschützt

Nutzung hinter Firewall / Fail2Ban empfohlen

Keine Passwörter im Klartext außer in .env

📦 Backup & Restore
🔁 Sofort-Backup:
./maintenance.sh backup

🧊 Verfügbare Snapshots anzeigen:
./maintenance.sh snapshots

🔄 Restore (Stop + Wiederherstellung + Start):
./maintenance.sh restore YYYY-MM-DD

🧰 maintenance.sh

Einfaches Wartungs-Werkzeug:

./maintenance.sh


Menü:

Backup starten

Snapshots anzeigen

Restore (mit Datum)

Stack stoppen

Stack starten

❓ FAQ
Läuft es auf Proxmox / Hetzner / Rootserver?

✔ Ja, auf allem mit Debian/Ubuntu.

Werden Backups wirklich verschlüsselt?

✔ 100% – rclone crypt (AES-256) + salted filenames.

Kann ich Nextcloud updaten?

✔ Ja, einfach Image-Version ändern.

👤 Author

m0usm
Github: https://github.com/m0usm

Projektidee: „One Command – Full Selfhosted Stack“
