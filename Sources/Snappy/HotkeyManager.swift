import Carbon
import Foundation

/// Manages registration and dispatch of global hotkeys via Carbon APIs.
final class HotkeyManager {
    struct KeyCombo {
        let keyCode: UInt32
        let modifiers: UInt32

        init(keyCode: UInt32, modifiers: UInt32) {
            self.keyCode = keyCode
            self.modifiers = modifiers
        }
    }

    private var nextIdentifier: UInt32 = 1
    private var hotkeyRefs: [UInt32: EventHotKeyRef] = [:]
    private var callbacks: [UInt32: () -> Void] = [:]
    private var eventHandler: EventHandlerRef?

    init() {
        installHandler()
    }

    deinit {
        unregisterAll()
    }

    func register(combo: KeyCombo, action: @escaping () -> Void) {
        let hotkeyID = EventHotKeyID(signature: HotkeyManager.signature, id: nextIdentifier)
        var hotkeyRef: EventHotKeyRef?

        let status = RegisterEventHotKey(
            combo.keyCode,
            combo.modifiers,
            hotkeyID,
            GetApplicationEventTarget(),
            0,
            &hotkeyRef
        )

        guard status == noErr, let ref = hotkeyRef else {
            print("Failed to register hotkey for id \(nextIdentifier) (status: \(status))")
            return
        }

        callbacks[hotkeyID.id] = action
        hotkeyRefs[hotkeyID.id] = ref
        nextIdentifier += 1
    }

    private func installHandler() {
        guard eventHandler == nil else { return }
        var eventSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            hotkeyEventHandler,
            1,
            &eventSpec,
            UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
            &eventHandler
        )

        if status != noErr {
            print("Failed to install hotkey handler (status: \(status))")
        }
    }

    private func unregisterAll() {
        for (_, ref) in hotkeyRefs {
            UnregisterEventHotKey(ref)
        }
        hotkeyRefs.removeAll()
        callbacks.removeAll()

        if let handler = eventHandler {
            RemoveEventHandler(handler)
            eventHandler = nil
        }
    }

    fileprivate func handle(eventRef: EventRef?) -> OSStatus {
        guard let eventRef else { return noErr }
        var hotkeyID = EventHotKeyID()
        let status = GetEventParameter(
            eventRef,
            EventParamName(kEventParamDirectObject),
            EventParamType(typeEventHotKeyID),
            nil,
            MemoryLayout<EventHotKeyID>.size,
            nil,
            &hotkeyID
        )

        guard status == noErr else { return status }

        if let callback = callbacks[hotkeyID.id] {
            callback()
        }
        return noErr
    }

    private static let signature = OSType(fourCharCode: "SNAP")
}

private let hotkeyEventHandler: EventHandlerUPP = { _, event, userData -> OSStatus in
    guard
        let userData,
        let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue() as HotkeyManager?
    else {
        return noErr
    }
    return manager.handle(eventRef: event)
}

private extension OSType {
    init(fourCharCode string: String) {
        precondition(string.count == 4, "FourCharCode must be exactly 4 characters.")
        var value: UInt32 = 0
        for scalar in string.utf16 {
            value = (value << 8) | UInt32(scalar)
        }
        self = value
    }
}
