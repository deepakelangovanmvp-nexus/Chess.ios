import SwiftUI

// MARK: - Puzzles View Model

@MainActor
final class PuzzlesViewModel: ObservableObject {
    @Published var puzzles: [Puzzle] = []
    @Published var selectedDifficulty: String = "All"

    let difficulties = ["All", "Easy", "Medium", "Hard"]

    init() {
        puzzles = ContentLoader.shared.puzzles
    }

    var filteredPuzzles: [Puzzle] {
        guard selectedDifficulty != "All" else { return puzzles }
        return puzzles.filter { $0.difficulty == selectedDifficulty }
    }

    func attempt(for puzzle: Puzzle) -> PuzzleAttempt? {
        ProgressStore.shared.puzzleAttempt(for: puzzle.id)
    }
}

// MARK: - Puzzles Root View

struct PuzzlesView: View {
    @StateObject private var vm = PuzzlesViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Difficulty picker
                Picker("Difficulty", selection: $vm.selectedDifficulty) {
                    ForEach(vm.difficulties, id: \.self) { d in Text(d).tag(d) }
                }
                .pickerStyle(.segmented)
                .padding()

                List(vm.filteredPuzzles) { puzzle in
                    NavigationLink(destination: PuzzleDetailView(puzzle: puzzle)) {
                        PuzzleRowView(puzzle: puzzle, attempt: vm.attempt(for: puzzle))
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Puzzles")
        }
    }
}

// MARK: - Puzzle Row

struct PuzzleRowView: View {
    let puzzle: Puzzle
    let attempt: PuzzleAttempt?

    var body: some View {
        HStack(spacing: 12) {
            // Status icon
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: statusIcon)
                    .foregroundStyle(statusColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(puzzle.title)
                    .font(.headline)
                HStack {
                    Text(puzzle.theme)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("·")
                        .foregroundStyle(.secondary)
                    Text(puzzle.difficulty)
                        .font(.caption)
                        .foregroundStyle(difficultyColor)
                }
                if let attempt = attempt {
                    Text("\(attempt.attempts) attempt\(attempt.attempts == 1 ? "" : "s")")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }

    private var statusIcon: String {
        guard let attempt = attempt else { return "circle" }
        return attempt.solvedCorrectly ? "checkmark.circle.fill" : "xmark.circle"
    }

    private var statusColor: Color {
        guard let attempt = attempt else { return .secondary }
        return attempt.solvedCorrectly ? .green : .orange
    }

    private var difficultyColor: Color {
        switch puzzle.difficulty {
        case "Easy": return .green
        case "Medium": return .orange
        case "Hard": return .red
        default: return .secondary
        }
    }
}

// MARK: - Puzzle Detail View

struct PuzzleDetailView: View {
    let puzzle: Puzzle

    @State private var gameState: GameState = GameState()
    @State private var selectedSquare: Square? = nil
    @State private var legalTargets: [Square] = []
    @State private var lastMove: [Square] = []
    @State private var moveIndex: Int = 0
    @State private var feedbackMessage: String? = nil
    @State private var isCorrect: Bool? = nil
    @State private var isSolved: Bool = false
    @State private var showExplanation: Bool = false

    private var sideToMove: PieceColor { puzzle.sideToMove == "w" ? .white : .black }
    private var isFlipped: Bool { puzzle.sideToMove == "b" }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(puzzle.theme)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.accentColor.opacity(0.15), in: Capsule())
                        Text(puzzle.difficulty)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(difficultyBadgeColor.opacity(0.15), in: Capsule())
                    }
                    Text("Find the best move for \(sideToMove == .white ? "White ♙" : "Black ♟").")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                // Board
                BoardView(
                    board: gameState.board,
                    selectedSquare: selectedSquare,
                    legalMoveTargets: legalTargets,
                    highlightedSquares: lastMove,
                    flipped: isFlipped,
                    onSquareTapped: handleTap
                )
                .padding(.horizontal, 8)
                .frame(maxHeight: 400)

                // Feedback
                if let msg = feedbackMessage {
                    HStack {
                        Image(systemName: isCorrect == true ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(isCorrect == true ? .green : .red)
                        Text(msg)
                            .font(.subheadline)
                    }
                    .padding(12)
                    .background((isCorrect == true ? Color.green : Color.red).opacity(0.1),
                                 in: RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)
                    .transition(.scale.combined(with: .opacity))
                }

                // Explanation (shown after solving)
                if showExplanation {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Explanation", systemImage: "lightbulb.fill")
                            .font(.headline)
                            .foregroundStyle(.yellow)
                        Text(puzzle.explanation)
                            .font(.body)
                    }
                    .padding(14)
                    .background(Color.yellow.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }

                // Action buttons
                HStack {
                    if !isSolved {
                        Button("Retry") { reset() }
                            .buttonStyle(.bordered)
                    }
                    Spacer()
                    if isSolved && !showExplanation {
                        Button("Show Explanation") { withAnimation { showExplanation = true } }
                            .buttonStyle(.bordered)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .padding(.top)
        }
        .navigationTitle(puzzle.title)
        .navigationBarTitleDisplayMode(.inline)
        .animation(.easeInOut(duration: 0.2), value: feedbackMessage)
        .onAppear { reset() }
    }

    // MARK: - Tap handling

    private func handleTap(_ sq: Square) {
        guard !isSolved else { return }
        guard gameState.board.sideToMove == sideToMove || moveIndex > 0 else { return }
        // Only move for the puzzle's side on odd moves; opponent moves are auto-played
        let isPlayerTurn = (moveIndex % 2 == 0)
        guard isPlayerTurn else { return }

        if let selected = selectedSquare {
            let targets = gameState.legalMoves(from: selected).filter { $0.to == sq }
            if !targets.isEmpty {
                let move = targets.first!
                processMove(move)
            } else if gameState.board[sq]?.color == sideToMove {
                selectedSquare = sq
                legalTargets = gameState.legalMoves(from: sq).map(\.to)
            } else {
                selectedSquare = nil
                legalTargets = []
            }
        } else if gameState.board[sq]?.color == sideToMove {
            selectedSquare = sq
            legalTargets = gameState.legalMoves(from: sq).map(\.to)
        }
    }

    private func processMove(_ move: Move) {
        let expectedUCI = puzzle.solution[moveIndex]
        selectedSquare = nil
        legalTargets = []

        if move.uci == expectedUCI {
            gameState.makeMove(move)
            lastMove = [move.from, move.to]
            moveIndex += 1

            if moveIndex >= puzzle.solution.count {
                // Puzzle solved
                isSolved = true
                feedbackMessage = "Correct! Puzzle solved 🎉"
                isCorrect = true
                ProgressStore.shared.recordPuzzle(puzzle.id, solved: true)
                ProgressStore.shared.recordActivity()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation { showExplanation = true }
                }
            } else {
                // Auto-play opponent's response
                feedbackMessage = "Correct! ✓"
                isCorrect = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    playOpponentMove()
                }
            }
        } else {
            feedbackMessage = "Not the best move — try again!"
            isCorrect = false
            ProgressStore.shared.recordPuzzle(puzzle.id, solved: false)
        }
    }

    private func playOpponentMove() {
        guard moveIndex < puzzle.solution.count else { return }
        let uci = puzzle.solution[moveIndex]
        if let move = Move(uci: uci) {
            gameState.makeMove(move)
            lastMove = [move.from, move.to]
            moveIndex += 1
            feedbackMessage = nil
        }
    }

    private func reset() {
        gameState = GameState(fen: puzzle.fen)
        selectedSquare = nil
        legalTargets = []
        lastMove = []
        moveIndex = 0
        feedbackMessage = nil
        isCorrect = nil
        isSolved = false
        showExplanation = false
    }

    private var difficultyBadgeColor: Color {
        switch puzzle.difficulty {
        case "Easy": return .green
        case "Medium": return .orange
        case "Hard": return .red
        default: return .secondary
        }
    }
}

#Preview {
    PuzzlesView()
}
