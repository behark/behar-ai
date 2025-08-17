# Behar AI - Open WebUI Deployment

A production-ready Open WebUI setup with multiple LLM support.

## 🚀 Quick Deploy

### Railway (Recommended)
[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template)

**Option 1: Standard Deployment**
```bash
# Clone and deploy
git clone https://github.com/behark/behar-ai.git
cd behar-ai
railway login
railway init
railway up
```

**Option 2: If build fails, try alternative config**
```bash
# Rename files to use alternative Dockerfile
mv railway-alt.toml railway.toml
# Then deploy normally
railway up
```

### Docker (Self-hosted)
```bash
# Clone repository
git clone https://github.com/behark/behar-ai.git
cd behar-ai

# Build and run
docker build -t behar-ai .
docker run -p 8080:8080 behar-ai
```

### VPS Deployment
```bash
# On your VPS
git clone https://github.com/behark/behar-ai.git
cd behar-ai
cp .env.example .env
# Edit .env with your settings
nano .env

# Run with Docker Compose
docker-compose up -d
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
