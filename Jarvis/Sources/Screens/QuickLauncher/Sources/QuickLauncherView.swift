import SwiftUI

struct QuickLauncherView: View {
    @State private var command = ""

    var body: some View {
        VStack {
            TextField("Enter command here...", text: $command)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
        }
        .frame(width: 500)
        .background(.ultraThinMaterial)
    }
}

