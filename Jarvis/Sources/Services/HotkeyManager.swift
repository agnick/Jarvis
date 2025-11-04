import AppKit
import Carbon.HIToolbox
import SwiftUI

final class HotkeyManager {
    static let shared = HotkeyManager()

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?

    func registerHotkey() {
        // Cmd + Space
        let modifierFlags: UInt32 = UInt32(cmdKey)
        let keyCode: UInt32 = UInt32(kVK_Space)

        let hotKeyID = EventHotKeyID(
            signature: OSType("QLCH".fourCharCodeValue),
            id: UInt32(1)
        )

        RegisterEventHotKey(
            keyCode,
            modifierFlags,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        InstallEventHandler(
            GetApplicationEventTarget(),
            { (nextHandler, theEvent, userData) -> OSStatus in
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
                
                if hkCom.id == 1 {
                    DispatchQueue.main.async {
                        QuickLauncherController.shared.toggleLauncher()
                    }
                }
                
                return noErr
            },
            1,
            &eventType,
            nil,
            &eventHandler
        )
    }
}

private extension String {
    var fourCharCodeValue: FourCharCode {
        var result: FourCharCode = 0
        for character in utf16 {
            result = (result << 8) + FourCharCode(character)
        }
        return result
    }
}
