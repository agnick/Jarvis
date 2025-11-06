import Foundation
import Carbon.HIToolbox

@MainActor
final class AppServicesFactory: ObservableObject {
    
    // MARK: - Services
    
    lazy var swiftDataContextManager: SwiftDataContextManager = {
        SwiftDataContextManager(models: [
            TaskItem.self,
            ClipboardEntry.self
        ])
    }()
    
    // MARK: - Factories
    
    lazy var tasksFactory: TasksFactory = {
        TasksFactoryImpl(swiftDataContextManager: swiftDataContextManager)
    }()
    
    lazy var hotkeyService: HotkeyService = {
        HotkeyServiceImpl()
    }()

    lazy var quickLauncherCoordinator: QuickLauncherCoordinator = {
        QuickLauncherCoordinatorImpl(viewModel: QuickLauncherViewModelImpl())
    }()

    // MARK: - Clipboard stack (SwiftData-backed)

    lazy var clipboardService: ClipboardHistoryService = {
        ClipboardHistoryServiceImpl(
            context: swiftDataContextManager.context,
            maxItems: 30,
            pollInterval: 0.5
        )
    }()

    lazy var clipboardViewModelImpl: ClipboardHistoryViewModelImpl = {
        ClipboardHistoryViewModelImpl(service: clipboardService)
    }()

    lazy var clipboardCoordinator: ClipboardCoordinator = {
        ClipboardCoordinatorImpl(viewModel: clipboardViewModelImpl)
    }()

    func registerClipboardHotkey() {
        // Cmd + Shift + V
        let keyCode = UInt32(kVK_ANSI_V)
        let modifiers = UInt32(cmdKey | shiftKey)
        let signature = OSType("CLPB".fourCharCodeValue)
        let id: UInt32 = 2

        hotkeyService.registerHotkey(
            keyCode: keyCode,
            modifiers: modifiers,
            signature: signature,
            id: id
        ) { [weak self] in
            Task { @MainActor in
                self?.clipboardCoordinator.toggleClipboard()
            }
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
