import Carbon
import Foundation

/// Provides runtime configuration for hotkeys and server options.
struct AppConfiguration {
    struct HotkeyMapping {
        let action: SnapAction
        let keyCode: UInt32

        init(action: SnapAction, keyCode: UInt32) {
            self.action = action
            self.keyCode = keyCode
        }
    }

    let httpPort: UInt16
    let defaultModifierFlags: UInt32
    let hotkeyMappings: [HotkeyMapping]

    static let `default` = AppConfiguration(
        httpPort: 42424,
        defaultModifierFlags: defaultModifiers,
        hotkeyMappings: [
            HotkeyMapping(action: .leftHalf, keyCode: UInt32(kVK_LeftArrow)),
            HotkeyMapping(action: .rightHalf, keyCode: UInt32(kVK_RightArrow)),
            HotkeyMapping(action: .topHalf, keyCode: UInt32(kVK_UpArrow)),
            HotkeyMapping(action: .bottomHalf, keyCode: UInt32(kVK_DownArrow)),
            HotkeyMapping(action: .maximize, keyCode: UInt32(kVK_Return)),
            HotkeyMapping(action: .centered, keyCode: UInt32(kVK_ANSI_C))
        ]
    )
}

private let defaultModifiers = UInt32(controlKey | optionKey | cmdKey)
