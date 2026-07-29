#!/bin/bash
# Build using docker build command directly

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "🚀 Building Code-Server Dev Environment"
echo "========================================"
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠️  .env file not found${NC}"
    echo "Creating from .env.example..."
    cp .env.example .env
    echo -e "${GREEN}✅ Created .env${NC}"
    echo "Please edit .env and set your password, then run this script again."
    exit 0
fi

echo "📋 Configuration:"
echo "  Running as: root (inside container)"
echo "  Port: ${PORT:-8080}"
echo "  Ollama Port: ${OLLAMA_PORT:-11434}"

# Source .env for variables
set -a
source .env
set +a

echo ""
echo "🔨 Building Docker image..."
echo "This will take 10-15 minutes on first run."
echo ""

# Build the image with docker build
docker build -t code-server-dev:latest .

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Build complete!${NC}"
    echo ""
    echo "🚀 Starting container..."
    echo ""
    
    # Stop and remove existing container if it exists
    docker stop code-server-dev 2>/dev/null || true
    docker rm code-server-dev 2>/dev/null || true
    
    # Create required directories
    mkdir -p data workspace ollama
    
    # Run the container
    docker run -d \
      --name code-server-dev \
      --hostname code-server-dev \
      -p "${PORT:-8080}:8080" \
      -p "${OLLAMA_PORT:-11434}:11434" \
      -e PASSWORD="${PASSWORD:-changeme}" \
      -e TZ="${TZ:-UTC}" \
      -e EXTENSIONS="${EXTENSIONS:-}" \
      -e GEMINI_API_KEY="${GEMINI_API_KEY:-}" \
      -v "$(pwd)/data:/root/.local/share/code-server" \
      -v "$(pwd)/ollama:/root/.ollama" \
      -v "$(pwd)/workspace:/root/workspace" \
      -v "${HOME}:/host-home" \
      -v "$(pwd)/extensions.txt:/extensions.txt:ro" \
      --restart unless-stopped \
      code-server-dev:latest
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✅ Container started successfully!${NC}"
        echo ""
        echo "📊 Container status:"
        sleep 2
        docker ps -a --filter name=code-server-dev
        
        echo ""
        echo "📝 Useful commands:"
        echo "  View logs:    docker logs -f code-server-dev"
        echo "  Enter shell:  docker exec -it code-server-dev zsh"
        echo "  Stop:         docker stop code-server-dev"
        echo "  Restart:      docker restart code-server-dev"
        echo ""
        echo "🌐 Access at:"
        echo "   Code-Server: http://localhost:${PORT:-8080}"
        echo "   Ollama API:  http://localhost:${OLLAMA_PORT:-11434}"
        echo ""
        echo -e "${GREEN}🎉 Happy coding!${NC}"
    else
        echo -e "${RED}❌ Failed to start container${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi
