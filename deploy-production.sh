#!/bin/bash
# Production deployment script for AI Behar Platform

echo "🚀 Starting AI Behar Platform Production Deployment..."

# Function to check if service is ready
wait_for_service() {
    local service=$1
    local port=$2
    local max_attempts=30
    local attempt=1
    
    echo "⏳ Waiting for $service to be ready..."
    while [ $attempt -le $max_attempts ]; do
        if curl -f http://localhost:$port/health &>/dev/null || \
           curl -f http://localhost:$port &>/dev/null || \
           nc -z localhost $port &>/dev/null; then
            echo "✅ $service is ready!"
            return 0
        fi
        echo "⏳ Attempt $attempt/$max_attempts: $service not ready yet..."
        sleep 5
        ((attempt++))
    done
    echo "❌ $service failed to start after $max_attempts attempts"
    return 1
}

# Check if .env exists, if not copy from template
if [ ! -f .env ]; then
    echo "📝 Creating .env from template..."
    cp .env.production .env
    echo "⚠️  IMPORTANT: Edit .env file with your secure passwords!"
fi

# Load environment variables
if [ -f .env ]; then
    echo "📋 Loading environment variables..."
    export $(cat .env | xargs)
fi

# Start the full stack
echo "🏗️  Starting AI Behar Platform services..."

# Start core services first
echo "📊 Starting database and cache services..."
docker-compose up -d db redis

# Wait for database
wait_for_service "PostgreSQL" 5432
wait_for_service "Redis" 6379

# Start Ollama
echo "🤖 Starting Ollama LLM service..."
docker-compose up -d ollama
wait_for_service "Ollama" 11434

# Start Open WebUI
echo "🌐 Starting Open WebUI..."
docker-compose up -d openwebui
wait_for_service "Open WebUI" 8080

# Start API (if exists)
if docker-compose config --services | grep -q "api"; then
    echo "⚡ Starting FastAPI backend..."
    docker-compose up -d api
    wait_for_service "API" 8000
fi

# Start monitoring (optional)
if [ "$PROMETHEUS_ENABLED" = "true" ]; then
    echo "📈 Starting monitoring services..."
    docker-compose --profile monitoring up -d
    wait_for_service "Prometheus" 9090
    wait_for_service "Grafana" 3001
fi

echo ""
echo "🎉 AI Behar Platform is now running!"
echo ""
echo "📋 Service URLs:"
echo "🌐 Open WebUI:    http://localhost:8080"
echo "⚡ API:           http://localhost:8000 (if enabled)"
echo "🤖 Ollama:        http://localhost:11434"
echo "📊 PostgreSQL:    localhost:5432"
echo "🔄 Redis:         localhost:6379"
if [ "$PROMETHEUS_ENABLED" = "true" ]; then
    echo "📈 Prometheus:    http://localhost:9090"
    echo "📊 Grafana:       http://localhost:3001 (admin/admin)"
fi
echo ""
echo "🛡️  Security Notes:"
echo "- Change default passwords in .env file"
echo "- Set up SSL/HTTPS for production"
echo "- Configure firewall rules"
echo "- Regular backups recommended"
echo ""
echo "📚 Next Steps:"
echo "1. Access Open WebUI at http://localhost:8080"
echo "2. Create admin account"
echo "3. Test all 7 LLM models"
echo "4. Configure monitoring dashboards"
echo ""
echo "✅ Deployment complete!"
