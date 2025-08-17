#!/bin/bash

# Enhanced deployment script with multiple profiles
set -e

echo "🚀 Enhanced AI Platform Deployment Script"
echo "=========================================="

# Function to display usage
usage() {
    echo "Usage: $0 [PROFILE]"
    echo ""
    echo "Profiles:"
    echo "  basic      - Basic services (API, DB, Redis, Ollama, OpenWebUI)"
    echo "  monitoring - Basic + Prometheus & Grafana"
    echo "  agents     - Basic + AI Agents (Trading, Voice, Orchestrator)"
    echo "  dashboard  - Basic + Real-time Dashboard & WebSocket"
    echo "  full       - All services enabled"
    echo "  backup     - Basic + Backup service"
    echo ""
    echo "Example: $0 full"
    exit 1
}

# Check if profile is provided
if [ $# -eq 0 ]; then
    usage
fi

PROFILE=$1

# Validate profile
case $PROFILE in
    basic|monitoring|agents|dashboard|full|backup)
        ;;
    *)
        echo "❌ Invalid profile: $PROFILE"
        usage
        ;;
esac

echo "📋 Selected Profile: $PROFILE"

# Check if .env exists
if [ ! -f .env ]; then
    echo "⚠️  .env file not found. Creating from .env.production template..."
    cp .env.production .env
    echo "✅ Please edit .env file with your configuration before proceeding."
    echo "🔑 Make sure to set secure passwords and API keys!"
    exit 1
fi

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p logs backups databases audio monitoring

# Build the compose command based on profile
COMPOSE_PROFILES=""
case $PROFILE in
    basic)
        COMPOSE_PROFILES=""
        ;;
    monitoring)
        COMPOSE_PROFILES="--profile monitoring"
        ;;
    agents)
        COMPOSE_PROFILES="--profile agents"
        ;;
    dashboard)
        COMPOSE_PROFILES=""
        echo "🔧 Dashboard will be included by default"
        ;;
    backup)
        COMPOSE_PROFILES="--profile backup"
        ;;
    full)
        COMPOSE_PROFILES="--profile monitoring --profile agents --profile backup"
        ;;
esac

# Stop any existing containers
echo "🛑 Stopping existing containers..."
docker compose down

# Pull latest images
echo "📥 Pulling latest images..."
docker compose pull

# Build custom images
echo "🔨 Building custom images..."
docker compose build

# Start services
echo "🚀 Starting services with profile: $PROFILE"
if [ -n "$COMPOSE_PROFILES" ]; then
    docker compose $COMPOSE_PROFILES up -d
else
    docker compose up -d
fi

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 30

# Health check
echo "🏥 Performing health checks..."

# Check API
if curl -f http://localhost:8000/health > /dev/null 2>&1; then
    echo "✅ API service is healthy"
else
    echo "❌ API service is not responding"
fi

# Check OpenWebUI
if curl -f http://localhost:8080 > /dev/null 2>&1; then
    echo "✅ OpenWebUI is healthy"
else
    echo "❌ OpenWebUI is not responding"
fi

# Check Ollama
if curl -f http://localhost:11434 > /dev/null 2>&1; then
    echo "✅ Ollama is healthy"
else
    echo "❌ Ollama is not responding"
fi

# Profile-specific checks
case $PROFILE in
    monitoring|full)
        if curl -f http://localhost:9090 > /dev/null 2>&1; then
            echo "✅ Prometheus is healthy"
        else
            echo "❌ Prometheus is not responding"
        fi
        
        if curl -f http://localhost:3001 > /dev/null 2>&1; then
            echo "✅ Grafana is healthy"
        else
            echo "❌ Grafana is not responding"
        fi
        ;;
    dashboard|full)
        if curl -f http://localhost:3000 > /dev/null 2>&1; then
            echo "✅ Dashboard is healthy"
        else
            echo "❌ Dashboard is not responding"
        fi
        ;;
esac

echo ""
echo "🎉 Deployment completed!"
echo ""
echo "📊 Service URLs:"
echo "   • API: http://localhost:8000"
echo "   • OpenWebUI: http://localhost:8080"
echo "   • Ollama: http://localhost:11434"

case $PROFILE in
    monitoring|full)
        echo "   • Prometheus: http://localhost:9090"
        echo "   • Grafana: http://localhost:3001 (admin/admin)"
        ;;
    dashboard|full)
        echo "   • Dashboard: http://localhost:3000"
        echo "   • WebSocket: ws://localhost:8001"
        ;;
esac

echo ""
echo "📋 To view logs: docker compose logs -f [service-name]"
echo "🛑 To stop: docker compose down"
echo "🔄 To restart: docker compose restart [service-name]"
echo ""
