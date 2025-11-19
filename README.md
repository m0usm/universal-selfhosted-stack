# 🚀 universial-stack-init

**Production-ready Bash installer that deploys a complete Traefik + Nextcloud + Paperless + n8n stack with healthchecks, SFTP, backups & secure defaults.**

---

## 🧩 Overview
`universial-stack-init` ist ein All‑in‑One Bootstrap‑Skript, das einen vollständigen Self‑Hosted‑Stack automatisiert bereitstellt:

- Traefik v3 (TLS, DNS, Dashboard, Middlewares)
- Nextcloud 29 + MariaDB 11
- Paperless‑ngx (OCR + Tika + Gotenberg)
- n8n Automation Server
- OnlyOffice Document Server
- SFTP‑Scanner (Uploads direkt in Paperless)
- Verschlüsseltes Backup-System (Hetzner + optional Synology)
- Healthchecks, Retry‑Loop & sichere Defaults

Alles in **einem einzigen Bash‑Script**.

---

## ⚡ Features

### 🔐 Traefik v3 + Security
- Vollautomatisches HTTPS (Let’s Encrypt)
- acme.json mit `600` Rechten
- Bcrypt‑geschütztes Dashboard
- Rate‑Limit Middleware

### ☁️ Nextcloud
- Nextcloud 29
- MariaDB 11
- Optimierte PHP‑Settings
- Fully Traefik‑integrated

### 📄 Paperless‑ngx
- OCR via Apache Tika
- PDF‑Konvertierung via Gotenberg
- Redis Queue
- Optional PostgreSQL statt SQLite

### 🤖 n8n Automation
- Encryption Key wird generiert
- Editor- & Webhook‑URLs automatisch korrekt gesetzt
- Persistente Daten

### 🔌 SFTP‑Scanner
- Scanner‑Benutzer wird automatisch angelegt
- Direkt in den Paperless‑Consume‑Ordner
- Upload / Done / Fail‑Ordner

### 📦 Backup System
- Rclone → Hetzner Storage Box (SFTP Port 23)
- Voll verschlüsselt (rclone crypt)
- `latest/`, `archive/`, `snapshots/`
- Optional: Synology Mirror
- Automatische Cron‑Jobs

---

## 🛠 Installation

### 1. Skript herunterladen
```bash
curl -fsSL https://example.com/universial-stack-init.sh -o init.sh
chmod +x init.sh
```

### 2. Ausführen
```bash
sudo ./init.sh
```

### 3. Dienste nach erfolgreicher Installation
| Dienst       | URL-Beispiel                     |
|--------------|----------------------------------|
| Traefik      | https://traefik.example.com      |
| Nextcloud    | https://cloud.example.com        |
| Paperless    | https://paperless.example.com    |
| n8n          | https://n8n.example.com          |
| OnlyOffice   | https://office.example.com       |


---

## 🎬 Demo (Ablaufübersicht)

Der Ablauf der Installation sieht typischerweise so aus:

1. Eingaben erfassen (Domain, Mail, Optionen)
2. Struktur anlegen (`/opt/stack/...`)
3. `.env` generieren
4. `docker-compose.yml` erzeugen
5. Images ziehen + Build
6. Stack starten
7. Healthchecks & Retry‑Loop
8. Ausgabe aller Endpunkte
9. Backup‑Plan aktivieren

*(GIF/Video kannst du hier später einfügen)*

---

## 🗂 Verzeichnisstruktur (Server)
```
/opt/stack
├─ traefik/
├─ nextcloud/
├─ paperless/
├─ n8n/
├─ onlyoffice/
├─ backup/
└─ .env
```

---

## 🔄 Wartung

### Wartungsskript
```bash
./maintenance.sh
```

### Beispiele
```bash
./maintenance.sh backup       # Sofort-Backup
./maintenance.sh restore      # Restore latest
./maintenance.sh restore 2025-11-16  # Snapshot
```

---

## 🧩 Backup-Konzept

### Storage Box Struktur
```
StorageBox:
├─ latest/
├─ archive/
│   ├─ 2025-11-10/
│   ├─ 2025-11-11/
│   └─ ...
└─ snapshots/
    ├─ 2025-11-16/
    ├─ 2025-11-23/
    └─ ...
```

---

## ❓ FAQ

### **Kostet das etwas?**
Nein. Das Script ist für deinen eigenen Server gedacht.

### **Welche OS werden unterstützt?**
- Debian
- Ubuntu

### **Kann ich OnlyOffice direkt nutzen?**
Ja → einfach in Nextcloud unter *Admin → OnlyOffice* die URL eintragen.

### **Paperless ohne Postgres?**
Ja, Standard ist SQLite.

---

## 🧾 License
MIT License © 2025 m0usm

---

## 👤 Maintainer
**m0usm** – Selfhoster, DevOps & Automation

Wenn dir das Projekt gefällt: ⭐ Star nicht vergessen!
