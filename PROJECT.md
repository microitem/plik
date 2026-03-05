# Plik File Sharing — PROJECT.md (Single Source of Truth)

> **⚠️ POVINNÉ PRE AI AGENTA:**  
> Pri práci s projektom **MUSÍŠ PRÍSNE DODRŽIAVAŤ** všetky pravidlá správania z [.github/COPILOT-INSTRUCTIONS.md](../../.github/COPILOT-INSTRUCTIONS.md) + SSoT princípy.

**Vytvorené:** 2026-03-05 | **Stav:** Fáza 3 - Tech Design

---

## 📍 AKTUÁLNY STAV

| Položka            | Hodnota                                           |
| ------------------ | ------------------------------------------------- |
| **Fáza**           | Fáza 3 - Tech Design                              |
| **Krok**           | 3.1 - Projektová štruktúra vytvorená              |
| **Posledná zmena** | 2026-03-05                                        |
| **Nasleduje**      | Docker Compose konfigurácia + testovanie na VPS2  |
| **Blocker**        | Žiadny                                            |
| **Finálny názov**  | plik                                              |

---

## 0. Metadáta projektu

| Položka         | Hodnota                                             |
| --------------- | --------------------------------------------------- |
| **Názov**       | Plik File Sharing Platform                          |
| **Doména**      | https://files.goodboog.com                          |
| **Typ**         | File Sharing Service (Go-based)                     |
| **Účel**        | Bezpečné zdieľanie súborov s dočasným TTL           |
| **Status**      | 🔄 V príprave                                       |
| **Repo**        | /opt/projects/plik                                  |
| **Autor**       | goodboog.com                                        |
| **Upstream**    | https://github.com/root-gg/plik                     |

---

## 1. Popis projektu

### 1.1 Čo projekt robí

Plik je open-source file sharing server, ktorý umožňuje:

- **Nahrávanie súborov** cez webové UI alebo CLI
- **Bezpečné URL linky** s MD5 hash kódmi
- **Automatické vymazanie** po nastavenom TTL (1h, 1d, 1w, 30d)
- **Jednoduchú správu** – zero-config setup
- **CLI support** – upload cez terminál (`plik-client`)

### 1.2 Hlavné funkcie

**Core funkcie:**
- Upload súborov (drag & drop alebo file picker)
- Generovanie bezpečných shareable linkov
- Automatická expirácia súborov (TTL)
- Health check endpoint
- Voliteľné password protection
- QR code generation pre linky

**Technické vlastnosti:**
- In-memory alebo disk-based storage
- Konfigurovateľné limity (max file size, upload count)
- TLS/HTTPS ready
- Minimálne dependencies (Go binary + static files)

### 1.3 Technológie

- **Backend:** Go (upstream: rootgg/plik)
- **Frontend:** HTML/JS/CSS (statické súbory)
- **Storage:** Local filesystem
- **Container:** Docker + docker-compose
- **Reverse proxy:** Nginx Proxy Manager (VPS1)

---

## 2. Architektúra

### 2.1 Komponenty

```
┌─────────────────────────────────────────────────────────┐
│                 files.goodboog.com                      │
│               (Nginx Proxy Manager)                     │
└────────────────────┬────────────────────────────────────┘
                     │ HTTPS
                     │
┌────────────────────▼────────────────────────────────────┐
│               plik-server container                     │
│                    (Go + HTTP server)                   │
│                                                          │
│  Endpoints:                                             │
│    GET  /                  → Upload UI                  │
│    GET  /health            → Health check               │
│    POST /upload            → Upload súbor               │
│    GET  /?code=abc123      → Download súbor             │
│                                                          │
│  Volumes:                                               │
│    /plik/data              → File storage (persistent)  │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### 2.2 Data Flow

1. **Upload:**
   - User nahrá súbor cez UI
   - Plik uloží súbor na disk (`/plik/data`)
   - Vygeneruje bezpečný link s MD5 kódom
   - Nastaví TTL pre automatické vymazanie

2. **Download:**
   - User otvorí link (`?code=abc123`)
   - Plik nájde súbor v storage
   - Streamuje súbor k userovi
   - Po expirácii automaticky vymaže súbor

---

## 3. Konfigurácia

### 3.1 Environment Variables

| Premenná                  | Default       | Popis                                |
| ------------------------- | ------------- | ------------------------------------ |
| `PLIK_SERVER_LISTENADDR`  | 0.0.0.0:8080  | Bind address                         |
| `PLIK_MAX_FILE_SIZE`      | 10240         | Max veľkosť súboru (MB)              |
| `PLIK_MAX_TTL`            | 2592000       | Max TTL (sekundy, default 30 dní)    |
| `PLIK_DATA_DIR`           | /plik/data    | Storage directory                    |

### 3.2 Porty

| Environm. | Port | Účel                     |
| --------- | ---- | ------------------------ |
| Dev (VPS2)| 8080 | HTTP server (localhost)  |
| Prod (VPS1)| 8080| HTTP server (za NPM)     |

---

## 4. Deployment

### 4.1 VPS2 (Development)

**URL:** http://localhost:8085  
**Účel:** Testovanie, vývoj, validácia

**Stack:**
- Docker Compose (development variant)
- Port 8080
- Local storage volume

### 4.2 VPS1 (Production)

**URL:** https://files.goodboog.com  
**Účel:** Produkčné nasadenie

**Stack:**
- Docker Compose (production variant)
- GitHub Actions CI/CD
- GHCR image registry
- Nginx Proxy Manager (reverse proxy)
- Let's Encrypt SSL (via NPM)

---

## 5. Testing

### 5.1 Health Checks

**Development:**
```bash
curl http://localhost:8080
```

**Production:**
```bash
curl https://files.goodboog.com/health
```

### 5.2 Funkčné testy

1. Otvor UI v prehliadači
2. Nahraj testovací súbor (napr. `test.txt`)
3. Skontroluj vygenerovaný link
4. Stiahni súbor cez link
5. Over TTL expiráciu (po nastavenom čase)

---

## 6. Security

### 6.1 Bezpečnostné mechanizmy

- ✅ MD5 hash kódy (unguessable links)
- ✅ Automatické vymazanie (TTL)
- ✅ Konfigurovateľné limity (max file size)
- ✅ Voliteľné password protection
- ✅ HTTPS (produkcia)
- ✅ Docker security best practices
- ✅ No-new-privileges security option

### 6.2 Doporučené nastavenia

- Max file size: **100 MB** (adjustable)
- Max TTL: **30 dní** (adjustable)
- Max uploads per IP: **10/day** (optional rate limiting)

---

## 7. Monitoring

### 7.1 Docker Health Checks

```yaml
healthcheck:
  test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:8080"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 20s
```

### 7.2 Metriky

- Container status: `docker compose ps`
- Logs: `docker compose logs -f plik-server`
- Disk usage: `du -sh /var/lib/docker/volumes/plik_data`

---

## 8. Backup & Recovery

### 8.1 Čo zálohovať

- ✅ `/plik/data` volume (uploaded files)
- ✅ Docker Compose konfiguráciu
- ✅ Environment variables (.env.production)

### 8.2 Recovery postup

1. Restore Docker volume backup
2. Deploy container cez GitHub Actions
3. Verify health checks
4. Test upload/download funkčnosť

---

## 9. Roadmap

- [x] Fáza 1: Analýza nápadu
- [x] Fáza 2: Vyhodnotenie (Plik vs alternatívy)
- [x] Fáza 3: Tech design + projektová štruktúra
- [ ] Fáza 4: Implementácia na VPS2
- [ ] Fáza 5: Testovanie + validácia
- [ ] Fáza 6: Production deployment na VPS1
- [ ] Fáza 7: Monitoring + dokumentácia

---

## 10. Súvisiace dokumenty

- [DEPLOYMENT.md](DEPLOYMENT.md) - Deployment príručka
- [CHANGELOG.md](CHANGELOG.md) - História zmien
- [README.md](README.md) - Quick start guide
- [.github/DEPLOYMENT-PROCESS.md](../../.github/workflows/DEPLOYMENT-PROCESS.md) - SSoT deployment proces

---

**Version:** 0.1.0 | **Date:** 2026-03-05
