import AppKit
import Foundation

let version = "1.0.0"

// Handle command-line arguments
if CommandLine.arguments.contains("--version") || CommandLine.arguments.contains("-v") {
    print("Snappy v\(version)")
    exit(0)
}

if CommandLine.arguments.contains("--help") || CommandLine.arguments.contains("-h") {
    print("""
    Snappy v\(version) - macOS Window Snapping Utility
    
    Usage:
      snappy              Start the Snappy service
      snappy --version    Display version information
      snappy --help       Display this help message
    
    Hotkeys (Ctrl+Opt+Cmd + key):
      Left Arrow          Snap window to left half
      Right Arrow         Snap window to right half
      Up Arrow            Snap window to top half
      Down Arrow          Snap window to bottom half
      Return              Maximize window
      C                   Center window
    
    HTTP API:
      POST http://localhost:42424/snap/{action}
      Actions: left, right, top, bottom, maximize, center
    """)
    exit(0)
}

// Set up NSApplication to receive system events
let nsApp = NSApplication.shared
nsApp.setActivationPolicy(.accessory) // Background app, no dock icon

let app = AppContext()
app.start()

// Keep the app running
nsApp.run()
