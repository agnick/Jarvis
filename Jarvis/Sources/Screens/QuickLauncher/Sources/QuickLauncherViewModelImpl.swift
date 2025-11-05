import SwiftUI

final class QuickLauncherViewModelImpl: QuickLauncherViewModel {
    @Published var command: String = ""
    
    func clearCommand() {
        command = ""
    }
}
