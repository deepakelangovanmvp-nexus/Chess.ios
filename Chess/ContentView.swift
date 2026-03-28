import SwiftUI

struct ContentView: View {
    @StateObject private var game = GameManager()

    var body: some View {
        ZStack {
            ChessTheme.background.ignoresSafeArea()

            #if os(macOS)
            macLayout
            #else
            iOSLayout
            #endif

            PromotionView(game: game)
        }
    }

    // MARK: - iOS Layout (stacked)
    var iOSLayout: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            if isLandscape {
                HStack(spacing: 16) {
                    BoardView(game: game)
                        .frame(maxHeight: geometry.size.height - 20)
                    ScrollView {
                        VStack(spacing: 12) {
                            GameInfoView(game: game)
                            ControlsView(game: game)
                        }
                        .frame(maxWidth: 300)
                    }
                }
                .padding(10)
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        Spacer().frame(height: 4)
                        BoardView(game: game)
                            .padding(.horizontal, 8)
                        GameInfoView(game: game)
                            .padding(.horizontal, 16)
                        ControlsView(game: game)
                            .padding(.horizontal, 16)
                        Spacer().frame(height: 16)
                    }
                }
            }
        }
    }

    // MARK: - Mac Layout (side by side)
    var macLayout: some View {
        HStack(alignment: .top, spacing: 20) {
            BoardView(game: game)
                .frame(minWidth: 400, maxWidth: 600)
                .padding(.leading, 20)
                .padding(.vertical, 20)

            VStack(spacing: 12) {
                GameInfoView(game: game)
                ControlsView(game: game)
                Spacer()
            }
            .frame(minWidth: 250, maxWidth: 320)
            .padding(.trailing, 20)
            .padding(.vertical, 20)
        }
    }
}
