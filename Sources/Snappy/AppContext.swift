import AppKit
import Carbon
import Foundation

/// Coordinates the hotkey system, window operations, and the HTTP interface.
final class AppContext: @unchecked Sendable {
    private let snapService = SnapService()
    private let hotkeyManager = HotkeyManager()
    private lazy var httpServer = HttpServer(port: configuration.httpPort) { [weak self] action in
        self?.handleSnapRequest(action)
    }

    private let configuration: AppConfiguration

    init(configuration: AppConfiguration = .default) {
        self.configuration = configuration
    }

    func start() {
        checkAccessibilityPermissions()
        registerHotkeys()
        httpServer.start()
        print("Snappy backend running. Press Ctrl+C to stop.")
    }
    
    private func checkAccessibilityPermissions() {
        let trusted = AXIsProcessTrusted()
        if !trusted {
            print("⚠️  Snappy requires Accessibility permissions to control windows.")
            print("📋 To enable:")
            print("   1. Press any hotkey (Ctrl+Opt+Cmd + Arrow) to trigger the permission dialog")
            print("   2. Click 'Open System Settings'")
            print("   3. Enable Snappy in Privacy & Security > Accessibility")
            print("   4. Press the hotkey again to start using Snappy")
            print("")
            
            // Optionally open System Settings directly
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                    NSWorkspace.shared.open(url)
                }
            }
        } else {
            print("✓ Accessibility permissions granted")
        }
    }

    private func registerHotkeys() {
        let modifierFlags = configuration.defaultModifierFlags
        for mapping in configuration.hotkeyMappings {
            let combo = HotkeyManager.KeyCombo(keyCode: mapping.keyCode, modifiers: modifierFlags)
            hotkeyManager.register(combo: combo) { [weak self] in
                self?.snapService.perform(mapping.action)
            }
        }
    }

    private func handleSnapRequest(_ action: SnapAction) {
        snapService.perform(action)
    }
}
