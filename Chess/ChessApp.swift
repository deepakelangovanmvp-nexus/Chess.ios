import SwiftUI

@main
struct ChessApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(macOS)
        .defaultSize(width: 900, height: 650)
        #endif
    }
}
