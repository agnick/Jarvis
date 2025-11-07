import AppKit
import Carbon.HIToolbox

protocol HotkeyService {
    func registerHotkey(action: @escaping () -> Void)
    func registerHotkey(keyCode: UInt32, modifiers: UInt32, signature: OSType, id: UInt32, action: @escaping () -> Void)
}

final class HotkeyServiceImpl: HotkeyService {
    private var hotKeyRefs: [UInt32: EventHotKeyRef?] = [:]
    private var actions: [UInt32: () -> Void] = [:]
    private var eventHandler: EventHandlerRef?

    func registerHotkey(action: @escaping () -> Void) {
        // Default: Cmd+Option+J (existing behavior)
        let modifierFlags: UInt32 = UInt32(cmdKey) | UInt32(optionKey)
        let keyCode: UInt32 = UInt32(kVK_ANSI_J)
        let signature = OSType("QLCH".fourCharCodeValue)
        registerHotkey(keyCode: keyCode, modifiers: modifierFlags, signature: signature, id: 1, action: action)
    }

    func registerHotkey(keyCode: UInt32, modifiers: UInt32, signature: OSType, id: UInt32, action: @escaping () -> Void) {
        actions[id] = action

        var hotKeyRef: EventHotKeyRef?
        let hotKeyID = EventHotKeyID(signature: signature, id: id)
        RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
        hotKeyRefs[id] = hotKeyRef

        if eventHandler == nil {
            var eventType = EventTypeSpec(
                eventClass: OSType(kEventClassKeyboard),
                eventKind: UInt32(kEventHotKeyPressed)
            )

            InstallEventHandler(
                GetApplicationEventTarget(),
                { (_, theEvent, userData) -> OSStatus in
                    var hkCom = EventHotKeyID()
                    GetEventParameter(
                        theEvent,
                        EventParamName(kEventParamDirectObject),
                        EventParamType(typeEventHotKeyID),
                        nil,
                        MemoryLayout<EventHotKeyID>.size,
                        nil,
                        &hkCom
                    )

                    if let userData = userData {
                        let instance = Unmanaged<HotkeyServiceImpl>
                            .fromOpaque(userData)
                            .takeUnretainedValue()
                        instance.actions[hkCom.id]?()
                    }
                    return noErr
                },
                1,
                &eventType,
                UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
                &eventHandler
            )
        }
    }
}

private extension String {
    var fourCharCodeValue: FourCharCode {
        var result: FourCharCode = 0
        for char in utf16 {
            result = (result << 8) + FourCharCode(char)
        }
        return result
    }
}

