#!/bin/bash
set -e

echo "🚀 Installing Snappy..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Build release binary
echo "📦 Building release binary..."
cd "$PROJECT_ROOT"
swift build -c release

# Install binary to /usr/local/bin
echo "📥 Installing binary to /usr/local/bin/snappy..."
sudo mkdir -p /usr/local/bin
sudo cp .build/release/Snappy /usr/local/bin/snappy
sudo chmod +x /usr/local/bin/snappy

# Create log directory
echo "📁 Creating log directory..."
mkdir -p ~/Library/Logs/Snappy

# Install LaunchAgent
echo "⚙️  Installing LaunchAgent..."
mkdir -p ~/Library/LaunchAgents
cp "$PROJECT_ROOT/LaunchAgents/com.snappy.agent.plist" ~/Library/LaunchAgents/
chmod 644 ~/Library/LaunchAgents/com.snappy.agent.plist

# Load LaunchAgent
echo "🔄 Loading LaunchAgent..."
launchctl unload ~/Library/LaunchAgents/com.snappy.agent.plist 2>/dev/null || true
launchctl load ~/Library/LaunchAgents/com.snappy.agent.plist

echo ""
echo -e "${GREEN}✓ Snappy installed successfully!${NC}"
echo ""
echo -e "${YELLOW}First-time setup:${NC}"
echo "1. Press any hotkey (Ctrl+Opt+Cmd + Arrow) to trigger the accessibility permission dialog"
echo "2. Enable Snappy in System Settings > Privacy & Security > Accessibility"
echo "3. Press the hotkey again to start snapping windows!"
echo ""
echo "Hotkeys:"
echo "  Ctrl+Opt+Cmd + Left/Right/Up/Down  - Snap to half"
echo "  Ctrl+Opt+Cmd + Return              - Maximize"
echo "  Ctrl+Opt+Cmd + C                   - Center"
echo ""
echo "Logs: ~/Library/Logs/Snappy/"
echo ""

