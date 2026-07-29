#!/bin/bash
# Troubleshooting and health check script

echo "🔍 Code-Server Dev Environment Health Check"
echo "==========================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if docker is running
echo -n "Checking Docker... "
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running${NC}"
    echo "Please start Docker Desktop or Docker daemon"
    exit 1
fi
echo -e "${GREEN}✅${NC}"

# Check if .env exists
echo -n "Checking .env file... "
if [ ! -f .env ]; then
    echo -e "${RED}❌ Missing${NC}"
    echo "Run: cp .env.example .env"
    exit 1
fi
echo -e "${GREEN}✅${NC}"

# Check if container is running
echo -n "Checking container... "
if ! docker-compose ps | grep -q "Up"; then
    echo -e "${YELLOW}⚠️  Not running${NC}"
    echo "Run: docker-compose up -d"
else
    echo -e "${GREEN}✅${NC}"
fi

# Check port
PORT=$(grep "^PORT=" .env | cut -d'=' -f2)
OLLAMA_PORT=$(grep "^OLLAMA_PORT=" .env | cut -d'=' -f2 || echo "11434")
echo -n "Checking port $PORT... "
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo -e "${GREEN}✅ In use${NC}"
else
    echo -e "${YELLOW}⚠️  Not listening${NC}"
fi

echo -n "Checking Ollama port $OLLAMA_PORT... "
if lsof -Pi :$OLLAMA_PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo -e "${GREEN}✅ In use${NC}"
else
    echo -e "${YELLOW}⚠️  Not listening${NC}"
fi

# Check files
echo ""
echo "📁 File Check:"
for file in Dockerfile docker-compose.yml extensions.txt install-extensions.sh docker-entrypoint.sh; do
    if [ -f "$file" ]; then
        echo -e "  ${GREEN}✅${NC} $file"
    else
        echo -e "  ${RED}❌${NC} $file - MISSING!"
    fi
done

# Check directories
echo ""
echo "📂 Directory Check:"
for dir in data workspace ollama; do
    if [ -d "$dir" ]; then
        echo -e "  ${GREEN}✅${NC} $dir/"
    else
        echo -e "  ${YELLOW}⚠️${NC} $dir/ - Will be created on first run"
    fi
done

# System resources
echo ""
echo "💻 System Resources:"
if command -v docker &> /dev/null; then
    echo "  CPU: $(docker info 2>/dev/null | grep "CPUs:" | awk '{print $2}')"
    echo "  Memory: $(docker info 2>/dev/null | grep "Total Memory:" | awk '{print $3,$4}')"
fi

# Container info if running
echo ""
if docker-compose ps | grep -q "Up"; then
    echo "📊 Container Stats:"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" $(docker-compose ps -q) 2>/dev/null || true
    
    echo ""
    echo "🔗 Access Information:"
    echo "  Code-Server: http://localhost:$PORT"
    echo "  Ollama API: http://localhost:$OLLAMA_PORT"
    echo "  Password: (set in .env)"
    
    echo ""
    echo "📝 Quick Commands:"
    echo "  View logs: docker-compose logs -f"
    echo "  Enter shell: docker-compose exec code-server-dev zsh"
    echo "  Test Ollama: curl http://localhost:$OLLAMA_PORT/api/tags"
    echo "  Restart: docker-compose restart"
    echo "  Stop: docker-compose down"
fi

echo ""
echo "✅ Health check complete!"
