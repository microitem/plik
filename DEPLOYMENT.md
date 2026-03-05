# Plik File Sharing - Deployment Príručka

**Aktualizované:** 2026-03-05  
**Verzia:** v0.1.0  
**Status:** 🔄 V príprave

---

## 📋 Prehľad

**VPS2 (Development):** http://localhost:8085  
**VPS1 (Production):** https://files.goodboog.com

---

## ⚙️ Príprava VPS1 (Production)

### 1. Nginx Proxy Manager konfigurácia

**Krok 1:** Prihlás sa do NPM (`https://npm.goodboog.com` alebo IP:81)

**Krok 2:** Vytvor nový Proxy Host
- Klikni: **Proxy Hosts** → **Add Proxy Host**
- Vyplň polia:

| Pole                   | Hodnota                              |
| ---------------------- | ------------------------------------ |
| **Domain Names**       | files.goodboog.com                   |
| **Scheme**             | http                                 |
| **Forward Hostname/IP**| plik-server (alebo localhost)        |
| **Forward Port**       | 8080                                 |
| **Cache Assets**       | ☑ (zaškrtni)                         |
| **Block Common Exploits**| ☑ (zaškrtni)                       |
| **Websockets Support** | ☐ (nechaj prázdne)                   |

**Krok 3:** Nastav SSL certifikát
- Prejdi na tab **SSL**
- SSL Certificate: **Request a new SSL Certificate**
- ☑ Force SSL
- ☑ HTTP/2 Support
- ☑ HSTS Enabled
- Email: **tvoj-email@domain.com**
- ☑ I Agree to the Let's Encrypt Terms of Service
- Klikni **Save**

**Výsledok:**  
✅ NPM získa Let's Encrypt certifikát automaticky  
✅ files.goodboog.com → HTTPS ready

---

## 🚀 Deployment Metódy

### Metóda 1: GitHub Actions CI/CD (Odporúčané)

**Predpoklady:**
- ✅ GitHub repo vytvorené
- ✅ GitHub Secrets nakonfigurované (VPS1_HOST, VPS1_PORT, VPS1_USER, VPS1_SSH_KEY)
- ✅ Docker network `docker_web` existuje na VPS1

**Deployment trigger:**
```bash
# Na VPS2 (po úspešnom testovaní):
git add .
git commit -m "feat: initial Plik deployment"
git tag -a v0.1.0 -m "Release v0.1.0"
git push origin main
git push origin v0.1.0
```

**Čo sa deje:**
1. GitHub Actions detekuje push tagu
2. Vybuduje Docker image (fresh build, no cache)
3. Pushne image do GHCR (ghcr.io/[user]/plik)
4. SSH na VPS1 a spustí `docker compose pull && docker compose up -d`
5. Verify health checks

---

### Metóda 2: Manuálny deployment (Fallback)

**Na VPS2:**
```bash
# 1. Build lokálne
cd /opt/projects/plik
docker compose -f docker-compose.production.yml build --no-cache

# 2. Tag image
docker tag plik-server:latest ghcr.io/[user]/plik:v0.1.0

# 3. Push do GHCR
docker push ghcr.io/[user]/plik:v0.1.0

# 4. Deploy na VPS1 cez SSH
ssh -p [VPS1_PORT] root@[VPS1_IP] 'cd /opt/plik && docker compose pull && docker compose up -d'
```

---

## 🧪 Testing

### Pre-deployment testy (VPS2)

```bash
# 1. Build a spusti container
cd /opt/projects/plik
docker compose build --no-cache
docker compose up -d

# 2. Počkaj na startup (20s)
sleep 20

# 3. Health check
curl -f http://localhost:8085 || echo "❌ Health check failed"

# 4. Test UI
# Otvor v prehliadači: http://localhost:8085

# 5. Test upload
# Nahraj testovací súbor cez UI
# Skontroluj vygenerovaný link
# Stiahni súbor cez link

# 6. Skontroluj logy
docker compose logs -f plik-server
```

**Expected output:**
```
✅ HTTP 200 OK
✅ UI sa načíta
✅ Upload funguje
✅ Download funguje
✅ Žiadne errors v logoch
```

---

### Post-deployment testy (VPS1)

```bash
# 1. SSH na VPS1
ssh -p [VPS1_PORT] root@[VPS1_IP]

# 2. Skontroluj container status
cd /opt/plik
docker compose ps

# Expected output:
# NAME         STATUS            PORTS
# plik-server  Up (healthy)      0.0.0.0:8080->8080/tcp

# 3. Internal health check
curl -f http://localhost:8080 || echo "❌ Failed"

# 4. External HTTPS test (z VPS2 alebo lokálne)
curl -f https://files.goodboog.com || echo "❌ Failed"

# 5. Test upload cez UI
# Otvor: https://files.goodboog.com
# Nahraj súbor
# Over shareable link

# 6. Logy
docker compose logs -f plik-server | head -50
```

---

## 🛠 Configuration Files (VPS1)

### Adresárová štruktúra

```
/opt/plik/
├── docker-compose.yml             # Production config (symlink alebo kópia)
├── .env.production                # Production environment
└── data/                          # Persistent storage (Docker volume)
```

### docker-compose.yml (Production)

Kópiu deployment súboru nájdeš v git repo:
```bash
cd /opt/plik
# Git pull alebo manuálne skopíruj docker-compose.production.yml → docker-compose.yml
```

### .env.production

```bash
# Plik Configuration
PLIK_SERVER_LISTENADDR=0.0.0.0:8080
PLIK_MAX_FILE_SIZE=102400          # 100 MB
PLIK_MAX_TTL=2592000               # 30 dní
PLIK_DATA_DIR=/plik/data
PUBLIC_URL=https://files.goodboog.com
```

---

## 🐛 Troubleshooting

### Problém: Container nie je healthy

**Diagnostika:**
```bash
docker compose ps          # Skontroluj status
docker compose logs        # Skontroluj logy
docker inspect plik-server # Detaily containera
```

**Riešenie:**
1. Over či port 8080 nie je obsadený: `netstat -tulpn | grep 8080`
2. Skontroluj health check command v docker-compose.yml
3. Reštartuj container: `docker compose restart`

---

### Problém: NPM nefunguje (502 Bad Gateway)

**Diagnostika:**
```bash
# Na VPS1:
curl http://localhost:8080   # Over či Plik beží

# V NPM:
# Skontroluj Proxy Host settings (Forward Host = plik-server alebo localhost)
```

**Riešenie:**
1. Over že container je v sieti `docker_web`: `docker network inspect docker_web`
2. Ak nie, pridaj do docker-compose.yml:
   ```yaml
   networks:
     - docker_web
   networks:
     docker_web:
       external: true
   ```

---

### Problém: SSL certifikát zlyhá

**Diagnostika:**
```bash
# Over DNS A-record:
dig files.goodboog.com +short

# Expected: IP adresa VPS1
```

**Riešenie:**
1. Počkaj 5-10 minút na DNS propagáciu
2. Retry SSL certificate request v NPM
3. Skontroluj firewall (port 80/443 musia byť otvorené)

---

## 📦 GitHub Secrets Setup

```bash
# Na VPS2 alebo lokálne:
gh secret set VPS1_HOST --body "84.247.160.146"
gh secret set VPS1_PORT --body "54869"
gh secret set VPS1_USER --body "root"
gh secret set VPS1_SSH_KEY < ~/.ssh/id_rsa_vps1

# Verifikácia:
gh secret list
```

---

## 📊 Monitoring

### Health Checks

**Internal (VPS1):**
```bash
watch -n 5 'docker compose ps && curl -s http://localhost:8080 | head -1'
```

**External (anywhere):**
```bash
watch -n 5 'curl -s -o /dev/null -w "%{http_code}" https://files.goodboog.com'
```

### Disk Usage

```bash
# Na VPS1:
du -sh /var/lib/docker/volumes/plik_data/_data
```

**Alert threshold:** 80% disk usage → logy alebo clean up starých súborov

---

## 🔄 Rollback Postup

Ak deployment zlyhá:

```bash
# Na VPS1:
cd /opt/plik

# 1. Zastaviť aktuálnu verziu
docker compose down

# 2. Vrátiť sa na predchádzajúci image
docker compose pull ghcr.io/[user]/plik:v0.0.9  # Predchádzajúca verzia
docker tag ghcr.io/[user]/plik:v0.0.9 plik-server:latest

# 3. Reštart
docker compose up -d

# 4. Verify
curl -f https://files.goodboog.com
```

---

## 📝 Pre-Push Checklist

Pred `git push` vykonaj:

```bash
cd /opt/projects/plik

# 1. Syntax validation
docker compose -f docker-compose.yml config

# 2. Build test
docker compose build --no-cache

# 3. Startup test
docker compose up -d && sleep 20

# 4. Health check
curl -f http://localhost:8085

# 5. Funkčný test (upload + download)
# Manuálne v prehliadači

# 6. Cleanup
docker compose down
```

**Všetko ✅?** → Pokračuj s git push + tag

---

**Version:** 0.1.0 | **Date:** 2026-03-05
