# Changelog — Plik File Sharing

Všetky významné zmeny v projekte budú dokumentované v tomto súbore.

Formát založený na [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
a tento projekt dodržiava [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Plánované
- Backup automation
- Rate limiting pre uploads

---

## [0.2.0] - 2026-03-05

### Added
- 🎨 GoodBoog branding: favicon, navbar logo, custom page title
  - `branding/favicon.svg` + `favicon.ico` — goodboog "g" ikona (modrá #1d63b7)
  - `branding/logo.svg` — navbar logo "files by goodboog"
  - `branding/index.html` — titul "GoodBoog Files" + JS injekcia loga do navbaru
- 📦 Docker volume mounty pre branding adresár (dev + production)
- 🔄 GitHub Actions workflow update: SCP kopíruje aj `branding/`

---

## [0.1.0] - 2026-03-05

### Added
- ✨ Prvotná implementácia Plik file sharing servera
- 📝 Projektová dokumentácia (PROJECT.md, DEPLOYMENT.md)
- 🐳 Docker Compose konfigurácia (dev + production)
- 🔒 Bezpečnostné nastavenia (no-new-privileges, health checks)
- 📦 Environment variables setup (.env.example)
- 🌐 Nginx Proxy Manager konfigurácia pre files.goodboog.com
- 🧪 Health check endpoints
- 📊 Resource limits (512M RAM, 0.5 CPU)

### Configuration
- Max file size: 100 MB
- Max TTL: 30 dní
- Storage: /plik/data (persistent volume)
- Port: 8080

### Deployment
- Development: VPS2 (http://localhost:8080)
- Production: VPS1 (https://files.goodboog.com)

---

**SSOT:** Git tags sú jediný zdroj pravdy pre verziovanie
