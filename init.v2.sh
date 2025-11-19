#!/usr/bin/env bash
set -euo pipefail

# --- Clean invisible Unicode spaces (e.g. NBSP) to prevent Bash errors ---
# Wichtig: Diese Zeile muss am Anfang bleiben, falls unsichtbare Zeichen vorhanden sind.
sed -i 's/\xC2\xA0/ /g' "$0"

# =============================
# Universal One-Shot Init (Traefik + Nextcloud + Paperless + n8n + Backup + SFTP Scanner)
# =========================================================================

# -------- helpers ----------
genpw() { tr -dc 'A-Za-z0-9' </dev/urandom | head -c "${1:-24}"; echo; }
say()   { printf "\n\033[1;32m%s\033[0m\n" "$*"; }
warn()  { printf "\n\033[1;33m%s\033[0m\n" "$*"; }
err()   { printf "\n\033[1;31m%s\033[0m\n" "$*"; }

# -------- 0) Inputs ----------
say "🧰 Universelles Setup – bitte Eingaben machen."

read -rp "Basis-Verzeichnis für den Stack [/opt/stack]: " BASE_DIR
BASE_DIR="${BASE_DIR:-/opt/stack}"
DC="${BASE_DIR}/docker-compose.yml"
ENVF="${BASE_DIR}/.env"

say "🧽 Lösch-Optionen:"
echo "  [0] Nichts löschen (weiter mit Setup)"
echo "  [1] Nur Container stoppen/entfernen (docker compose down)"
echo "  [2] Container + Volumes entfernen (docker compose down -v)"
echo "  [3] KOMPLETTES Verzeichnis löschen (rm -rf ${BASE_DIR})"
read -rp "Wähle 0/1/2/3 [0]: " WIPE_CHOICE
WIPE_CHOICE="${WIPE_CHOICE:-0}"

read -rp "Let’s-Encrypt E-Mail [admin@example.com]: " LE_EMAIL
LE_EMAIL="${LE_EMAIL:-admin@example.com}"

read -rp "Basisdomain (z. B. example.com): " BASE_DOMAIN
while [[ -z "${BASE_DOMAIN}" ]]; do
  read -rp "Basisdomain darf nicht leer sein. Bitte eingeben (z. B. example.com): " BASE_DOMAIN
done

# Subdomains mit Defaults auf Basis der Basisdomain
read -rp "Traefik-Domain [traefik.${BASE_DOMAIN}]: " TRAEFIK_HOST
TRAEFIK_HOST="${TRAEFIK_HOST:-traefik.${BASE_DOMAIN}}"

read -rp "Nextcloud-Domain [cloud.${BASE_DOMAIN}]: " NEXTCLOUD_HOST
NEXTCLOUD_HOST="${NEXTCLOUD_HOST:-cloud.${BASE_DOMAIN}}"

read -rp "Paperless-Domain [paperless.${BASE_DOMAIN}]: " PAPERLESS_HOST
PAPERLESS_HOST="${PAPERLESS_HOST:-paperless.${BASE_DOMAIN}}"

read -rp "n8n-Domain [n8n.${BASE_DOMAIN}]: " N8N_HOST
N8N_HOST="${N8N_HOST:-n8n.${BASE_DOMAIN}}"

read -rp "OnlyOffice-Domain [office.${BASE_DOMAIN}]: " ONLYOFFICE_HOST
ONLYOFFICE_HOST="${ONLYOFFICE_HOST:-office.${BASE_DOMAIN}}"

# Traefik Dashboard BasicAuth
say "🔒 Traefik Dashboard BasicAuth (wird geschützt)"
read -rp "Traefik-Dashboard Benutzer [admin]: " TFA_USER
TFA_USER="${TFA_USER:-admin}"
read -rsp "Traefik-Dashboard Passwort: " TFA_PASS; echo
read -rsp "Traefik-Dashboard Passwort (Wiederholung): " TFA_PASS2; echo
if [ "$TFA_PASS" != "$TFA_PASS2" ]; then
  err "Passwörter stimmen nicht überein."
  exit 1
fi

# Paperless DB-Wahl
read -rp "Paperless mit PostgreSQL betreiben? (empfohlen) [Y/n]: " PGPAPER
PGPAPER="${PGPAPER:-Y}"
case "${PGPAPER}" in
  n|N) PAPERLESS_USE_POSTGRES="no" ;;
  *)   PAPERLESS_USE_POSTGRES="yes" ;;
esac

# StorageBox Zugang
say "💾 Hetzner Storage Box (Passwort-Auth)"
read -rp "StorageBox User (z. B. u503434 oder ssh-u503434): " SB_USER
read -rp "StorageBox Host (z. B. u503434.your-storagebox.de): " SB_HOST
read -rsp "StorageBox Passwort (Eingabe wird nicht angezeigt): " SB_PASS; echo
read -rp "StorageBox Pfad [/backup]: " SB_PATH
SB_PATH="${SB_PATH:-/backup}"

# Synology-Backup optional (Passwort)
read -rp "Zusätzliches Backup auf Synology aktivieren? [y/N]: " SYNO_EN
SYNO_EN="${SYNO_EN:-N}"
if [[ "$SYNO_EN" =~ ^[Yy]$ ]]; then
  say "🧩 Synology (per SFTP/SSH über Port 22)"
  read -rp "Synology Host/IP (z. B. 192.168.8.50): " SYNOLOGY_HOST
  read -rp "Synology Benutzer (z. B. backupuser): " SYNOLOGY_USER
  read -rsp "Synology Passwort (Eingabe wird nicht angezeigt): " SYNOLOGY_PASSWORD; echo
  read -rp "Synology Pfad [/volume1/Backups/unraid]: " SYNOLOGY_PATH
  SYNOLOGY_PATH="${SYNOLOGY_PATH:-/volume1/Backups/unraid}"
  read -rp "Synology Port [22]: " SYNOLOGY_PORT
  SYNOLOGY_PORT="${SYNOLOGY_PORT:-22}"
else
  SYNOLOGY_HOST=""
  SYNOLOGY_USER=""
  SYNOLOGY_PASSWORD=""
  SYNOLOGY_PATH=""
  SYNOLOGY_PORT=""
fi

# Wie lange Backups aufbewahrt werden sollen (in Tagen) – für archive/
read -rp "Delta-Archive (Tages-Ordner) aufbewahren für [180] Tage: " KEEP_DAYS
KEEP_DAYS="${KEEP_DAYS:-180}"

read -rp "Vollsnapshot täglich (0) oder wöchentlich (1) erstellen? [0/1]: " WEEKLY_SNAPSHOT
WEEKLY_SNAPSHOT="${WEEKLY_SNAPSHOT:-0}"

read -rp "Vollschnapshots aufbewahren für [30] Tage: " SNAPSHOT_KEEP_DAYS
SNAPSHOT_KEEP_DAYS="${SNAPSHOT_KEEP_DAYS:-30}"

# -------- 1) Optionales Wipe ----------
if [ -d "${BASE_DIR}" ]; then
  case "${WIPE_CHOICE}" in
    1)
      say "🛑 Stoppe und entferne Container (ohne Volumes)…"
      if [ -f "${DC}" ]; then (cd "${BASE_DIR}" && docker compose down) || true; else warn "Kein ${DC} gefunden – überspringe docker compose down."; fi
      ;;
    2)
      say "🗑️ Stoppe Container und entferne Volumes…"
      if [ -f "${DC}" ]; then (cd "${BASE_DIR}" && docker compose down -v) || true; else warn "Kein ${DC} gefunden – überspringe docker compose down -v."; fi
      ;;
    3)
      warn "🚨 ALLES in ${BASE_DIR} wird gelöscht!"
      read -rp "Sicher? Tippe genau 'JA, LOESCHEN': " CONFIRM_WIPE
      if [[ "${CONFIRM_WIPE}" == "JA, LOESCHEN" ]]; then
        if [ -f "${DC}" ]; then (cd "${BASE_DIR}" && docker compose down -v) || true; fi
        rm -rf "${BASE_DIR}"
        say "✅ ${BASE_DIR} vollständig entfernt."
      else
        warn "Löschen abgebrochen. Fahre ohne Komplettlöschung fort."
      fi
      ;;
    0|*) say "ℹ️ Keine Löschung gewählt." ;;
  esac
else
  say "ℹ️ Verzeichnis ${BASE_DIR} existierte nicht – kein Wipe nötig."
fi

# -------- 2) Docker prüfen/Installieren ----------
if ! command -v docker >/dev/null 2>&1; then
  warn "Docker nicht gefunden – versuche Docker zu installieren (Debian/Ubuntu)…"
  if ! command -v apt-get >/dev/null 2>&1; then
    err "Automatische Docker-Installation unterstützt nur Debian/Ubuntu. Bitte Docker manuell installieren."
    exit 1
  fi
  apt-get update -y
  apt-get install -y ca-certificates curl gnupg
  curl -fsSL https://get.docker.com | sh
fi
if ! docker compose version >/dev/null 2>&1; then
  err "Docker Compose Plugin fehlt. Bitte Docker/Compose installieren."
  exit 1
fi

# -------- 3) Struktur ----------
say "📁 Erstelle Struktur in ${BASE_DIR}"
mkdir -p "${BASE_DIR}/data/traefik/auth"
mkdir -p "${BASE_DIR}/data/nextcloud/db" "${BASE_DIR}/data/nextcloud/html"
mkdir -p "${BASE_DIR}/data/paperless/db" \
         "${BASE_DIR}/data/paperless/data" \
         "${BASE_DIR}/data/paperless/media" \
         "${BASE_DIR}/data/paperless/export" \
         "${BASE_DIR}/data/paperless/consume"
mkdir -p "${BASE_DIR}/data/paperless/consume/done" \
         "${BASE_DIR}/data/paperless/consume/fail"
mkdir -p "${BASE_DIR}/data/n8n"
mkdir -p "${BASE_DIR}/backup"
touch "${BASE_DIR}/data/traefik/acme.json"
chmod 600 "${BASE_DIR}/data/traefik/acme.json" || true

# .dockerignore für Backup-Container
cat > "${BASE_DIR}/backup/.dockerignore" <<'EOF'
# Ignore unnecessary files for smaller builds
.git
*.log
*.tmp
*.bak
*.sql
*.tar
EOF

# -------- 4) Secrets ----------
TZV="Europe/Berlin"

NC_DB="nextcloud"
NC_DB_USER="ncuser"
NC_DB_PASS="$(genpw 20)"
NC_DB_ROOT="$(genpw 24)"

PAPERLESS_SECRET="$(genpw 48)"
PAPERLESS_ADMIN="admin"
PAPERLESS_ADMIN_PASS="$(genpw 20)"
if [ "${PAPERLESS_USE_POSTGRES}" = "yes" ]; then
  PAPERLESS_DB_PASSWORD="$(genpw 24)"
else
  PAPERLESS_DB_PASSWORD=""
fi

N8N_USER="admin"
N8N_PASS="$(genpw 20)"
N8N_KEY="$(genpw 32)"

SFTP_USER="scanner"
SFTP_PASS="$(genpw 20)"

# Rclone Crypt Passwort für StorageBox-Verschlüsselung
SB_CRYPT_PASS="$(genpw 32)"

# -------- 5) .env schreiben ----------
say "📝 Schreibe ${ENVF}"
cat > "${ENVF}" <<EOF
# Basics
TZ=${TZV}
LE_EMAIL=${LE_EMAIL}

# Domains
BASE_DOMAIN=${BASE_DOMAIN}
TRAEFIK_HOST=${TRAEFIK_HOST}
NEXTCLOUD_HOST=${NEXTCLOUD_HOST}
PAPERLESS_HOST=${PAPERLESS_HOST}
N8N_HOST=${N8N_HOST}
ONLYOFFICE_HOST=${ONLYOFFICE_HOST}

# Nextcloud DB
NEXTCLOUD_DB=${NC_DB}
NEXTCLOUD_DB_USER=${NC_DB_USER}
NEXTCLOUD_DB_PASSWORD=${NC_DB_PASS}
NEXTCLOUD_DB_ROOT=${NC_DB_ROOT}

# Paperless
PAPERLESS_SECRET_KEY=${PAPERLESS_SECRET}
PAPERLESS_ADMIN_USER=${PAPERLESS_ADMIN}
PAPERLESS_ADMIN_PASSWORD=${PAPERLESS_ADMIN_PASS}
PAPERLESS_DB_PASSWORD=${PAPERLESS_DB_PASSWORD}
PAPERLESS_USE_POSTGRES=${PAPERLESS_USE_POSTGRES}

# n8n
N8N_BASIC_AUTH_USER=${N8N_USER}
N8N_BASIC_AUTH_PASSWORD=${N8N_PASS}
N8N_ENCRYPTION_KEY=${N8N_KEY}

# SFTP Scanner Access
SFTP_USER=${SFTP_USER}
SFTP_PASS=${SFTP_PASS}

# Storage Box (Password auth + Rclone Crypt)
STORAGEBOX_HOST=${SB_HOST}
STORAGEBOX_USER=${SB_USER}
STORAGEBOX_PASSWORD=${SB_PASS}
STORAGEBOX_PATH=${SB_PATH}
STORAGEBOX_CRYPT_PASS=${SB_CRYPT_PASS}

# Synology Backup (optional, per Passwort)
SYNOLOGY_HOST=${SYNOLOGY_HOST}
SYNOLOGY_USER=${SYNOLOGY_USER}
SYNOLOGY_PASSWORD=${SYNOLOGY_PASSWORD}
SYNOLOGY_PATH=${SYNOLOGY_PATH}
SYNOLOGY_PORT=${SYNOLOGY_PORT}

# Backup-Aufbewahrungstage (archive)
KEEP_DAYS=${KEEP_DAYS}

# Vollsnapshots (zusätzlich zu latest+archive)
WEEKLY_SNAPSHOT=${WEEKLY_SNAPSHOT}
SNAPSHOT_KEEP_DAYS=${SNAPSHOT_KEEP_DAYS}
EOF
chmod 600 "${ENVF}"

# -------- 6) Traefik .htpasswd generieren (bcrypt) ----------
say "🔐 Erzeuge Traefik BasicAuth (.htpasswd)…"
HTPASSWD_FILE="${BASE_DIR}/data/traefik/auth/.htpasswd"
docker run --rm httpd:2.4-alpine sh -c "htpasswd -nbB '$TFA_USER' '$TFA_PASS'" > "$HTPASSWD_FILE"
chmod 600 "$HTPASSWD_FILE"
unset TFA_PASS TFA_PASS2

# -------- 7) docker-compose.yml ----------
say "🧾 Schreibe ${DC}"

# Compose (Teil 1: gemeinsame Services)
cat > "${DC}" <<'YML'
version: "3.9"

services:
  traefik:
    image: traefik:v3.1
    container_name: traefik
    restart: unless-stopped
    command:
      - --providers.docker=true
      - --providers.docker.exposedbydefault=false
      - --entrypoints.web.address=:80
      - --entrypoints.websecure.address=:443
      - --certificatesresolvers.letsencrypt.acme.httpchallenge=true
      - --certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web
      - --certificatesresolvers.letsencrypt.acme.email=${LE_EMAIL}
      - --certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json
      - --api.dashboard=true
      - --ping=true
    ports:
      - "80:80"
      - "443:443"
    environment:
      - TZ=${TZ}
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./data/traefik:/letsencrypt
      - ./data/traefik/auth:/auth:ro
    labels:
      - traefik.enable=true
      - traefik.http.routers.traefik.rule=Host(`${TRAEFIK_HOST}`)
      - traefik.http.routers.traefik.entrypoints=websecure
      - traefik.http.routers.traefik.tls.certresolver=letsencrypt
      - traefik.http.routers.traefik.service=api@internal
      # Middlewares
      - traefik.http.middlewares.traefik-auth.basicauth.usersfile=/auth/.htpasswd
      - traefik.http.middlewares.traefik-ratelimit.ratelimit.average=10
      - traefik.http.middlewares.traefik-ratelimit.ratelimit.burst=20
      - traefik.http.routers.traefik.middlewares=traefik-auth@docker,traefik-ratelimit@docker

  nextcloud_db:
    image: mariadb:11
    container_name: nextcloud_db
    restart: unless-stopped
    environment:
      - TZ=${TZ}
      - MYSQL_ROOT_PASSWORD=${NEXTCLOUD_DB_ROOT}
      - MYSQL_DATABASE=${NEXTCLOUD_DB}
      - MYSQL_USER=${NEXTCLOUD_DB_USER}
      - MYSQL_PASSWORD=${NEXTCLOUD_DB_PASSWORD}
    volumes:
      - ./data/nextcloud/db:/var/lib/mysql
    healthcheck:
      test: ["CMD-SHELL", "mysqladmin ping -h 127.0.0.1 -u root -p$$MYSQL_ROOT_PASSWORD --silent"]
      interval: 10s
      timeout: 5s
      retries: 12
      start_period: 30s

  nextcloud:
    image: nextcloud:31
    container_name: nextcloud
    restart: unless-stopped
    depends_on:
      - nextcloud_db
    environment:
      - TZ=${TZ}
      - MYSQL_HOST=nextcloud_db
      - MYSQL_DATABASE=${NEXTCLOUD_DB}
      - MYSQL_USER=${NEXTCLOUD_DB_USER}
      - MYSQL_PASSWORD=${NEXTCLOUD_DB_PASSWORD}
      - PHP_MEMORY_LIMIT=1024M
      - PHP_UPLOAD_LIMIT=1024M
    volumes:
      - ./data/nextcloud/html:/var/www/html
    labels:
      - traefik.enable=true
      - traefik.http.routers.nextcloud.rule=Host(`${NEXTCLOUD_HOST}`)
      - traefik.http.routers.nextcloud.entrypoints=websecure
      - traefik.http.routers.nextcloud.tls.certresolver=letsencrypt
      - traefik.http.services.nextcloud.loadbalancer.server.port=80
    healthcheck:
      test: ["CMD-SHELL", "php -r 'exit(@file_get_contents(\"http://localhost/status.php\")?0:1);'"]
      interval: 15s
      timeout: 5s
      retries: 8
      start_period: 40s

  onlyoffice:
    image: onlyoffice/documentserver:latest
    container_name: onlyoffice
    restart: unless-stopped
    environment:
      - TZ=${TZ}
    labels:
      - traefik.enable=true
      - traefik.http.routers.onlyoffice.rule=Host(`${ONLYOFFICE_HOST}`)
      - traefik.http.routers.onlyoffice.entrypoints=websecure
      - traefik.http.routers.onlyoffice.tls.certresolver=letsencrypt
      - traefik.http.services.onlyoffice.loadbalancer.server.port=80
    healthcheck:
      test: ["CMD-SHELL", "curl -fsS http://localhost/healthcheck >/dev/null || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 60s

  redis:
    image: redis:7-alpine
    container_name: redis
    restart: unless-stopped
    command: ["redis-server","--appendonly","yes"]
    environment:
      - TZ=${TZ}
    healthcheck:
      test: ["CMD-SHELL", "redis-cli ping | grep -q PONG"]
      interval: 10s
      timeout: 4s
      retries: 10
      start_period: 10s

  tika:
    image: apache/tika:3.2.3.0
    container_name: tika
    restart: unless-stopped

  gotenberg:
    image: gotenberg/gotenberg:8
    container_name: gotenberg
    restart: unless-stopped
    command:
      - gotenberg
      - --chromium-disable-javascript=true

YML

# Compose (Teil 2: optionaler Postgres für Paperless)
if [ "${PAPERLESS_USE_POSTGRES}" = "yes" ]; then
  cat >> "${DC}" <<'YML'

  paperless_db:
    image: postgres:16-alpine
    container_name: paperless_db
    restart: unless-stopped
    environment:
      - POSTGRES_DB=paperless
      - POSTGRES_USER=paperless
      - POSTGRES_PASSWORD=${PAPERLESS_DB_PASSWORD}
    volumes:
      - ./data/paperless/db:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U paperless -h localhost"]
      interval: 10s
      timeout: 5s
      retries: 10
      start_period: 20s
YML
fi

# Compose (Teil 3: Paperless Service – je nach DB)
if [ "${PAPERLESS_USE_POSTGRES}" = "yes" ]; then
  cat >> "${DC}" <<'YML'

  paperless:
    image: ghcr.io/paperless-ngx/paperless-ngx:latest
    container_name: paperless
    restart: unless-stopped
    depends_on:
      - redis
      - tika
      - gotenberg
      - paperless_db
    environment:
      - TZ=${TZ}
      - PAPERLESS_REDIS=redis://redis:6379
      - PAPERLESS_TIKA_ENABLED=1
      - PAPERLESS_TIKA_URL=http://tika:9998
      - PAPERLESS_GOTENBERG_ENDPOINT=http://gotenberg:3000
      - PAPERLESS_SECRET_KEY=${PAPERLESS_SECRET_KEY}
      - PAPERLESS_ADMIN_USER=${PAPERLESS_ADMIN_USER}
      - PAPERLESS_ADMIN_PASSWORD=${PAPERLESS_ADMIN_PASSWORD}
      - PAPERLESS_OCR_LANGUAGE=deu
      - PAPERLESS_TIME_ZONE=${TZ}
      - PAPERLESS_DBENGINE=postgresql
      - PAPERLESS_DBHOST=paperless_db
      - PAPERLESS_DBPORT=5432
      - PAPERLESS_DBNAME=paperless
      - PAPERLESS_DBUSER=paperless
      - PAPERLESS_DBPASS=${PAPERLESS_DB_PASSWORD}
    volumes:
      - ./data/paperless/data:/usr/src/paperless/data
      - ./data/paperless/media:/usr/src/paperless/media
      - ./data/paperless/export:/usr/src/paperless/export
      - ./data/paperless/consume:/usr/src/paperless/consume
    labels:
      - traefik.enable=true
      - traefik.http.routers.paperless.rule=Host(`${PAPERLESS_HOST}`)
      - traefik.http.routers.paperless.entrypoints=websecure
      - traefik.http.routers.paperless.tls.certresolver=letsencrypt
      - traefik.http.services.paperless.loadbalancer.server.port=8000
    healthcheck:
      test: ["CMD-SHELL", "python - <<'PY'\nimport sys,urllib.request\ntry:\n  urllib.request.urlopen('http://localhost:8000', timeout=5)\n  sys.exit(0)\nexcept:\n  sys.exit(1)\nPY"]
      interval: 15s
      timeout: 6s
      retries: 10
      start_period: 40s
YML
else
  cat >> "${DC}" <<'YML'

  paperless:
    image: ghcr.io/paperless-ngx/paperless-ngx:latest
    container_name: paperless
    restart: unless-stopped
    depends_on:
      - redis
      - tika
      - gotenberg
    environment:
      - TZ=${TZ}
      - PAPERLESS_REDIS=redis://redis:6379
      - PAPERLESS_TIKA_ENABLED=1
      - PAPERLESS_TIKA_URL=http://tika:9998
      - PAPERLESS_GOTENBERG_ENDPOINT=http://gotenberg:3000
      - PAPERLESS_SECRET_KEY=${PAPERLESS_SECRET_KEY}
      - PAPERLESS_ADMIN_USER=${PAPERLESS_ADMIN_USER}
      - PAPERLESS_ADMIN_PASSWORD=${PAPERLESS_ADMIN_PASSWORD}
      - PAPERLESS_OCR_LANGUAGE=deu
      - PAPERLESS_TIME_ZONE=${TZ}
      # SQLite default
    volumes:
      - ./data/paperless/data:/usr/src/paperless/data
      - ./data/paperless/media:/usr/src/paperless/media
      - ./data/paperless/export:/usr/src/paperless/export
      - ./data/paperless/consume:/usr/src/paperless/consume
    labels:
      - traefik.enable=true
      - traefik.http.routers.paperless.rule=Host(`${PAPERLESS_HOST}`)
      - traefik.http.routers.paperless.entrypoints=websecure
      - traefik.http.routers.paperless.tls.certresolver=letsencrypt
      - traefik.http.services.paperless.loadbalancer.server.port=8000
    healthcheck:
      test: ["CMD-SHELL", "python - <<'PY'\nimport sys,urllib.request\ntry:\n  urllib.request.urlopen('http://localhost:8000', timeout=5)\n  sys.exit(0)\nexcept:\n  sys.exit(1)\nPY"]
      interval: 15s
      timeout: 6s
      retries: 10
      start_period: 40s
YML
fi

# Compose (Teil 4: Rest)
cat >> "${DC}" <<'YML'

  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    environment:
      - TZ=${TZ}
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=${N8N_BASIC_AUTH_USER}
      - N8N_BASIC_AUTH_PASSWORD=${N8N_BASIC_AUTH_PASSWORD}
      - N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY}
      - N8N_HOST=${N8N_HOST}
      - N8N_PROTOCOL=https
      - N8N_PORT=5678
      - WEBHOOK_URL=https://${N8N_HOST}/
      - N8N_EDITOR_BASE_URL=https://${N8N_HOST}/
    volumes:
      - ./data/n8n:/home/node/.n8n
      - ./data/paperless/consume:/consume_folder_for_paperless
    labels:
      - traefik.enable=true
      - traefik.http.routers.n8n.rule=Host(`${N8N_HOST}`)
      - traefik.http.routers.n8n.entrypoints=websecure
      - traefik.http.routers.n8n.tls.certresolver=letsencrypt
      - traefik.http.services.n8n.loadbalancer.server.port=5678
    healthcheck:
      test: ["CMD-SHELL", "node -e \"require('http').get('http://localhost:5678/healthz',r=>process.exit(r.statusCode===200?0:1)).on('error',()=>process.exit(1))\""]
      interval: 15s
      timeout: 6s
      retries: 10
      start_period: 40s

  sftp_scanner:
    image: atmoz/sftp:latest
    container_name: sftp_scanner
    restart: unless-stopped
    ports:
      - "2222:22"
    environment:
      - TZ=${TZ}
    command: ${SFTP_USER}:${SFTP_PASS}:1001
    volumes:
      - ./data/paperless/consume:/home/${SFTP_USER}/upload
      - ./data/paperless/consume/done:/home/${SFTP_USER}/done
      - ./data/paperless/consume/fail:/home/${SFTP_USER}/fail
    labels:
      - traefik.enable=false

  backup:
    build: ./backup
    container_name: backup
    restart: unless-stopped
    environment:
      - TZ=${TZ}
      - NEXTCLOUD_DB_HOST=nextcloud_db
      - NEXTCLOUD_DB=${NEXTCLOUD_DB}
      - NEXTCLOUD_DB_USER=${NEXTCLOUD_DB_USER}
      - NEXTCLOUD_DB_PASSWORD=${NEXTCLOUD_DB_PASSWORD}
      - PAPERLESS_DB_PASSWORD=${PAPERLESS_DB_PASSWORD}
      - PAPERLESS_USE_POSTGRES=${PAPERLESS_USE_POSTGRES}
      - STORAGEBOX_HOST=${STORAGEBOX_HOST}
      - STORAGEBOX_USER=${STORAGEBOX_USER}
      - STORAGEBOX_PASSWORD=${STORAGEBOX_PASSWORD}
      - STORAGEBOX_PATH=${STORAGEBOX_PATH}
      - STORAGEBOX_CRYPT_PASS=${STORAGEBOX_CRYPT_PASS}
      - SYNOLOGY_HOST=${SYNOLOGY_HOST}
      - SYNOLOGY_USER=${SYNOLOGY_USER}
      - SYNOLOGY_PASSWORD=${SYNOLOGY_PASSWORD}
      - SYNOLOGY_PATH=${SYNOLOGY_PATH}
      - SYNOLOGY_PORT=${SYNOLOGY_PORT}
      - KEEP_DAYS=${KEEP_DAYS}
      - WEEKLY_SNAPSHOT=${WEEKLY_SNAPSHOT}
      - SNAPSHOT_KEEP_DAYS=${SNAPSHOT_KEEP_DAYS}
    volumes:
      - ./data:/data
      - /etc/localtime:/etc/localtime:ro
YML

# -------- 8) Backup-Container Dateien ----------
say "📦 Erstelle Backup-Container-Dateien …"

cat > "${BASE_DIR}/backup/Dockerfile" <<'EOF'
FROM alpine:3.20
# postgresql-client für optionalen Paperless-Dump und curl für Healthchecks/APIs
RUN apk add --no-cache rclone mysql-client openssh-client postgresql-client curl
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
# Cronjob für tägliches Backup um 2:00 Uhr (BusyBox crond)
RUN printf '0 2 * * * /entrypoint.sh backup\n' > /etc/crontabs/root
ENTRYPOINT ["/entrypoint.sh"]
CMD ["cron"]
EOF

cat > "${BASE_DIR}/backup/entrypoint.sh" <<'EOF'
#!/bin/sh
set -e

# Zweistufige Rclone-Remote (SFTP -> CRYPT)

# 1. Basis-SFTP-Verbindung zur Storage Box
export RCLONE_CONFIG_STORAGEBOX_SFTP_TYPE=sftp
export RCLONE_CONFIG_STORAGEBOX_SFTP_HOST=${STORAGEBOX_HOST}
export RCLONE_CONFIG_STORAGEBOX_SFTP_USER=${STORAGEBOX_USER}
export RCLONE_CONFIG_STORAGEBOX_SFTP_PASS="$(rclone obscure "${STORAGEBOX_PASSWORD}")"
export RCLONE_CONFIG_STORAGEBOX_SFTP_PORT=23
export RCLONE_CONFIG_STORAGEBOX_SFTP_USE_SSH_AGENT=false
export RCLONE_CONFIG_STORAGEBOX_SFTP_HOST_KEY_CHECKING=false

# 2. Verschlüsselte Schicht ('StorageBox' ist der Name, der im Skript verwendet wird)
export RCLONE_CONFIG_STORAGEBOX_TYPE=crypt
# Verwende die SFTP-Remote als Basis und den StorageBox-Pfad als Root-Verzeichnis
export RCLONE_CONFIG_STORAGEBOX_REMOTE=storagebox-sftp:${STORAGEBOX_PATH}
export RCLONE_CONFIG_STORAGEBOX_FILENAME_ENCRYPTION=standard
export RCLONE_CONFIG_STORAGEBOX_PASSWORD="$(rclone obscure "${STORAGEBOX_CRYPT_PASS}")"
export RCLONE_CONFIG_STORAGEBOX_PASSWORD2="$(rclone obscure "${STORAGEBOX_CRYPT_PASS}")"

setup_synology_remote() {
  if [ -n "${SYNOLOGY_HOST:-}" ] && [ -n "${SYNOLOGY_USER:-}" ] && [ -n "${SYNOLOGY_PASSWORD:-}" ] && [ -n "${SYNOLOGY_PATH:-}" ]; then
    echo "Einrichtung Synology-Remote..."
    export RCLONE_CONFIG_SYNOLOGY_TYPE=sftp
    export RCLONE_CONFIG_SYNOLOGY_HOST=${SYNOLOGY_HOST}
    export RCLONE_CONFIG_SYNOLOGY_USER=${SYNOLOGY_USER}
    export RCLONE_CONFIG_SYNOLOGY_PASS="$(rclone obscure "${SYNOLOGY_PASSWORD}")"
    export RCLONE_CONFIG_SYNOLOGY_PORT=${SYNOLOGY_PORT:-22}
    export RCLONE_CONFIG_SYNOLOGY_USE_SSH_AGENT=false
    export RCLONE_CONFIG_SYNOLOGY_HOST_KEY_CHECKING=false
    return 0
  else
    echo "ℹ️ Synology-Variablen nicht gesetzt – überspringe Synology-Vorbereitung."
    return 1
  fi
}

run_backup() {
  echo "Backup-Prozess gestartet..."
  mkdir -p /data/dbdumps

  echo "Dump der Nextcloud-DB (MariaDB)..."
  mysqldump -h nextcloud_db -u${NEXTCLOUD_DB_USER} -p${NEXTCLOUD_DB_PASSWORD} ${NEXTCLOUD_DB} > /data/dbdumps/nextcloud.sql || echo "DB Dump fehlgeschlagen, fahre fort..."

  # Dump Paperless (PostgreSQL), falls verwendet
  if [ "${PAPERLESS_USE_POSTGRES:-no}" = "yes" ]; then
    echo "Dump der Paperless-DB (PostgreSQL)..."
    export PGPASSWORD=${PAPERLESS_DB_PASSWORD}
    pg_dump -h paperless_db -U paperless -F p paperless > /data/dbdumps/paperless.sql || echo "Paperless-DB Dump fehlgeschlagen, fahre fort..."
    unset PGPASSWORD
  fi

  echo "Sync nach 'latest' + Archiv mit Tagesordner (StorageBox/CRYPT)…"
  rclone sync /data "StorageBox:latest" \
    --backup-dir="StorageBox:archive/$(date +%Y-%m-%d)" \
    --fast-list \
    -v --log-file=/dev/stdout

  KEEP_DAYS="${KEEP_DAYS:-180}"
  echo "Pruning (älter als ${KEEP_DAYS} Tage entfernen - StorageBox/archive)…"
  rclone delete "StorageBox:archive" \
    --min-age ${KEEP_DAYS}d \
    --fast-list \
    -v --log-file=/dev/stdout || true
  rclone rmdirs "StorageBox:archive" \
    --fast-list \
    -v --log-file=/dev/stdout || true

  DOW="$(date +%u)"
  WEEKLY_SNAPSHOT="${WEEKLY_SNAPSHOT:-0}" # 0 = täglich, 1 = wöchentlich (Sonntag)
  SNAPSHOT_KEEP_DAYS="${SNAPSHOT_KEEP_DAYS:-30}"
  SNAPSHOT_DATE="$(date +%F)"

  MAKE_SNAPSHOT=0
  if [ "$WEEKLY_SNAPSHOT" = "1" ] && [ "$DOW" = "7" ]; then
    MAKE_SNAPSHOT=1
  elif [ "$WEEKLY_SNAPSHOT" = "0" ]; then
    MAKE_SNAPSHOT=1
  fi

  if [ "$MAKE_SNAPSHOT" = "1" ]; then
    echo "🧊 Erzeuge Vollsnapshot (StorageBox/CRYPT): snapshots/${SNAPSHOT_DATE}"
    rclone sync /data "StorageBox:snapshots/${SNAPSHOT_DATE}" \
      --fast-list \
      -v --log-file=/dev/stdout

    echo "🧹 Pruning von Snapshots älter als ${SNAPSHOT_KEEP_DAYS} Tage (StorageBox/snapshots)…"
    rclone delete "StorageBox:snapshots" \
      --min-age ${SNAPSHOT_KEEP_DAYS}d \
      --fast-list \
      -v --log-file=/dev/stdout || true
    rclone rmdirs "StorageBox:snapshots" \
      --fast-list \
      -v --log-file=/dev/stdout || true
  else
    echo "ℹ️ Vollsnapshot heute übersprungen (WEEKLY_SNAPSHOT=${WEEKLY_SNAPSHOT}, Wochentag=${DOW})."
  fi

  if setup_synology_remote; then
    if [ "$MAKE_SNAPSHOT" = "1" ]; then
      echo "🧊 Erzeuge Vollsnapshot (Synology): snapshots/${SNAPSHOT_DATE}"
      rclone sync /data "SYNOLOGY:${SYNOLOGY_PATH}/snapshots/${SNAPSHOT_DATE}" \
        --fast-list \
        -v --log-file=/dev/stdout

      echo "🧹 Pruning von Synology-Snapshots älter als ${SNAPSHOT_KEEP_DAYS} Tage …"
      rclone delete "SYNOLOGY:${SYNOLOGY_PATH}/snapshots" \
        --min-age ${SNAPSHOT_KEEP_DAYS}d \
        --fast-list \
        -v --log-file=/dev/stdout || true
      rclone rmdirs "SYNOLOGY:${SYNOLOGY_PATH}/snapshots" \
        --fast-list \
        -v --log-file=/dev/stdout || true
    fi
  fi

  echo "Backup fertig."
}

run_restore() {
  REQ_DATE="${1:-}"

  export PGPASSWORD=${PAPERLESS_DB_PASSWORD}

  if [ -n "${REQ_DATE}" ]; then
    SNAP_DIR="StorageBox:snapshots/${REQ_DATE}"
    if rclone lsd "${SNAP_DIR}" --fast-list >/dev/null 2>&1; then
      echo "🧊 Wiederherstellung aus Vollsnapshot ${REQ_DATE}..."
      rclone sync "${SNAP_DIR}" /data --fast-list -v --log-file=/dev/stdout
      echo "✅ Dateiwiederherstellung abgeschlossen (vollständiger Datumssnapshot)."

      echo "🔄 Beginne DB-Wiederherstellung..."

      if [ -f /data/dbdumps/nextcloud.sql ]; then
        echo "-> Spiele Nextcloud (MariaDB) Dump ein."
        mysql -h nextcloud_db -u${NEXTCLOUD_DB_USER} -p${NEXTCLOUD_DB_PASSWORD} ${NEXTCLOUD_DB} < /data/dbdumps/nextcloud.sql || echo "WARNUNG: Nextcloud DB-Restore fehlgeschlagen."
      else
        echo "ℹ️ Nextcloud-Dump nicht gefunden, überspringe DB-Restore."
      fi

      if [ "${PAPERLESS_USE_POSTGRES:-no}" = "yes" ] && [ -f /data/dbdumps/paperless.sql ]; then
        echo "-> Spiele Paperless (PostgreSQL) Dump ein."
        psql -h paperless_db -U paperless paperless < /data/dbdumps/paperless.sql || echo "WARNUNG: Paperless DB-Restore fehlgeschlagen."
      else
        echo "ℹ️ Paperless-PostgreSQL-Dump nicht gefunden oder SQLite verwendet, überspringe."
      fi

      echo "✅ DB-Wiederherstellung abgeschlossen."
      return 0
    else
      echo "⚠️ Vollsnapshot ${REQ_DATE} nicht gefunden. Fallback auf 'latest' + ggf. Tages-Archiv."
    fi
  fi

  echo "🚚 Synchronisiere 'latest' → /data (vollständiger aktueller Stand)..."
  rclone sync "StorageBox:latest" /data --fast-list -v --log-file=/dev/stdout

  if [ -n "${REQ_DATE}" ]; then
    SNAPSHOT_PATH="StorageBox:archive/${REQ_DATE}"
    if rclone lsd "${SNAPSHOT_PATH}" --fast-list >/dev/null 2>&1; then
      echo "↩️  Wende Änderungen aus archive/${REQ_DATE} zusätzlich an (Dateien überschreiben)..."
      rclone copy "${SNAPSHOT_PATH}" /data --fast-list -v --log-file=/dev/stdout || true
    else
      echo "ℹ️ Kein Tages-Archiv für ${REQ_DATE} gefunden – überspringe."
    fi
  fi

  echo "✅ Restore abgeschlossen."
}

if [ "$1" = "cron" ]; then
  exec crond -f -l 8
elif [ "$1" = "backup" ]; then
  run_backup
elif [ "$1" = "restore" ]; then
  run_restore "$2"
elif [ "$1" = "snapshots" ]; then
  echo "Liste Archiv-Ordner (StorageBox/CRYPT):"
  rclone lsd "StorageBox:archive" --fast-list || true
  echo "Liste Vollsnapshots (StorageBox/CRYPT):"
  rclone lsd "StorageBox:snapshots" --fast-list || true
  if setup_synology_remote; then
    echo "Liste Vollsnapshots (Synology):"
    rclone lsd "SYNOLOGY:${SYNOLOGY_PATH}/snapshots" --fast-list || true
  fi
else
  exec "$@"
fi
EOF
chmod +x "${BASE_DIR}/backup/entrypoint.sh"

# --- Unicode NBSP in allen erzeugten Dateien entfernen ---
find "${BASE_DIR}" -maxdepth 4 -type f -print0 | xargs -0 sed -i 's/\xC2\xA0/ /g'

# -------- 9) Stack starten ----------
say "🚀 Starte Stack …"
cd "${BASE_DIR}"

if docker compose up -d --help | grep -q -- "--wait"; then
  docker compose pull
  docker compose build backup
  docker compose up -d --wait || true
else
  docker compose pull
  docker compose build backup
  docker compose up -d
fi

# -------- 10) Retry-Healthcheck ----------
say "🩺 Überprüfe Containerstatus (mit Retry) …"

MAX_RETRIES=6
SLEEP_SECS=10
attempt=1

check_status() {
  FAILED_CONTAINERS=$(docker compose ps --status exited --format '{{.Name}}' || true)
  RESTARTING_CONTAINERS=$(docker compose ps --status restarting --format '{{.Name}}' || true)
}

check_status
while { [ -n "${FAILED_CONTAINERS}" ] || [ -n "${RESTARTING_CONTAINERS}" ]; } && [ ${attempt} -le ${MAX_RETRIES} ]; do
  warn "⏳ Versuch ${attempt}/${MAX_RETRIES} – warte ${SLEEP_SECS}s und prüfe erneut …"
  sleep "${SLEEP_SECS}"
  check_status
  attempt=$((attempt+1))
done

if [ -n "${FAILED_CONTAINERS}" ] || [ -n "${RESTARTING_CONTAINERS}" ]; then
  err "❌ Einige Container laufen nicht stabil:"
  [ -n "${FAILED_CONTAINERS}" ] && echo "  🔴 Gestoppt: ${FAILED_CONTAINERS}"
  [ -n "${RESTARTING_CONTAINERS}" ] && echo "  🟡 Neustartet: ${RESTARTING_CONTAINERS}"
  warn "→ Logs ansehen:  docker compose logs -f [CONTAINERNAME]"
else
  say "✅ Alle Container laufen stabil!"
fi

# -------- VISUELLE BACKUP/RESTORE-SKIZZE ----------
say "📊 Backup & Restore Überblick"
cat <<'EOF'
╔══════════════════════════════════════════════════════════════════════╗
║                          📦 BACKUP-ZEITLEISTE                        ║
╚══════════════════════════════════════════════════════════════════════╝

      Montag → Dienstag → Mittwoch → Donnerstag → Freitag → Samstag → Sonntag
        │          │          │           │           │           │
        ▼          ▼          ▼           ▼           ▼           ▼
  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
  │ Backup   │ │ Backup   │ │ Backup   │ │ Backup   │ │ Backup   │ │ Backup   │
  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘
       │          │          │           │           │           │
       ├── Sync → /latest  (vollständiger aktueller, VERSCHLÜSSELTER Stand)
       │
       ├── Änderungen → /archive/YYYY-MM-DD  (nur Deltas, VERSCHLÜSSELT)
       │
       └── Snapshot → /snapshots/YYYY-MM-DD  (Datum-Vollkopie, VERSCHLÜSSELT)

EOF

# -------- 11) Erstelle Wartungs-Skript (maintenance.sh) ----------
say "🔧 Erstelle Wartungs-Skript für einfache Handhabung…"

MAINT_FILE="${BASE_DIR}/maintenance.sh"
cat > "${MAINT_FILE}" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(dirname "$0")"
DC="${BASE_DIR}/docker-compose.yml"

say() { printf "\n\033[1;32m%s\033[0m\n" "$*"; }
warn() { printf "\n\033[1;33m%s\033[0m\n" "$*"; }
err()  { printf "\n\033[1;31m%s\033[0m\n" "$*"; }

if [ "$#" -eq 0 ]; then
    say "Verfügbare Befehle:"
    echo "  [1] backup               - Führt manuelles Sofort-Backup durch."
    echo "  [2] snapshots            - Listet verfügbare Archive & Vollsnapshots."
    echo "  [3] restore [YYYY-MM-DD] - Stoppt Container & stellt Snapshot/Archive wieder her."
    echo "  [4] stop                 - Stoppt alle Container."
    echo "  [5] start                - Startet alle Container."

    echo
    say "📊 Backup & Restore Überblick"
    cat <<'DIAGRAM'
╔══════════════════════════════════════════════════════════════════════╗
║                          📦 BACKUP-ZEITLEISTE                        ║
╚══════════════════════════════════════════════════════════════════════╝
      Montag → Dienstag → Mittwoch → Donnerstag → Freitag → Samstag → Sonntag
        │          │          │           │           │           │
        ▼          ▼          ▼           ▼           ▼           ▼
  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
  │ Backup   │ │ Backup   │ │ Backup   │ │ Backup   │ │ Backup   │ │ Backup   │
  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘
       │          │          │           │           │           │
       ├── Sync → /latest  (vollständiger aktueller, VERSCHLÜSSELTER Stand)
       │
       ├── Änderungen → /archive/YYYY-MM-DD  (nur Deltas, VERSCHLÜSSELT)
       │
       └── Snapshot → /snapshots/YYYY-MM-DD  (Datum-Vollkopie, VERSCHLÜSSELT)

DIAGRAM
    exit 0
fi

if [ ! -f "${DC}" ]; then
    err "Fehler: Die Datei ${DC} wurde nicht gefunden."
    exit 1
fi

case "$1" in
    backup)
        say "▶️ Führe manuelles Backup aus…"
        (cd "${BASE_DIR}" && docker compose run --rm backup backup)
        say "✅ Backup-Prozess abgeschlossen."
        ;;
    snapshots)
        say "▶️ Liste verfügbare Backups und Snapshots auf…"
        (cd "${BASE_DIR}" && docker compose run --rm backup snapshots)
        ;;
    restore)
        if [ -z "${2:-}" ]; then
            err "Fehler: Für den Restore-Befehl muss ein Datum im Format YYYY-MM-DD angegeben werden."
            exit 1
        fi
        RESTORE_DATE="$2"
        warn "⚠️ ALLE CONTAINER WERDEN GESTOPPT FÜR DEN RESTORE!"
        read -rp "Sicher, dass Sie den Stack stoppen und auf den Stand ${RESTORE_DATE} wiederherstellen wollen? Tippen Sie 'JA' zur Bestätigung: " CONFIRM_RESTORE
        if [[ "${CONFIRM_RESTORE}" != "JA" ]]; then
            warn "Restore abgebrochen."
            exit 0
        fi

        say "🛑 Stoppe Container…"
        (cd "${BASE_DIR}" && docker compose stop)

        say "🔄 Starte Wiederherstellung auf Stand ${RESTORE_DATE}…"
        (cd "${BASE_DIR}" && docker compose run --rm backup restore "${RESTORE_DATE}")

        say "🚀 Starte Container neu…"
        (cd "${BASE_DIR}" && docker compose up -d)
        say "✅ Wiederherstellung und Neustart abgeschlossen."
        warn "Hinweis: Bitte überprüfen Sie die Container-Logs, falls Probleme auftreten (docker compose logs)."
        ;;
    stop)
        say "🛑 Stoppe alle Container…"
        (cd "${BASE_DIR}" && docker compose stop)
        say "✅ Alle Container gestoppt."
        ;;
    start)
        say "🚀 Starte alle Container…"
        (cd "${BASE_DIR}" && docker compose up -d)
        say "✅ Alle Container gestartet."
        ;;
    *)
        err "Unbekannter Befehl: $1"
        exit 1
        ;;
esac
EOF
chmod +x "${MAINT_FILE}"

# -------- 12) Abschließende Hinweise ----------
say "🎉 Setup abgeschlossen!"
echo ""
echo "--- Zugangsdaten ---"
echo "🌐 Traefik Dashboard: https://${TRAEFIK_HOST} (BasicAuth: ${TFA_USER}/Ihr-Passwort)"
echo "☁️ Nextcloud: https://${NEXTCLOUD_HOST} (Erste Anmeldung über Web)"
echo "📄 Paperless: https://${PAPERLESS_HOST} (User: ${PAPERLESS_ADMIN}, Passwort: ${PAPERLESS_ADMIN_PASS})"
echo "⚙️ n8n: https://${N8N_HOST} (BasicAuth: ${N8N_USER}/${N8N_PASS})"
echo "  💡 N8N Encryption Key: ${N8N_KEY} (BITTE SICHERN!)"
echo ""
echo "🔑 SFTP Scanner (Zum Hochladen nach Paperless):"
echo "  Host: [IHRE IP/DOMAIN]"
echo "  Port: 2222"
echo "  User: ${SFTP_USER}"
echo "  Pass: ${SFTP_PASS}"
echo ""
echo "💾 Backup-Container Secrets:"
echo "  StorageBox SFTP User: ${SB_USER}"
echo "  StorageBox Pfad (auf SB): ${SB_PATH}"
echo "  Rclone Crypt-Passwort: ${SB_CRYPT_PASS} (BITTE SICHERN!)"
echo "---"
echo ""
say "Nächste Schritte:"
echo "* Führen Sie ${BASE_DIR}/maintenance.sh aus, um Backups zu verwalten."
echo "* Überprüfen Sie die Logs bei Problemen: docker compose logs"
