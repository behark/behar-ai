#!/bin/bash
# Check deployment configuration
# This script checks the deployment configuration for consistency

set -e

echo "🔍 Checking deployment configuration..."

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to check for port conflicts
check_port_conflicts() {
    local ports=()
    local conflicts=0
    
    echo -e "\n${BLUE}Checking port configurations in docker-compose.yml...${NC}"
    
    # Extract port mappings from docker-compose.yml
    while IFS= read -r line; do
        # Match lines with port mappings like "- "8080:8080"" or similar
        if [[ $line =~ -[[:space:]]*\"([0-9]+):[0-9]+\" ]]; then
            port=${BASH_REMATCH[1]}
            ports+=("$port")
            echo -e "  ${GREEN}Found port:${NC} $port"
        fi
    done < docker-compose.yml
    
    # Check for duplicates
    echo -e "\n${BLUE}Checking for port conflicts...${NC}"
    
    for i in "${!ports[@]}"; do
        for j in "${!ports[@]}"; do
            if [[ $i -lt $j && ${ports[i]} == ${ports[j]} ]]; then
                echo -e "  ${RED}Conflict:${NC} Port ${ports[i]} is used multiple times!"
                conflicts=$((conflicts+1))
            fi
        done
    done
    
    if [ $conflicts -eq 0 ]; then
        echo -e "  ${GREEN}No port conflicts found in docker-compose.yml${NC}"
    else
        echo -e "  ${RED}$conflicts port conflict(s) found!${NC}"
    fi
}

# Function to check Railway configuration
check_railway_config() {
    echo -e "\n${BLUE}Checking Railway configuration...${NC}"
    
    # Check if railway-fastapi.toml exists
    if [ -f "railway-fastapi.toml" ]; then
        echo -e "  ${GREEN}railway-fastapi.toml found${NC}"
        
        # Check for PORT environment variable in the toml file
        if grep -q "PORT" railway-fastapi.toml; then
            echo -e "  ${YELLOW}Warning:${NC} PORT is set in railway-fastapi.toml but Railway will override it"
        else
            echo -e "  ${GREEN}PORT correctly not set in railway-fastapi.toml (will use Railway's PORT)${NC}"
        fi
    else
        echo -e "  ${RED}railway-fastapi.toml not found!${NC}"
    fi
    
    # Check Dockerfile.railway
    if [ -f "Dockerfile.railway" ]; then
        echo -e "  ${GREEN}Dockerfile.railway found${NC}"
        
        # Check for proper handling of $PORT
        if grep -q "EXPOSE \${PORT:-" Dockerfile.railway; then
            echo -e "  ${GREEN}EXPOSE \${PORT:-8000} correctly configured in Dockerfile.railway${NC}"
        else
            echo -e "  ${YELLOW}Warning:${NC} EXPOSE directive might not handle Railway's PORT correctly"
        fi
        
        if grep -q "exec uvicorn.*--port \${PORT:-" Dockerfile.railway; then
            echo -e "  ${GREEN}Uvicorn correctly configured to use \${PORT:-8000} in Dockerfile.railway${NC}"
        else
            echo -e "  ${RED}Uvicorn might not use PORT environment variable correctly!${NC}"
        fi
    else
        echo -e "  ${RED}Dockerfile.railway not found!${NC}"
    fi
    
    # Check for minimal requirements
    if [ -f "requirements.railway.txt" ]; then
        echo -e "  ${GREEN}requirements.railway.txt found${NC}"
        
        # Count the number of packages
        pkg_count=$(grep -v "^#" requirements.railway.txt | grep -v "^$" | wc -l)
        echo -e "  ${GREEN}Found ${pkg_count} packages in requirements.railway.txt${NC}"
        
        if [ $pkg_count -gt 15 ]; then
            echo -e "  ${YELLOW}Warning:${NC} requirements.railway.txt contains more than 15 packages, might not be minimal"
        else
            echo -e "  ${GREEN}requirements.railway.txt appears to be minimal (${pkg_count} packages)${NC}"
        fi
    else
        echo -e "  ${RED}requirements.railway.txt not found!${NC}"
    fi
}

# Function to check .dockerignore
check_dockerignore() {
    echo -e "\n${BLUE}Checking .dockerignore...${NC}"
    
    if [ -f ".dockerignore" ]; then
        echo -e "  ${GREEN}.dockerignore found${NC}"
        
        # Check if .env files are excluded
        if grep -q "\.env" .dockerignore; then
            echo -e "  ${GREEN}.env files correctly excluded in .dockerignore${NC}"
        else
            echo -e "  ${RED}Warning: .env files should be excluded in .dockerignore!${NC}"
        fi
        
        # Check if unnecessary directories are excluded
        for dir in node_modules __pycache__ logs data test tests; do
            if grep -q "$dir" .dockerignore; then
                echo -e "  ${GREEN}${dir} correctly excluded in .dockerignore${NC}"
            else
                echo -e "  ${YELLOW}Warning:${NC} Consider excluding ${dir} in .dockerignore"
            fi
        done
    else
        echo -e "  ${RED}.dockerignore not found! This can lead to bloated Docker images.${NC}"
    fi
}

# Function to validate core files
check_core_files() {
    echo -e "\n${BLUE}Checking core platform files...${NC}"
    
    # Check if enhanced_platform.py exists
    if [ -f "core/enhanced_platform.py" ]; then
        echo -e "  ${GREEN}core/enhanced_platform.py found${NC}"
    else
        echo -e "  ${YELLOW}Warning:${NC} core/enhanced_platform.py not found, might be needed"
    fi
    
    # Check if minimal_platform.py exists
    if [ -f "core/minimal_platform.py" ]; then
        echo -e "  ${GREEN}core/minimal_platform.py found${NC}"
    else
        echo -e "  ${RED}core/minimal_platform.py not found! Required for Railway deployment${NC}"
    fi
}

# Run checks
check_port_conflicts
check_railway_config
check_dockerignore
check_core_files

echo -e "\n${BLUE}Configuration check completed!${NC}"
