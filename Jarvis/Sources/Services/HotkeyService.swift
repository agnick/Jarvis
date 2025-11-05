import AppKit
import Carbon.HIToolbox

protocol HotkeyService {
    func registerHotkey(action: @escaping () -> Void)
}

final class HotkeyServiceImpl: HotkeyService {
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private var action: (() -> Void)?

    func registerHotkey(action: @escaping () -> Void) {
        self.action = action

        let modifierFlags: UInt32 = UInt32(cmdKey)
        let keyCode: UInt32 = UInt32(kVK_Space)

        var hotKeyID = EventHotKeyID(signature: OSType("QLCH".fourCharCodeValue), id: UInt32(1))

        RegisterEventHotKey(keyCode, modifierFlags, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)

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

                if hkCom.id == 1,
                   let userData = userData {
                    let instance = Unmanaged<HotkeyServiceImpl>
                        .fromOpaque(userData)
                        .takeUnretainedValue()
                    instance.action?()
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

private extension String {
    var fourCharCodeValue: FourCharCode {
        var result: FourCharCode = 0
        for char in utf16 {
            result = (result << 8) + FourCharCode(char)
        }
        return result
    }
}
