# Changelog — Plik File Sharing

Všetky významné zmeny v projekte budú dokumentované v tomto súbore.

Formát založený na [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
a tento projekt dodržiava [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Plánované
- GitHub Actions CI/CD workflow
- Backup automation
- Rate limiting pre uploads
- Admin dashboard (voliteľné)

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
