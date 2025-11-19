# universial-stack-init

Production-ready Bash installer that deploys a complete **Traefik + Nextcloud + Paperless + n8n** stack with healthchecks, SFTP, encrypted backups & secure defaults.

> Self-hosted stack for people who just want a sane baseline without juggling 10 different docker-compose snippets.

---

## Features

- **Traefik v3 reverse proxy**
  - Automatic Let's Encrypt certificates (HTTP-01)
  - Dashboard behind bcrypt **BasicAuth**
  - Rate limiting middleware for the dashboard
- **Nextcloud 29 + MariaDB 11**
  - PHP memory & upload limits preconfigured
  - OnlyOffice document server container included
- **Paperless-ngx**
  - Apache Tika for OCR and Gotenberg for PDF conversion
  - Optional PostgreSQL 16, otherwise SQLite
  - Redis queue and HTTP healthchecks
- **n8n automation**
  - BasicAuth enabled
  - Correct `N8N_HOST`, `WEBHOOK_URL` and `N8N_EDITOR_BASE_URL`
  - Persistent data in `data/n8n`
- **SFTP scanner**
  - `atmoz/sftp` on host port `2222`
  - User `scanner` with generated password
  - Mapped directly to Paperless `consume/`, `done/`, `fail/`
- **Encrypted backups**
  - Dedicated backup container (Alpine + rclone + cron)
  - Hetzner Storage Box via SFTP (port 23) + **rclone crypt**
  - Layout: `latest/`, `archive/YYYY-MM-DD`, `snapshots/YYYY-MM-DD`
  - Optional Synology mirror via SFTP (port 22)
  - Automatic DB dumps for Nextcloud (MariaDB) and optionally Paperless (PostgreSQL)
- **Maintenance script**
  - `maintenance.sh backup|snapshots|restore|start|stop`
  - ASCII overview of backup/restore flow
- **Safety niceties**
  - Cleans invisible Unicode NBSP characters from generated files
  - Healthcheck + retry loop for containers
  - All secrets pushed into a `.env` with restrictive permissions

---

## Requirements

- A Linux host (Debian/Ubuntu recommended)
- Root or `sudo` access
- A domain with DNS records for:
  - `traefik.<your-domain>`
  - `cloud.<your-domain>`
  - `paperless.<your-domain>`
  - `n8n.<your-domain>`
  - `office.<your-domain>`
- Open ports `80` and `443` on the host
- Hetzner Storage Box credentials (optional but recommended)
- Optional: Synology reachable via SFTP for secondary backups

If Docker is missing, the script will install it on **Debian/Ubuntu** using `get.docker.com`.  
On other distros you need to install Docker and the Docker Compose plugin yourself.

---

## Installation

### 1. Download the installer

```bash
curl -fsSL https://raw.githubusercontent.com/m0usm/universial-stack-init/main/universial-stack-init.sh -o universial-stack-init.sh
chmod +x universial-stack-init.sh
Always read the script before running it on a production system.

2. Run the script
bash
Code kopieren
sudo ./universial-stack-init.sh
You will be asked for a few inputs:

Base directory for the stack (default: /opt/stack)

Delete / wipe options (keep data, remove containers, remove containers + volumes, or nuke the whole directory)

Let’s Encrypt email

Base domain, e.g. example.com

Traefik / Nextcloud / Paperless / n8n / OnlyOffice subdomains

Traefik dashboard credentials (BasicAuth)

Paperless DB choice

PostgreSQL (recommended) or SQLite

Hetzner Storage Box

User (e.g. u123456 / ssh-u123456)

Host (e.g. u123456.your-storagebox.de)

Path on the box (default: /backup)

Optional Synology backup

Host/IP, user, password, path, port (default 22)

Retention

Days to keep daily delta archives

Snapshots daily or weekly (Sunday)

Days to keep full snapshots

All passwords and secrets are generated automatically and written to:

text
Code kopieren
<BASE_DIR>/.env
with chmod 600.

After that the script:

Creates the full directory structure under <BASE_DIR>

Writes .env and docker-compose.yml

Generates a bcrypt .htpasswd for Traefik

Builds the backup container image

Runs docker compose pull and docker compose up -d (with --wait when available)

Checks container status in a retry loop and prints a summary

Services & Endpoints
Assuming your base domain is example.com, the default endpoints are:

Traefik dashboard – https://traefik.example.com

Nextcloud – https://cloud.example.com

Paperless-ngx – https://paperless.example.com

n8n – https://n8n.example.com

OnlyOffice – https://office.example.com

The script prints:

Traefik BasicAuth user

Paperless admin user + password

n8n BasicAuth user + password

N8N_ENCRYPTION_KEY

SFTP user/password for the scanner

Storage Box details + rclone crypt password

Backup concept
Backups are handled by a dedicated container built from backup/Dockerfile.

Inside the backup container
Daily cron at 02:00:

cron
Code kopieren
0 2 * * * /entrypoint.sh backup
What backup does
Creates DB dumps into /data/dbdumps:

nextcloud.sql (MariaDB)

paperless.sql (PostgreSQL, if enabled)

Syncs /data → StorageBox:latest

Moves changed files into StorageBox:archive/YYYY-MM-DD

Optionally creates full snapshots in StorageBox:snapshots/YYYY-MM-DD

Daily or weekly (Sunday), depending on WEEKLY_SNAPSHOT

Deletes old archives and snapshots based on:

KEEP_DAYS

SNAPSHOT_KEEP_DAYS

Optionally mirrors snapshots to Synology under:

text
Code kopieren
SYNOLOGY:<SYNOLOGY_PATH>/snapshots/YYYY-MM-DD
Remote layout (encrypted)
On the Hetzner Storage Box (inside the encrypted StorageBox remote):

text
Code kopieren
StorageBox:
├─ latest/                 # current full state of /data
├─ archive/                # daily deltas
│   ├─ 2025-11-10/
│   ├─ 2025-11-11/
│   └─ …
└─ snapshots/              # full frozen images
    ├─ 2025-11-16/
    ├─ 2025-11-23/
    └─ …
Everything in StorageBox: is encrypted via rclone crypt.
The crypt password is generated and stored as STORAGEBOX_CRYPT_PASS in .env.

Restore workflow
Restores are triggered via the maintenance script.

From <BASE_DIR>:

bash
Code kopieren
./maintenance.sh restore 2025-11-16
Steps:

Stop all containers (docker compose stop)

Run backup restore <DATE> inside the backup container

Sync data back into /data from either:

StorageBox:snapshots/<DATE> (preferred), or

StorageBox:latest (+ optional archive/<DATE> overlay)

Re-import DB dumps when available:

Nextcloud (MariaDB)

Paperless (PostgreSQL, if enabled)

Start containers again (docker compose up -d)

maintenance.sh
The installer creates a helper script in <BASE_DIR>/maintenance.sh.

Usage:

bash
Code kopieren
./maintenance.sh            # show help + diagram
./maintenance.sh backup     # trigger an immediate backup
./maintenance.sh snapshots  # list archives + snapshots
./maintenance.sh restore 2025-11-16  # restore exact snapshot
./maintenance.sh stop       # stop all services
./maintenance.sh start      # start all services
The script prints a small ASCII diagram of the backup/restore model when run without arguments.

SFTP scanner
The stack includes an atmoz/sftp container for scanners / MFPs etc.

Host: your server IP or domain

Port: 2222

User: scanner

Password: random, printed at the end of the setup

Paths inside the container:

text
Code kopieren
/home/scanner/upload  -> mapped to data/paperless/consume
/home/scanner/done    -> mapped to data/paperless/consume/done
/home/scanner/fail    -> mapped to data/paperless/consume/fail
Upload scans to upload/, let Paperless process them, and optionally move them to done/ / fail/ depending on your workflows.

Security notes
Traefik dashboard is protected by bcrypt BasicAuth (.htpasswd).

acme.json for Let’s Encrypt is created with chmod 600.

Secrets (DB credentials, encryption keys, SFTP passwords, rclone crypt passphrase) are written to .env with chmod 600.

Backups on the Storage Box are fully encrypted using rclone crypt.

The script strips potential invisible NBSP characters from itself and generated files to avoid weird Bash/YAML issues.

You are still responsible for:

Hardening the host OS (SSH, firewall, updates)

Restricting access to the Traefik dashboard

Keeping Docker images up to date (docker compose pull && docker compose up -d)

Troubleshooting
Containers keep restarting

Run docker compose ps and docker compose logs <service> in <BASE_DIR>

Traefik doesn’t get certificates

Check DNS records for your domain

Make sure ports 80/443 are reachable from the internet

Backup container fails

Check Storage Box credentials & firewall

Verify STORAGEBOX_HOST, STORAGEBOX_USER, STORAGEBOX_PASSWORD, STORAGEBOX_PATH

Restore didn’t bring back DB data

Ensure dbdumps/nextcloud.sql / dbdumps/paperless.sql exist in the snapshot

Check DB logs after restore

License
This project is licensed under the MIT License.
See the LICENSE file for details.

Coded by m0usm 🚀
