#!/bin/bash
# Railway Minimal Deployment Script
# This script prepares the repository for a minimal Railway deployment

set -e

echo "🚀 Preparing for Railway deployment..."

# Check if .env exists and create if not
if [ ! -f .env ]; then
    echo "⚠️ .env file not found. Creating from .env.production template..."
    cp .env.production .env
    echo "✅ Created .env file. Please edit with your configuration before deploying to Railway."
fi

# Create minimal Railway-specific files
echo "📄 Creating Railway deployment files..."

# Create a minimal directory structure to avoid deploying unnecessary files
mkdir -p railway-deploy/core

# Copy only essential files for deployment
echo "📦 Copying essential files..."

# Core files
cp core/minimal_platform.py railway-deploy/core/
cp requirements.railway.txt railway-deploy/
cp Dockerfile.railway railway-deploy/Dockerfile
cp railway-fastapi.toml railway-deploy/railway.toml

# Create basic .env file for Railway
cat > railway-deploy/.env.example << 'EOF'
# Railway environment config
ENVIRONMENT=production
DEBUG=false
CORS_ALLOW_ORIGIN=*
OLLAMA_BASE_URL=https://your-ollama-instance-url:11434
EOF

# Create .dockerignore for Railway
cat > railway-deploy/.dockerignore << 'EOF'
# Ignore everything
*

# Except essential files
!core/minimal_platform.py
!requirements.railway.txt
!.env.example
EOF

echo "🔧 Configuring for minimal size deployment..."

# Create a simple README for Railway
cat > railway-deploy/README.md << 'EOF'
# Minimal Railway Deployment

This is a minimal deployment configuration for Railway.

## Environment Variables

- `PORT` - Set automatically by Railway
- `OLLAMA_BASE_URL` - URL to your Ollama instance
- `ENVIRONMENT` - Set to "production" by default
- `DEBUG` - Set to "false" by default
- `CORS_ALLOW_ORIGIN` - Set to "*" by default or specify allowed origins
EOF

echo "✅ Railway deployment package prepared!"
echo ""
echo "📋 Next steps:"
echo "1. Deploy to Railway using: railway up -d railway-deploy"
echo "2. Set the required environment variables in Railway dashboard"
echo "3. Connect to your Ollama instance using the OLLAMA_BASE_URL environment variable"
echo ""
