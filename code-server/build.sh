#!/bin/bash
set -e

echo "🚀 Code-Server Dev Environment Builder"
echo "======================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠️  .env file not found${NC}"
    echo "Creating from .env.example..."
    cp .env.example .env
    echo -e "${GREEN}✅ Created .env file${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  IMPORTANT: Edit .env and change the PASSWORD!${NC}"
    echo ""
    read -p "Press Enter to continue or Ctrl+C to cancel and edit .env first..."
fi

# Get user IDs
CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)

echo ""
echo "📋 Configuration:"
echo "  Current User ID (PUID): $CURRENT_UID"
echo "  Current Group ID (PGID): $CURRENT_GID"
echo ""

# Check if PUID/PGID match in .env
if grep -q "PUID=$CURRENT_UID" .env && grep -q "PGID=$CURRENT_GID" .env; then
    echo -e "${GREEN}✅ User IDs match${NC}"
else
    echo -e "${YELLOW}⚠️  User IDs don't match .env file${NC}"
    read -p "Update .env with your current IDs? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sed -i.bak "s/PUID=.*/PUID=$CURRENT_UID/" .env
        sed -i.bak "s/PGID=.*/PGID=$CURRENT_GID/" .env
        rm .env.bak
        echo -e "${GREEN}✅ Updated PUID and PGID in .env${NC}"
    fi
fi

echo ""
echo "🔨 Starting build process..."
echo "This will take 10-15 minutes on first run."
echo ""

# Build and start
docker-compose up -d --build

echo ""
echo -e "${GREEN}✅ Build complete!${NC}"
echo ""
echo "📊 Checking container status..."
sleep 2
docker-compose ps

echo ""
echo "📝 View logs with:"
echo "   docker-compose logs -f"
echo ""
echo "🌐 Access at:"
echo "   http://localhost:$(grep PORT .env | cut -d '=' -f2)"
echo ""
echo -e "${GREEN}🎉 Happy coding!${NC}"
