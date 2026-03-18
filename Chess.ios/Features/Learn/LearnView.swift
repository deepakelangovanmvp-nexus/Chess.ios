import SwiftUI

// MARK: - Learn View Model

@MainActor
final class LearnViewModel: ObservableObject {
    @Published var lessons: [Lesson] = []

    init() {
        lessons = ContentLoader.shared.lessons
    }

    func completionFraction(for lesson: Lesson) -> Double {
        let completion = ProgressStore.shared.lessonCompletion(for: lesson.id)
        let total = lesson.sections.count
        guard total > 0 else { return 0 }
        return Double(completion?.sectionsCompleted ?? 0) / Double(total)
    }

    func isComplete(lesson: Lesson) -> Bool {
        completionFraction(for: lesson) >= 1.0
    }
}

// MARK: - Learn View (tab root)

struct LearnView: View {
    @StateObject private var vm = LearnViewModel()

    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedLessons.keys.sorted(), id: \.self) { category in
                    Section(header: Text(category).font(.headline)) {
                        ForEach(groupedLessons[category] ?? []) { lesson in
                            NavigationLink(destination: LessonDetailView(lesson: lesson)) {
                                LessonRowView(
                                    lesson: lesson,
                                    fraction: vm.completionFraction(for: lesson),
                                    isComplete: vm.isComplete(lesson: lesson)
                                )
                            }
                        }
                    }
                }
            }
            .navigationTitle("Learn")
            .listStyle(.insetGrouped)
        }
    }

    private var groupedLessons: [String: [Lesson]] {
        Dictionary(grouping: vm.lessons, by: \.category)
    }
}

// MARK: - Lesson Row

struct LessonRowView: View {
    let lesson: Lesson
    let fraction: Double
    let isComplete: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 2)
                    .frame(width: 42, height: 42)
                Circle()
                    .trim(from: 0, to: fraction)
                    .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .frame(width: 42, height: 42)
                    .rotationEffect(.degrees(-90))
                if isComplete {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.green)
                } else {
                    Text("♟")
                        .font(.title3)
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(lesson.title)
                    .font(.headline)
                Text(lesson.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                HStack {
                    Label(lesson.difficulty, systemImage: "chart.bar")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("·")
                        .foregroundStyle(.secondary)
                    Label("\(lesson.estimatedMinutes) min", systemImage: "clock")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Lesson Detail View

struct LessonDetailView: View {
    let lesson: Lesson
    @State private var currentSectionIndex: Int = 0
    @State private var checkpointState: CheckpointState? = nil
    @Environment(\.dismiss) private var dismiss

    private var currentSection: LessonSection {
        lesson.sections[currentSectionIndex]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Progress indicator
                HStack {
                    ForEach(0..<lesson.sections.count, id: \.self) { i in
                        Capsule()
                            .fill(i <= currentSectionIndex ? Color.accentColor : Color.secondary.opacity(0.3))
                            .frame(height: 4)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // Section title
                Text(currentSection.title)
                    .font(.title2.bold())
                    .padding(.horizontal)

                // Body text
                Text(currentSection.body)
                    .font(.body)
                    .padding(.horizontal)

                // Optional board display
                if let fen = currentSection.boardFEN, currentSection.checkpoint == nil {
                    if let board = try? FENParser.board(from: fen) {
                        BoardView(board: board)
                            .padding(.horizontal, 16)
                            .frame(maxHeight: 340)
                    }
                }

                // Checkpoint (interactive)
                if let checkpoint = currentSection.checkpoint {
                    CheckpointView(checkpoint: checkpoint, state: $checkpointState)
                        .padding(.horizontal)
                }

                Spacer(minLength: 20)

                // Navigation
                navigationButtons
                    .padding(.horizontal)
                    .padding(.bottom, 24)
            }
        }
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { checkpointState = nil }
        .onChange(of: currentSectionIndex) { _, _ in checkpointState = nil }
    }

    private var canAdvance: Bool {
        if let checkpoint = currentSection.checkpoint {
            if let state = checkpointState {
                return state.solved
            }
            return false
        }
        return true
    }

    private var navigationButtons: some View {
        HStack {
            if currentSectionIndex > 0 {
                Button(action: { withAnimation { currentSectionIndex -= 1 } }) {
                    Label("Previous", systemImage: "chevron.left")
                }
                .buttonStyle(.bordered)
            }
            Spacer()
            if currentSectionIndex < lesson.sections.count - 1 {
                Button(action: {
                    markProgress()
                    withAnimation { currentSectionIndex += 1 }
                }) {
                    Label("Next", systemImage: "chevron.right")
                        .labelStyle(.titleAndIcon)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canAdvance)
            } else {
                Button(action: {
                    markProgress()
                    dismiss()
                }) {
                    Label("Complete!", systemImage: "checkmark.circle.fill")
                        .labelStyle(.titleAndIcon)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canAdvance)
            }
        }
    }

    private func markProgress() {
        ProgressStore.shared.markLesson(lesson.id, sectionIndex: currentSectionIndex, totalSections: lesson.sections.count)
        ProgressStore.shared.recordActivity()
    }
}

// MARK: - Checkpoint State

struct CheckpointState {
    var solved: Bool
    var message: String
}

// MARK: - Checkpoint View

struct CheckpointView: View {
    let checkpoint: LessonSection.Checkpoint
    @Binding var state: CheckpointState?

    @State private var gameState: GameState = GameState()
    @State private var selectedSquare: Square? = nil
    @State private var legalTargets: [Square] = []
    @State private var lastMove: [Square] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Interactive Checkpoint", systemImage: "puzzlepiece.fill")
                .font(.headline)
                .foregroundStyle(.accentColor)

            Text("Find the best move for \(checkpoint.sideToMove == "w" ? "White" : "Black").")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            BoardView(
                board: gameState.board,
                selectedSquare: selectedSquare,
                legalMoveTargets: legalTargets,
                highlightedSquares: lastMove,
                flipped: checkpoint.sideToMove == "b",
                onSquareTapped: handleTap
            )
            .frame(maxHeight: 300)

            if let state = state {
                HStack {
                    Image(systemName: state.solved ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(state.solved ? .green : .red)
                    Text(state.message)
                        .font(.subheadline)
                }
                .padding(10)
                .background((state.solved ? Color.green : Color.red).opacity(0.12),
                             in: RoundedRectangle(cornerRadius: 8))
            }

            if state?.solved == false {
                Button("Try Again") {
                    reset()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(14)
        .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
        .onAppear { reset() }
    }

    private func reset() {
        gameState = GameState(fen: checkpoint.fen)
        selectedSquare = nil
        legalTargets = []
        lastMove = []
        state = nil
    }

    private func handleTap(_ sq: Square) {
        guard state == nil else { return }

        let side: PieceColor = checkpoint.sideToMove == "w" ? .white : .black
        guard gameState.board.sideToMove == side else { return }

        if let selected = selectedSquare {
            let targets = gameState.legalMoves(from: selected).filter { $0.to == sq }
            if !targets.isEmpty {
                let move = targets.first!
                let moveUCI = move.uci
                gameState.makeMove(move)
                lastMove = [move.from, move.to]
                selectedSquare = nil
                legalTargets = []

                if checkpoint.correctMoves.contains(moveUCI) {
                    state = CheckpointState(solved: true, message: checkpoint.explanation)
                } else {
                    state = CheckpointState(solved: false, message: "Not quite — try again!")
                }
            } else if gameState.board[sq]?.color == side {
                selectedSquare = sq
                legalTargets = gameState.legalMoves(from: sq).map(\.to)
            } else {
                selectedSquare = nil
                legalTargets = []
            }
        } else if gameState.board[sq]?.color == side {
            selectedSquare = sq
            legalTargets = gameState.legalMoves(from: sq).map(\.to)
        }
    }
}

#Preview {
    LearnView()
}
