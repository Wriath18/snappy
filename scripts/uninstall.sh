#!/bin/bash
set -e

echo "🗑️  Uninstalling Snappy..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Unload LaunchAgent
echo "⏹️  Stopping Snappy service..."
launchctl unload ~/Library/LaunchAgents/com.snappy.agent.plist 2>/dev/null || true

# Remove LaunchAgent
echo "🗑️  Removing LaunchAgent..."
rm -f ~/Library/LaunchAgents/com.snappy.agent.plist

# Remove binary
echo "🗑️  Removing binary..."
sudo rm -f /usr/local/bin/snappy

# Ask about logs
echo ""
read -p "Remove logs directory? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf ~/Library/Logs/Snappy
    echo "🗑️  Removed logs"
fi

echo ""
echo -e "${GREEN}✓ Snappy uninstalled successfully!${NC}"
echo ""

