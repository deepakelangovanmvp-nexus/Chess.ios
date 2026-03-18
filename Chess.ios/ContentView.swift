import SwiftUI

struct ContentView: View {
    var body: some View {
        #if os(iOS)
        iOSTabView()
        #else
        macOSSidebarView()
        #endif
    }
}

// MARK: - iOS Tab View

struct iOSTabView: View {
    var body: some View {
        TabView {
            LearnView()
                .tabItem { Label("Learn", systemImage: "book.fill") }

            PuzzlesView()
                .tabItem { Label("Puzzles", systemImage: "puzzlepiece.fill") }

            PlayView()
                .tabItem { Label("Play", systemImage: "chessboard") }

            UserProgressView()
                .tabItem { Label("Progress", systemImage: "chart.bar.fill") }
        }
    }
}

// MARK: - macOS Sidebar View

enum AppSection: String, CaseIterable, Identifiable {
    case learn    = "Learn"
    case puzzles  = "Puzzles"
    case play     = "Play"
    case progress = "Progress"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .learn:    return "book.fill"
        case .puzzles:  return "puzzlepiece.fill"
        case .play:     return "chessboard"
        case .progress: return "chart.bar.fill"
        }
    }
}

struct macOSSidebarView: View {
    @State private var selectedSection: AppSection = .learn

    var body: some View {
        NavigationSplitView {
            List(AppSection.allCases, selection: $selectedSection) { section in
                Label(section.rawValue, systemImage: section.icon)
                    .tag(section)
            }
            .navigationTitle("Chess.ios")
            .listStyle(.sidebar)
        } detail: {
            switch selectedSection {
            case .learn:    LearnView()
            case .puzzles:  PuzzlesView()
            case .play:     PlayView()
            case .progress: UserProgressView()
            }
        }
    }
}

#Preview {
    ContentView()
}
