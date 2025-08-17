# 🤖 Enhanced Dimensional AI Platform

A comprehensive AI platform with multi-agent orchestration, real-time dashboard, voice interface, trading capabilities, and advanced monitoring.

## 🌟 Features

### Core Platform
- **FastAPI Backend** - High-performance API with health checks
- **PostgreSQL Database** - Production-ready data persistence
- **Redis Caching** - Fast data caching and session management
- **Ollama Integration** - Local LLM inference
- **Open WebUI** - Beautiful chat interface

### Advanced Features
- **🤖 Multi-Agent System** - Trading, Voice, and Meta Controller agents
- **📊 Real-time Dashboard** - Live monitoring with WebSocket updates
- **🗣️ Voice Interface** - Speech-to-text and text-to-speech capabilities
- **📈 Trading Agent** - Automated trading with risk management
- **🔍 Monitoring Stack** - Prometheus metrics and Grafana dashboards
- **💾 Automated Backups** - Database backup and retention
- **🎯 Agent Orchestration** - Load balancing and performance monitoring

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Dashboard     │    │   OpenWebUI     │    │   Voice Agent   │
│   (Port 3000)   │    │   (Port 8080)   │    │   (Port 8002)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   WebSocket     │    │   FastAPI       │    │   Trading       │
│   (Port 8001)   │    │   (Port 8000)   │    │   Agent         │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Orchestrator  │    │   PostgreSQL    │    │     Redis       │
│                 │    │   (Port 5432)   │    │   (Port 6379)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Prometheus    │    │     Ollama      │    │    Grafana      │
│   (Port 9090)   │    │   (Port 11434)  │    │   (Port 3001)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🚀 Quick Start

### 1. Clone and Setup
```bash
git clone <repository-url>
cd behar-ai-deploy
```

### 2. Configure Environment
```bash
cp .env.production .env
# Edit .env with your configuration
```

### 3. Deploy with Profiles

#### Basic Deployment (Core Services Only)
```bash
./deploy-enhanced.sh basic
```

#### Full Deployment (All Features)
```bash
./deploy-enhanced.sh full
```

#### Other Deployment Options
```bash
# Monitoring only
./deploy-enhanced.sh monitoring

# AI Agents only
./deploy-enhanced.sh agents

# Dashboard only
./deploy-enhanced.sh dashboard

# With backups
./deploy-enhanced.sh backup
```

## 🎛️ Deployment Profiles

| Profile | Services Included |
|---------|------------------|
| `basic` | API, DB, Redis, Ollama, OpenWebUI |
| `monitoring` | Basic + Prometheus, Grafana |
| `agents` | Basic + Trading Agent, Voice Agent, Orchestrator |
| `dashboard` | Basic + Real-time Dashboard, WebSocket |
| `backup` | Basic + Automated Backups |
| `full` | All services enabled |

## 🔧 Service Management

### Agent Management
```bash
# Start all agents
./manage-agents.sh start all

# Start specific agent
./manage-agents.sh start trading

# Check agent status
./manage-agents.sh status

# View agent logs
./manage-agents.sh logs voice

# Stop agents
./manage-agents.sh stop all
```

### Docker Compose Commands
```bash
# View all logs
docker compose logs -f

# View specific service logs
docker compose logs -f api

# Restart specific service
docker compose restart api

# Scale services
docker compose up -d --scale api=2
```

## 🌐 Service URLs

| Service | URL | Description |
|---------|-----|-------------|
| **FastAPI** | http://localhost:8000 | Main API endpoint |
| **OpenWebUI** | http://localhost:8080 | Chat interface |
| **Dashboard** | http://localhost:3000 | Real-time monitoring |
| **Ollama** | http://localhost:11434 | LLM inference |
| **Prometheus** | http://localhost:9090 | Metrics collection |
| **Grafana** | http://localhost:3001 | Metrics visualization |
| **Voice Agent** | http://localhost:8002 | Voice interface |
| **WebSocket** | ws://localhost:8001 | Real-time updates |

## 🔑 Configuration

### Environment Variables

#### Core Configuration
```env
# Database
DB_PASSWORD=your_secure_password_here
DATABASE_URL=postgresql://ai_behar_user:password@db:5432/dimensional_ai_prod

# API
API_PORT=8000
ENVIRONMENT=production
DEBUG=false
```

#### Agent Configuration
```env
# Trading Agent
TRADING_ENABLED=false
INITIAL_BALANCE=100000
ALPHA_VANTAGE_API_KEY=your_api_key_here

# Voice Agent
VOICE_ENABLED=true
VOICE_LANGUAGE=en

# Orchestrator
MAX_AGENTS=10
HEALTH_CHECK_INTERVAL=30
```

#### External APIs
```env
# Optional integrations
OPENAI_API_KEY=sk-your-openai-key-here
ALPHA_VANTAGE_API_KEY=your_alpha_vantage_key_here
```

### Platform Configuration (platform-config.toml)

The platform uses a TOML configuration file for advanced settings:

- **Agent settings** - Trading parameters, voice settings
- **Orchestrator configuration** - Load balancing, performance monitoring
- **Integration settings** - External API configurations
- **Security settings** - JWT secrets, encryption
- **Monitoring configuration** - Health checks, metrics

## 🤖 AI Agents

### Trading Agent
- **Market Analysis** - Real-time market data processing
- **Risk Management** - Position sizing and stop-loss
- **Multiple Markets** - Stocks, crypto, forex support
- **Strategy Execution** - Automated trading strategies

### Voice Agent
- **Speech Recognition** - Convert speech to text
- **Text-to-Speech** - Natural voice responses
- **Multi-language** - Support for multiple languages
- **Real-time Processing** - Low-latency voice interaction

### Orchestrator Agent
- **Load Balancing** - Distribute tasks across agents
- **Health Monitoring** - Agent performance tracking
- **Auto-scaling** - Dynamic agent management
- **Task Coordination** - Inter-agent communication

## 📊 Monitoring & Observability

### Prometheus Metrics
- System performance metrics
- Agent performance tracking
- API response times
- Database connection stats

### Grafana Dashboards
- Real-time system overview
- Agent performance visualization
- Resource utilization tracking
- Alert management

### Health Checks
All services include comprehensive health checks:
- Database connectivity
- Redis connectivity
- Agent responsiveness
- API endpoint availability

## 💾 Backup & Recovery

### Automated Backups
- **Daily backups** - PostgreSQL database dumps
- **Retention policy** - 7-day retention by default
- **Compression** - Gzipped backup files
- **Cleanup** - Automatic old backup removal

### Manual Backup
```bash
# Run backup manually
docker compose exec backup /backup.sh

# Restore from backup
docker compose exec db psql -U ai_behar_user -d dimensional_ai_prod < backup_file.sql
```

## 🔒 Security

### Built-in Security Features
- **Non-root containers** - All services run as non-root users
- **Environment isolation** - Separate network for services
- **Secret management** - Environment-based configuration
- **JWT authentication** - Secure API access
- **CORS configuration** - Configurable cross-origin policies

### Security Best Practices
1. Change all default passwords
2. Use strong JWT secrets
3. Configure CORS appropriately
4. Enable HTTPS in production
5. Regular security updates

## 🚨 Troubleshooting

### Common Issues

#### Services Not Starting
```bash
# Check logs
docker compose logs -f [service-name]

# Check system resources
docker system df
```

#### Agent Connection Issues
```bash
# Restart agents
./manage-agents.sh restart all

# Check agent status
./manage-agents.sh status
```

#### Database Connection Issues
```bash
# Check database health
docker compose exec db pg_isready -U ai_behar_user

# View database logs
docker compose logs db
```

## 📈 Performance Tuning

### Resource Limits
Services are configured with appropriate resource limits:
- **Ollama**: 8GB memory limit, 4GB reservation
- **PostgreSQL**: Optimized for production workloads
- **Redis**: Persistent storage with AOF

### Scaling Options
```bash
# Scale API instances
docker compose up -d --scale api=3

# Scale with load balancer
# (Configure nginx/haproxy for production)
```

## 🛠️ Development

### Adding New Agents
1. Create new Dockerfile (e.g., `Dockerfile.newagent`)
2. Add requirements file (`requirements.newagent.txt`)
3. Update `docker-compose.yml` with new service
4. Add agent to `manage-agents.sh`
5. Update platform configuration

### Custom Dashboards
1. Add dashboard components to `src/dashboard/`
2. Update dashboard Dockerfile
3. Configure WebSocket connections
4. Deploy with dashboard profile

## 📝 License

This project is licensed under the MIT License. See LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📞 Support

For issues and questions:
1. Check the troubleshooting section
2. Review Docker logs
3. Create an issue in the repository
4. Join our community discussions

---

**Built with ❤️ for the AI community**
