#!/bin/bash
# Deployment Mode Switcher for AI Behar Platform

echo "🚀 AI Behar Platform - Deployment Mode Switcher"
echo ""
echo "Choose your deployment option:"
echo "1. 🌐 Simple Open WebUI (fastest, Railway friendly)"
echo "2. ⚡ Custom FastAPI Platform (API + WebUI)"
echo "3. 🏗️  Full Production Stack (Docker Compose)"
echo ""

read -p "Enter your choice (1-3): " choice

case $choice in
    1)
        echo "🌐 Setting up Simple Open WebUI deployment..."
        cp railway.toml railway-backup.toml 2>/dev/null || true
        echo "[build]
builder = \"dockerfile\"

[deploy]
healthcheckPath = \"/health\"
healthcheckTimeout = 300
restartPolicyType = \"on_failure\"

[env]
WEBUI_SECRET_KEY = { generate = true }
CORS_ALLOW_ORIGIN = \"*\"
DATA_DIR = \"/app/backend/data\"" > railway.toml
        echo "✅ Ready for Railway deployment with Open WebUI"
        echo "💡 Run: railway up"
        ;;
    2)
        echo "⚡ Setting up Custom FastAPI Platform..."
        cp railway-fastapi.toml railway.toml
        echo "✅ Ready for Railway deployment with FastAPI"
        echo "💡 Run: railway up"
        echo "📊 Features: Custom API + Health checks + Metrics"
        ;;
    3)
        echo "🏗️  Setting up Full Production Stack..."
        echo "✅ Ready for Docker Compose deployment"
        echo "💡 Run: ./deploy-production.sh"
        echo "📊 Features: PostgreSQL + Redis + Monitoring + API + WebUI"
        ;;
    *)
        echo "❌ Invalid choice. Please run again and select 1, 2, or 3."
        exit 1
        ;;
esac

echo ""
echo "🔧 Configuration Files:"
echo "📄 Railway Config: railway.toml"
echo "🐳 Docker Files: Multiple options available"
echo "📋 Requirements: Optimized for each deployment type"
echo ""
echo "🚀 Ready to deploy!"
