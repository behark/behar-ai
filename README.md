# Behar AI - Production Open WebUI Platform

A complete production-ready AI platform with Open WebUI, PostgreSQL, Redis, monitoring, and 7 LLM models.

## 🌟 Features

- 🤖 **Open WebUI** - Modern chat interface
- �️ **PostgreSQL** - Production database
- ⚡ **Redis** - High-performance caching
- 🐋 **Docker** - Containerized deployment
- 📊 **Monitoring** - Prometheus + Grafana
- 🔒 **Security** - User management & API keys
- 📈 **Analytics** - Usage tracking
- 🔄 **Backup** - Automated backups

## 🚀 Quick Deploy

### Railway (Recommended)
[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template)

**Step 1: Choose deployment mode**
```bash
git clone https://github.com/behark/behar-ai.git
cd behar-ai
./setup-deployment.sh  # Choose your option
```

**Step 2: Deploy to Railway**
```bash
railway login
railway init
railway up
```

**Deployment Options:**
1. **Simple WebUI** - Open WebUI only (2 min setup)
2. **Custom Platform** - FastAPI + WebUI (5 min setup)
3. **Full Production** - All services (15 min setup)

### Local Development
```bash
# Quick Docker setup
docker build -f Dockerfile.railway -t behar-ai .
docker run -p 8080:8080 behar-ai
```

## 🛠️ Configuration

1. **Copy environment template:**
   ```bash
   cp .env.deploy .env
   ```

2. **Edit configuration:**
   - Set `WEBUI_SECRET_KEY` to a secure random string
   - Configure `OLLAMA_BASE_URL` if using external Ollama
   - Set `CORS_ALLOW_ORIGIN` to your domain

3. **Deploy and access:**
   - Railway: Automatic HTTPS URL provided
   - VPS: Configure nginx + SSL
   - Local: http://localhost:8080

## 🔒 Security

- No personal data in repository
- Environment variables for secrets
- CORS protection
- Rate limiting enabled
- Authentication required

## 📊 Features

- Multiple LLM support via Ollama
- Clean, responsive web interface
- API access for integrations
- Real-time chat streaming
- Model switching
- Chat history

## 🆘 Support

For issues or questions, please open an issue in this repository.
