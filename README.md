# Ibiza Mi Vida CMS — Deployment Guide

Complete setup: GitHub → Docker → VPS server, with automatic deploys when you push code or update content in Supabase.

---

## Architecture

```
You push to GitHub main
        ↓
GitHub Actions validates + builds Docker image
        ↓
Image pushed to Docker Hub
        ↓
GitHub Actions SSHs into VPS → pulls new image → restarts container
        ↓
CMS live at cms.ibizamivida.com

Supabase content change (new event, club, etc.)
        ↓
Supabase webhook → triggers GitHub Actions
        ↓
Same deploy pipeline above
```

---

## Step 1 — Prepare your GitHub repo

```bash
# Clone the repo (or push your files to it)
git clone https://github.com/viesatomenjoep-ops/Ibiza-mi-vida-cms.git
cd Ibiza-mi-vida-cms

# Copy all these files into the repo root
cp /path/to/ibiza-cms.html .
cp /path/to/Dockerfile .
cp /path/to/docker-compose.yml .
cp /path/to/nginx.conf .
cp /path/to/.env.template .
cp /path/to/.gitignore .
mkdir -p .github/workflows
cp /path/to/.github/workflows/deploy.yml .github/workflows/
cp /path/to/.github/workflows/supabase-webhook.yml .github/workflows/

git add .
git commit -m "Add Docker + CI/CD setup"
git push origin main
```

---

## Step 2 — Create a Docker Hub account & access token

1. Go to **hub.docker.com** → sign up or log in
2. Account Settings → **Security** → New Access Token
3. Name it `ibiza-cms-deploy`, permissions: **Read & Write**
4. Copy the token — you only see it once

---

## Step 3 — Add GitHub Secrets

Go to your repo → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Add these secrets one by one:

| Secret name | Value |
|---|---|
| `DOCKER_HUB_USERNAME` | Your Docker Hub username |
| `DOCKER_HUB_TOKEN` | The token from Step 2 |
| `SERVER_HOST` | IP address of your VPS (e.g. `123.45.67.89`) |
| `SERVER_USER` | SSH user on your VPS (usually `root` or `ubuntu`) |
| `SERVER_SSH_KEY` | Your private SSH key (paste the full contents of `~/.ssh/id_rsa`) |
| `SERVER_PORT` | SSH port (default: `22`) |

---

## Step 4 — Set up your VPS

You need a VPS with Ubuntu 22.04+. Any provider works: Hetzner (cheapest), DigitalOcean, Vultr, Contabo.

**Minimum specs:** 1 vCPU, 1GB RAM, 10GB SSD — the CMS is a single HTML file served by nginx.

```bash
# SSH into your server
ssh root@YOUR_SERVER_IP

# Download and run the setup script
curl -O https://raw.githubusercontent.com/viesatomenjoep-ops/Ibiza-mi-vida-cms/main/server-setup.sh
bash server-setup.sh
```

The script installs Docker, configures the firewall, and creates a systemd service.

```bash
# Create the app directory and copy files
mkdir -p /opt/ibiza-cms
cd /opt/ibiza-cms

# Copy .env.template and fill it in
cp .env.template .env
nano .env   # fill in all your keys
```

---

## Step 5 — First deploy

```bash
# On your server
cd /opt/ibiza-cms
docker compose --profile prod up -d

# Check it's running
docker ps
docker logs ibiza-cms

# Visit: http://YOUR_SERVER_IP:3000
```

---

## Step 6 — Point your domain (optional but recommended)

In your domain registrar (e.g. Namecheap, Cloudflare):

```
A record:   cms.ibizamivida.com  →  YOUR_SERVER_IP
A record:   ibizamivida.com      →  YOUR_SERVER_IP
A record:   ibizamivida.es       →  YOUR_SERVER_IP
```

Then add SSL:
```bash
# On your server
certbot certonly --standalone -d cms.ibizamivida.com
```

---

## Step 7 — Connect Supabase webhook (auto-deploy on content change)

1. Supabase Dashboard → **Database** → **Webhooks** → **Create a new hook**
2. Name: `cms-deploy`
3. Table: `featured_events` (and repeat for other tables you want to trigger on)
4. Events: `INSERT`, `UPDATE`, `DELETE`
5. URL:
```
https://api.github.com/repos/viesatomenjoep-ops/Ibiza-mi-vida-cms/dispatches
```
6. Method: `POST`
7. Headers:
```
Authorization: Bearer YOUR_GITHUB_PERSONAL_ACCESS_TOKEN
Content-Type: application/json
Accept: application/vnd.github.v3+json
```
8. Body:
```json
{"event_type": "supabase-content-update"}
```

Now whenever you add or edit an event in the CMS → Supabase fires the webhook → GitHub Actions deploys automatically.

---

## Day-to-day workflow

```
Edit content in CMS  →  saved to Supabase  →  auto deploy  (2–3 min)
Push code changes    →  git push origin main  →  auto deploy  (3–4 min)
Manual deploy        →  GitHub → Actions → "Deploy" → Run workflow
```

---

## Useful commands on the server

```bash
# View running containers
docker ps

# View CMS logs
docker logs ibiza-cms -f

# Restart CMS
docker compose restart cms

# Pull latest image manually
docker compose pull cms && docker compose up -d cms

# Check nginx config
docker exec ibiza-cms nginx -t

# Check disk usage
docker system df
```

---

## Local development

```bash
# Clone repo
git clone https://github.com/viesatomenjoep-ops/Ibiza-mi-vida-cms.git
cd Ibiza-mi-vida-cms

# Copy and fill in env
cp .env.template .env

# Start CMS + local Postgres
docker compose --profile dev up

# CMS available at http://localhost:3000
```

---

## Troubleshooting

**Loading screen won't go away** → The CMS now falls back to demo mode after 2 seconds. If it still hangs, open browser DevTools → Console and check for errors.

**Docker image won't build** → Check that `ibiza-cms.html` is in the repo root.

**SSH deploy fails** → Make sure `SERVER_SSH_KEY` contains the full private key including `-----BEGIN...-----` headers.

**Supabase webhook not triggering** → Check the webhook logs in Supabase Dashboard → Database → Webhooks → View logs.

**Container keeps restarting** → Run `docker logs ibiza-cms` to see the error.

---

## File structure

```
Ibiza-mi-vida-cms/
├── ibiza-cms.html              ← The entire CMS (single file)
├── Dockerfile                  ← Docker build instructions
├── docker-compose.yml          ← Service definitions
├── nginx.conf                  ← Web server config
├── .env.template               ← Environment variables template
├── .env                        ← Your secrets (never commit!)
├── .gitignore
├── server-setup.sh             ← One-click VPS setup
├── README.md
└── .github/
    └── workflows/
        ├── deploy.yml          ← Main CI/CD pipeline
        └── supabase-webhook.yml ← Content-change trigger
```
