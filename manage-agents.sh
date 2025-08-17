#!/bin/bash

# Agent management script
set -e

echo "🤖 AI Agent Management Script"
echo "============================="

# Function to display usage
usage() {
    echo "Usage: $0 [COMMAND] [AGENT]"
    echo ""
    echo "Commands:"
    echo "  start     - Start specific agent or all agents"
    echo "  stop      - Stop specific agent or all agents"
    echo "  restart   - Restart specific agent or all agents"
    echo "  status    - Show status of agents"
    echo "  logs      - Show logs for specific agent"
    echo ""
    echo "Agents:"
    echo "  trading      - Trading agent"
    echo "  voice        - Voice interface agent"
    echo "  orchestrator - Agent orchestrator/meta controller"
    echo "  all          - All agents"
    echo ""
    echo "Examples:"
    echo "  $0 start trading"
    echo "  $0 stop all"
    echo "  $0 logs voice"
    exit 1
}

# Check arguments
if [ $# -lt 1 ]; then
    usage
fi

COMMAND=$1
AGENT=${2:-all}

# Validate command
case $COMMAND in
    start|stop|restart|status|logs)
        ;;
    *)
        echo "❌ Invalid command: $COMMAND"
        usage
        ;;
esac

# Validate agent
case $AGENT in
    trading|voice|orchestrator|all)
        ;;
    *)
        echo "❌ Invalid agent: $AGENT"
        usage
        ;;
esac

# Function to get container name
get_container_name() {
    case $1 in
        trading) echo "ai-behar-trading" ;;
        voice) echo "ai-behar-voice" ;;
        orchestrator) echo "ai-behar-orchestrator" ;;
    esac
}

# Function to start agent
start_agent() {
    local agent=$1
    local container=$(get_container_name $agent)
    
    echo "🚀 Starting $agent agent..."
    docker compose --profile agents up -d $agent-agent
    echo "✅ $agent agent started"
}

# Function to stop agent
stop_agent() {
    local agent=$1
    local container=$(get_container_name $agent)
    
    echo "🛑 Stopping $agent agent..."
    docker compose stop $agent-agent
    echo "✅ $agent agent stopped"
}

# Function to restart agent
restart_agent() {
    local agent=$1
    echo "🔄 Restarting $agent agent..."
    stop_agent $agent
    sleep 2
    start_agent $agent
}

# Function to show status
show_status() {
    echo "📊 Agent Status:"
    echo "================"
    
    agents=("trading" "voice" "orchestrator")
    for agent in "${agents[@]}"; do
        container=$(get_container_name $agent)
        if docker ps --format "table {{.Names}}" | grep -q $container; then
            echo "✅ $agent: Running"
        else
            echo "❌ $agent: Stopped"
        fi
    done
}

# Function to show logs
show_logs() {
    local agent=$1
    local container=$(get_container_name $agent)
    
    echo "📝 Showing logs for $agent agent..."
    docker compose logs -f $agent-agent
}

# Execute command
case $COMMAND in
    start)
        if [ "$AGENT" = "all" ]; then
            echo "🚀 Starting all agents..."
            start_agent "trading"
            start_agent "voice" 
            start_agent "orchestrator"
            echo "✅ All agents started"
        else
            start_agent $AGENT
        fi
        ;;
    stop)
        if [ "$AGENT" = "all" ]; then
            echo "🛑 Stopping all agents..."
            stop_agent "trading"
            stop_agent "voice"
            stop_agent "orchestrator"
            echo "✅ All agents stopped"
        else
            stop_agent $AGENT
        fi
        ;;
    restart)
        if [ "$AGENT" = "all" ]; then
            echo "🔄 Restarting all agents..."
            restart_agent "trading"
            restart_agent "voice"
            restart_agent "orchestrator"
            echo "✅ All agents restarted"
        else
            restart_agent $AGENT
        fi
        ;;
    status)
        show_status
        ;;
    logs)
        if [ "$AGENT" = "all" ]; then
            echo "❌ Please specify a specific agent for logs"
            usage
        else
            show_logs $AGENT
        fi
        ;;
esac
