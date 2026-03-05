# Plik File Sharing — Quick Start

**Projekt:** Plik File Sharing Platform  
**Účel:** Bezpečné zdieľanie súborov s automatickou expiráciou  
**URL (Production):** https://files.goodboog.com  
**SSOT:** [PROJECT.md](PROJECT.md)

---

## 🚀 Quick Start (VPS2 Development)

### 1. Vytvor .env súbor

```bash
cd /opt/projects/plik
cp .env.example .env.development
```

### 2. Build a spusti

```bash
docker compose build --no-cache
docker compose up -d
```

### 3. Over funkčnosť

```bash
# Health check
curl http://localhost:8085

# Otvor UI v prehliadači
# http://localhost:8085
```

### 4. Test upload

1. Otvor `http://localhost:8085` v prehliadači
2. Nahraj testovací súbor (napr. `test.txt`)
3. Skontroluj vygenerovaný shareable link
4. Stiahni súbor cez link
5. Over automatické vymazanie po TTL

---

## 📋 Deployment na VPS1 (Production)

**Prerekvizity:**
- ✅ DNS A-record: `files.goodboog.com` → IP VPS1
- ✅ NPM Proxy Host nakonfigurovaný
- ✅ SSL certifikát (Let's Encrypt via NPM)
- ✅ Docker network `docker_web` existuje

**Postup:**
1. Otestuj na VPS2 (výše)
2. Spusti `.github/scripts/pre-action-validator.sh --critical`
3. Commit + tag:
   ```bash
   git add .
   git commit -m "feat: Plik deployment v0.1.0"
   git tag -a v0.1.0 -m "Release v0.1.0"
   ```
4. **CEO GATE #1:** Čakaj na approval
5. Push: `git push origin main && git push origin v0.1.0`
6. GitHub Actions automaticky deployne na VPS1

**Verifikácia:**
```bash
curl https://files.goodboog.com
```

---

## 🧪 Testing Commands

```bash
# Container status
docker compose ps

# Logs
docker compose logs -f plik-server

# Health check
curl -f http://localhost:8080 || echo "Failed"

# Stop
docker compose down

# Clean restart
docker compose down && docker compose build --no-cache && docker compose up -d
```

---

## 📖 Dokumentácia

- [PROJECT.md](PROJECT.md) - Single Source of Truth
- [DEPLOYMENT.md](DEPLOYMENT.md) - Deployment príručka
- [CHANGELOG.md](CHANGELOG.md) - História zmien

---

## 🔒 Security Features

- ✅ MD5 hash kódy (bezpečné linky)
- ✅ Automatická expirácia (TTL)
- ✅ Konfigurovateľné limity (max file size: 100 MB)
- ✅ HTTPS (produkcia)
- ✅ Docker security hardening
- ✅ Optional password protection

---

## 🐛 Troubleshooting

**Problém:** Container nie je healthy  
**Riešenie:** `docker compose logs plik-server`

**Problém:** Port 8080 je obsadený  
**Riešenie:** Plik používa port 8085 na VPS2 (development)

**Problém:** NPM 502 Bad Gateway  
**Riešenie:** Over či container beží + skontroluj NPM Forward Host

**Problém:** Súbory sa nevymazávajú automaticky  
**Riešenie:** Over `PLIK_MAX_TTL` v .env súbore

---

**Version:** 0.1.0 | **Date:** 2026-03-05
