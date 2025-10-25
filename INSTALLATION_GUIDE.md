# Snappy Installation Guide

Complete guide to install and configure Snappy on your Mac.

## Quick Start

### For End Users

**Option 1: Homebrew (Once published)**
```bash
brew tap yourusername/snappy
brew install snappy
brew services start snappy
```

**Option 2: Manual Installation**
```bash
git clone https://github.com/yourusername/Snappy.git
cd Snappy
make install
```

## Detailed Installation Steps

### Prerequisites

- macOS 13.0 or later
- Xcode Command Line Tools (install with: `xcode-select --install`)

### Manual Installation Process

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/Snappy.git
   cd Snappy
   ```

2. **Install using the automated script**:
   ```bash
   make install
   ```
   
   This script will:
   - Build the release binary using Swift Package Manager
   - Copy the binary to `/usr/local/bin/snappy` (requires sudo password)
   - Create a logs directory at `~/Library/Logs/Snappy/`
   - Install a LaunchAgent plist to auto-start Snappy at login
   - Start the Snappy service immediately

3. **Grant Accessibility Permissions**:
   
   When you first use Snappy (press any hotkey), macOS will prompt you:
   
   - Click **"Open System Settings"**
   - In **Privacy & Security → Accessibility**, enable **Snappy**
   - Press the hotkey again - it should now work!

## Verifying Installation

Check that Snappy is installed correctly:

```bash
# Check version
snappy --version
# Output: Snappy v1.0.0

# Check if service is running
launchctl list | grep snappy
# Should show: com.snappy.agent
```

## Testing the Installation

Try these commands to test Snappy:

```bash
# Test with HTTP API
curl -X POST http://localhost:42424/snap/left

# Use global hotkeys (make sure a window is focused)
# Press: Ctrl+Opt+Cmd + Left Arrow
```

## Troubleshooting

### "snappy: command not found"

The binary might not be in your PATH:
```bash
# Check if binary exists
ls -l /usr/local/bin/snappy

# If not there, reinstall
make install
```

### Service not starting

```bash
# Check service status
launchctl list | grep snappy

# Manually start the service
launchctl load ~/Library/LaunchAgents/com.snappy.agent.plist

# Check logs for errors
tail -f /tmp/snappy.err.log
```

### Hotkeys not working

1. **Check Accessibility permissions**:
   - System Settings → Privacy & Security → Accessibility
   - Ensure Snappy is listed and enabled
   - If not listed, press a hotkey to trigger the permission prompt

2. **Restart the service**:
   ```bash
   launchctl unload ~/Library/LaunchAgents/com.snappy.agent.plist
   launchctl load ~/Library/LaunchAgents/com.snappy.agent.plist
   ```

3. **Check if another app is using the same hotkeys**:
   - Try disabling other window managers or hotkey utilities temporarily

### HTTP API not responding

```bash
# Check if service is running
launchctl list | grep snappy

# Check if port is in use
lsof -i :42424

# Check logs
tail -f /tmp/snappy.out.log
```

### Build errors during installation

```bash
# Make sure Xcode CLI tools are installed
xcode-select --install

# Try building manually
swift build -c release

# If Swift version is too old, update Xcode
softwareupdate --list
```

## Uninstalling

To completely remove Snappy:

```bash
make uninstall
```

This will:
- Stop the LaunchAgent service
- Remove the LaunchAgent plist
- Remove the binary from `/usr/local/bin`
- Optionally remove logs (you'll be prompted)

## Advanced Configuration

### Changing the HTTP Port

Currently, the HTTP port is hardcoded to `42424`. To change it:

1. Edit `Sources/Snappy/Configuration.swift`
2. Change the `httpPort` value in `AppConfiguration.default`
3. Rebuild and reinstall:
   ```bash
   make install
   ```

### Customizing Hotkeys

To customize hotkeys, edit `Sources/Snappy/Configuration.swift`:

1. Find the `hotkeyMappings` array
2. Modify the key codes (see [Carbon Key Codes](https://github.com/phracker/MacOSX-SDKs/blob/master/MacOSX10.13.sdk/System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/HIToolbox.framework/Versions/A/Headers/Events.h))
3. Rebuild and reinstall

### Running Without Auto-Start

If you don't want Snappy to start at login:

```bash
# Unload the LaunchAgent
launchctl unload ~/Library/LaunchAgents/com.snappy.agent.plist

# Run manually when needed
snappy
```

To re-enable auto-start:
```bash
launchctl load ~/Library/LaunchAgents/com.snappy.agent.plist
```

## Development Setup

For developers who want to contribute:

```bash
# Clone and enter directory
git clone https://github.com/yourusername/Snappy.git
cd Snappy

# Run in development mode
make run

# Or use Swift directly
swift run

# Build release
make build

# Clean build artifacts
make clean
```

## Getting Help

If you encounter issues:

1. Check the [README.md](readme.md) for usage information
2. Review [HOMEBREW_SETUP.md](HOMEBREW_SETUP.md) for publishing guidance
3. Check logs: `tail -f /tmp/snappy.out.log` and `/tmp/snappy.err.log`
4. Open an issue on GitHub with:
   - macOS version: `sw_vers`
   - Snappy version: `snappy --version`
   - Error logs from `/tmp/snappy.err.log`

## Security & Privacy

Snappy requires Accessibility permissions because it:
- Reads the position and size of windows
- Moves and resizes windows

Snappy:
- ✅ Runs entirely locally (no internet connection required)
- ✅ Does not collect or transmit any data
- ✅ Only listens on localhost (127.0.0.1) for HTTP API
- ✅ Open source - audit the code yourself!

The HTTP API (port 42424) is only accessible from your local machine, not from the network.

