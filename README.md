🌌 UNIVERSAL SELFHOSTED STACK
Nextcloud • Paperless-ngx • Traefik v3 • n8n • OnlyOffice • Zero-Knowledge Backups • SFTP-Scanner
<div align="center"> <img src="https://img.shields.io/badge/Status-Stable-00e5ff?style=for-the-badge&logo=hackthebox&logoColor=00e5ff" /> <img src="https://img.shields.io/badge/Docker-Ready-0aff9d?style=for-the-badge&logo=docker&logoColor=0aff9d" /> <img src="https://img.shields.io/badge/Traefik-v3-00e5ff?style=for-the-badge&logo=traefikproxy&logoColor=00e5ff" /> <img src="https://img.shields.io/badge/N8N-Automation-0aff9d?style=for-the-badge&logo=n8n&logoColor=0aff9d" /> <img src="https://img.shields.io/badge/Backups-Encrypted-00e5ff?style=for-the-badge&logo=protonvpn&logoColor=00e5ff" /> </div>
🧬 Überblick

Ein kompletter Dark-Mode Homelab-Stack, der sich in 1 Command selbst installiert:
Reverse Proxy, SSL, Cloud, Dokumentenmanagement, Office, Workflows, OCR, PDF-Engine, Backups, Zero-Knowledge Encryption — alles automatisch.

Keine manuelle Konfiguration. Keine YAML-Hölle. Keine Passworteingaben.

🔥 Features
🧩 Core Services
Service	Beschreibung
Traefik v3	TLS, Routing, Dashboard (bcrypt geschützt)
Nextcloud 31	Private Cloud, Files, Kalender
Paperless-ngx	Dokumentenmanagement + OCR
OnlyOffice	Online Office Suite
n8n	Automationen & Workflows
Redis	Cache für NC + Paperless
Tika / Gotenberg	OCR + PDF Rendering
SFTP-Scanner	Scanner-Upload → Paperless „consume“
