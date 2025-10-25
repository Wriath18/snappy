# Snappy

A lightweight macOS window snapping utility with global hotkeys and HTTP API control.

## Features

- **Global Hotkeys**: Snap windows instantly with keyboard shortcuts
- **HTTP API**: Control window snapping programmatically
- **Auto-Start**: Runs automatically at login as a background service
- **Accessibility-Based**: Uses native macOS Accessibility APIs for reliable window management
- **Zero UI**: Pure background agent with no menu bar clutter

## Installation

### Option 1: Homebrew (Recommended)

1. **Add the tap** (once you publish your Homebrew tap):
   ```bash
   brew tap yourusername/snappy
   ```

2. **Install Snappy**:
   ```bash
   brew install snappy
   ```

3. **Start the service**:
   ```bash
   brew services start snappy
   ```

   Or start it once manually:
   ```bash
   snappy
   ```

### Option 2: Manual Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/Snappy.git
   cd Snappy
   ```

2. **Run the install script**:
   ```bash
   make install
   ```

   Or run the script directly:
   ```bash
   ./scripts/install.sh
   ```

This will:
- Build the release binary
- Install it to `/usr/local/bin/snappy`
- Set up a LaunchAgent for auto-start at login
- Start the service immediately

## First-Time Setup

Snappy requires **Accessibility permissions** to control windows:

1. Press any hotkey (e.g., `Ctrl+Opt+Cmd + Left Arrow`)
2. macOS will show a permission dialog
3. Click "Open System Settings"
4. Enable **Snappy** in **Privacy & Security → Accessibility**
5. Press the hotkey again - it should now work!

System Settings will open automatically when you first run Snappy if permissions aren't granted.

## Usage

### Global Hotkeys

All hotkeys use the `Ctrl+Opt+Cmd` (⌃⌥⌘) modifier combination:

| Hotkey | Action |
|--------|--------|
| `Ctrl+Opt+Cmd + ←` | Snap window to **left half** |
| `Ctrl+Opt+Cmd + →` | Snap window to **right half** |
| `Ctrl+Opt+Cmd + ↑` | Snap window to **top half** |
| `Ctrl+Opt+Cmd + ↓` | Snap window to **bottom half** |
| `Ctrl+Opt+Cmd + Return` | **Maximize** window |
| `Ctrl+Opt+Cmd + C` | **Center** window (70% size) |

### HTTP API

Snappy runs a local HTTP server on port `42424` for programmatic control:

```bash
# Snap to left half
curl -X POST http://localhost:42424/snap/left

# Snap to right half
curl -X POST http://localhost:42424/snap/right

# Snap to top half
curl -X POST http://localhost:42424/snap/top

# Snap to bottom half
curl -X POST http://localhost:42424/snap/bottom

# Maximize
curl -X POST http://localhost:42424/snap/maximize

# Center
curl -X POST http://localhost:42424/snap/center
```

### Command-Line Options

```bash
# Show version
snappy --version

# Show help
snappy --help
```

## Service Management

### Using Homebrew

```bash
# Start service (auto-start at login)
brew services start snappy

# Stop service
brew services stop snappy

# Restart service
brew services restart snappy

# Check service status
brew services info snappy
```

### Using launchctl (Manual Installation)

```bash
# Start service
launchctl load ~/Library/LaunchAgents/com.snappy.agent.plist

# Stop service
launchctl unload ~/Library/LaunchAgents/com.snappy.agent.plist

# Check if running
launchctl list | grep snappy
```

## Logs

View logs to troubleshoot issues:

```bash
# Homebrew installation
tail -f /tmp/snappy.out.log
tail -f /tmp/snappy.err.log

# Or check system logs
log stream --predicate 'process == "snappy"' --level debug
```

## Uninstallation

### Homebrew

```bash
brew services stop snappy
brew uninstall snappy
brew untap yourusername/snappy
```

### Manual Installation

```bash
make uninstall
```

Or run the script directly:
```bash
./scripts/uninstall.sh
```

## Development

### Requirements

- macOS 13.0 or later
- Swift 6.1 or later
- Xcode Command Line Tools

### Building

```bash
# Build release
make build

# Or using SwiftPM
swift build -c release
```

### Running (Development)

```bash
# Run directly
make run

# Or using SwiftPM
swift run
```

### Project Structure

```
Snappy/
├── Sources/Snappy/
│   ├── main.swift           # Entry point, CLI handling
│   ├── AppContext.swift     # Main coordinator
│   ├── HotkeyManager.swift  # Global hotkey registration
│   ├── SnapService.swift    # Window manipulation via Accessibility API
│   ├── HTTPServer.swift     # HTTP API server
│   ├── Configuration.swift  # App configuration
│   └── SnapAction.swift     # Snap action definitions
├── LaunchAgents/
│   └── com.snappy.agent.plist  # LaunchAgent configuration
├── Formula/
│   └── snappy.rb            # Homebrew formula
├── scripts/
│   ├── install.sh           # Installation script
│   └── uninstall.sh         # Uninstallation script
└── Makefile                 # Build automation
```

## Publishing to Homebrew

To make your formula publicly available:

1. **Create a GitHub release**:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. **Create a Homebrew tap repository** named `homebrew-snappy`

3. **Copy the formula**:
   ```bash
   cp Formula/snappy.rb ../homebrew-snappy/snappy.rb
   ```

4. **Update the formula** with the correct URL and SHA256:
   ```bash
   # Get the SHA256 of your release tarball
   curl -L https://github.com/yourusername/Snappy/archive/refs/tags/v1.0.0.tar.gz | shasum -a 256
   ```

5. **Update the formula** with the SHA256 and push to your tap repository

6. **Users can then install with**:
   ```bash
   brew tap yourusername/snappy
   brew install snappy
   ```

## License

MIT License - See LICENSE file for details

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Credits

Built with Swift, using macOS Accessibility APIs and Carbon Event Manager for global hotkeys.
