import SwiftUI

// MARK: - Play View Model

@MainActor
final class PlayViewModel: ObservableObject {
    @Published var gameState: GameState = GameState()
    @Published var selectedSquare: Square? = nil
    @Published var legalTargets: [Square] = []
    @Published var lastMoveSquares: [Square] = []
    @Published var isThinking: Bool = false
    @Published var promotionPending: Move? = nil
    @Published var coachFeedback: CoachFeedback? = nil
    @Published var showCoachFeedback: Bool = false
    @Published var showNewGameSheet: Bool = false
    @Published var boardFlipped: Bool = false

    var humanColor: PieceColor = .white
    var difficulty: BotDifficulty = .easy
    var coachModeEnabled: Bool = true

    private var bot: ChessBot = ChessBot(difficulty: .easy, color: .black)
    private var coach: CoachMode = CoachMode()

    var result: GameResult { gameState.result }
    var isGameOver: Bool { result != .ongoing }
    var currentFEN: String { gameState.currentFEN }

    var resultMessage: String {
        switch result {
        case .ongoing: return ""
        case .checkmate(let winner):
            return winner == humanColor ? "You win! 🎉" : "Computer wins!"
        case .stalemate: return "Stalemate – Draw"
        case .drawByRepetition: return "Draw by Repetition"
        case .drawBy50MoveRule: return "Draw – 50 Move Rule"
        case .drawByInsufficientMaterial: return "Draw – Insufficient Material"
        }
    }

    var isInCheck: Bool {
        MoveGenerator.isInCheck(gameState.board, color: gameState.board.sideToMove)
    }

    // MARK: New game

    func newGame(humanColor: PieceColor, difficulty: BotDifficulty, coachMode: Bool) {
        self.humanColor = humanColor
        self.difficulty = difficulty
        self.coachModeEnabled = coachMode
        bot = ChessBot(difficulty: difficulty, color: humanColor.opposite)
        coach = CoachMode(botDifficulty: difficulty)
        boardFlipped = humanColor == .black
        gameState = GameState()
        selectedSquare = nil
        legalTargets = []
        lastMoveSquares = []
        coachFeedback = nil
        showCoachFeedback = false

        // If human plays black, bot moves first
        if humanColor == .black {
            Task { await triggerBotMove() }
        }
    }

    // MARK: Square tapped

    func squareTapped(_ sq: Square) {
        guard !isGameOver, !isThinking else { return }
        guard gameState.board.sideToMove == humanColor else { return }

        if let selected = selectedSquare {
            // Try to make a move
            let possibleMoves = gameState.legalMoves(from: selected).filter { $0.to == sq }
            if !possibleMoves.isEmpty {
                // Check if promotion
                if possibleMoves.contains(where: { $0.promotion != nil }) {
                    promotionPending = Move(from: selected, to: sq)
                    selectedSquare = nil
                    legalTargets = []
                    return
                }
                executeHumanMove(possibleMoves.first!)
            } else if gameState.board[sq]?.color == humanColor {
                // Reselect
                selectedSquare = sq
                legalTargets = gameState.legalMoves(from: sq).map(\.to)
            } else {
                selectedSquare = nil
                legalTargets = []
            }
        } else {
            if gameState.board[sq]?.color == humanColor {
                selectedSquare = sq
                legalTargets = gameState.legalMoves(from: sq).map(\.to)
            }
        }
    }

    func selectPromotion(_ type: PieceType) {
        guard let pending = promotionPending else { return }
        let move = Move(from: pending.from, to: pending.to, promotion: type)
        promotionPending = nil
        executeHumanMove(move)
    }

    private func executeHumanMove(_ move: Move) {
        let stateBefore = gameState
        let success = gameState.makeMove(move)
        guard success else { return }

        lastMoveSquares = [move.from, move.to]
        selectedSquare = nil
        legalTargets = []

        if coachModeEnabled {
            let feedback = coach.evaluate(stateBefore: stateBefore, movePlayedBy: humanColor, move: move)
            coachFeedback = feedback
            showCoachFeedback = true
        }

        if !isGameOver {
            Task { await triggerBotMove() }
        }
    }

    private func triggerBotMove() async {
        guard !isGameOver else { return }
        isThinking = true
        // Offload computation to a background task so the UI remains responsive
        let move = await Task.detached(priority: .userInitiated) { [bot = self.bot, state = self.gameState] in
            bot.bestMoveSync(in: state)
        }.value
        if let move {
            gameState.makeMove(move)
            lastMoveSquares = [move.from, move.to]
        }
        isThinking = false
    }

    func undoLastMove() {
        guard !isThinking else { return }
        // Undo both bot and human moves
        if gameState.moveHistory.count >= 2 {
            gameState.undoLastMove()
            gameState.undoLastMove()
        } else if !gameState.moveHistory.isEmpty {
            gameState.undoLastMove()
        }
        selectedSquare = nil
        legalTargets = []
        coachFeedback = nil
        showCoachFeedback = false
        lastMoveSquares = gameState.moveHistory.suffix(1).flatMap { [$0.from, $0.to] }
    }
}

// MARK: - Play View

struct PlayView: View {
    @StateObject private var vm = PlayViewModel()
    @State private var showingSetup = true

    var body: some View {
        NavigationStack {
            ZStack {
                if showingSetup {
                    NewGameSetupView { humanColor, difficulty, coachMode in
                        vm.newGame(humanColor: humanColor, difficulty: difficulty, coachMode: coachMode)
                        showingSetup = false
                    }
                    .navigationTitle("Play vs Computer")
                } else {
                    gameBoard
                        .navigationTitle("Play")
                        .toolbar { toolbarItems }
                }
            }
        }
    }

    // MARK: Game board UI

    private var gameBoard: some View {
        VStack(spacing: 12) {
            // Status bar
            statusBar

            // Board
            BoardView(
                board: vm.gameState.board,
                selectedSquare: vm.selectedSquare,
                legalMoveTargets: vm.legalTargets,
                highlightedSquares: vm.lastMoveSquares,
                flipped: vm.boardFlipped,
                onSquareTapped: { sq in vm.squareTapped(sq) }
            )
            .padding(.horizontal, 8)
            .overlay {
                if vm.isThinking {
                    SwiftUI.ProgressView("Computer thinking…")
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }

            // Coach feedback
            if vm.showCoachFeedback, let feedback = vm.coachFeedback {
                CoachFeedbackView(feedback: feedback) {
                    withAnimation { vm.showCoachFeedback = false }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding(.horizontal)
            }

            Spacer(minLength: 8)
        }
        .animation(.easeInOut(duration: 0.25), value: vm.showCoachFeedback)
        .sheet(item: $vm.promotionPending) { pending in
            PromotionPickerView(color: vm.humanColor) { type in
                vm.selectPromotion(type)
            }
            .presentationDetents([.height(200)])
        }
        .sheet(isPresented: $vm.showNewGameSheet) {
            NewGameSetupView { humanColor, difficulty, coachMode in
                vm.newGame(humanColor: humanColor, difficulty: difficulty, coachMode: coachMode)
                vm.showNewGameSheet = false
            }
        }
        .alert(vm.resultMessage, isPresented: .constant(vm.isGameOver && !vm.resultMessage.isEmpty)) {
            Button("New Game") { vm.showNewGameSheet = true }
            Button("OK", role: .cancel) {}
        }
    }

    private var statusBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(turnText)
                    .font(.headline)
                if vm.isInCheck && !vm.isGameOver {
                    Text("Check!")
                        .font(.caption)
                        .foregroundStyle(.red)
                        .bold()
                }
            }
            Spacer()
            if vm.isThinking {
                Label("Thinking…", systemImage: "cpu")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.top, 4)
    }

    private var turnText: String {
        if vm.isGameOver { return vm.resultMessage }
        if vm.isThinking { return "Computer is thinking…" }
        return vm.gameState.board.sideToMove == vm.humanColor ? "Your turn" : "Computer's turn"
    }

    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("New Game") { vm.showNewGameSheet = true }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Undo", systemImage: "arrow.uturn.backward") { vm.undoLastMove() }
                .disabled(vm.gameState.moveHistory.isEmpty || vm.isThinking)
        }
    }
}

// MARK: - New Game Setup

struct NewGameSetupView: View {
    var onStart: (PieceColor, BotDifficulty, Bool) -> Void

    @State private var selectedColor: PieceColor = .white
    @State private var selectedDifficulty: BotDifficulty = .easy
    @State private var coachMode: Bool = true

    var body: some View {
        Form {
            Section("Play As") {
                Picker("Color", selection: $selectedColor) {
                    Label("White", systemImage: "circle").tag(PieceColor.white)
                    Label("Black", systemImage: "circle.fill").tag(PieceColor.black)
                }
                .pickerStyle(.segmented)
            }

            Section("Difficulty") {
                Picker("Difficulty", selection: $selectedDifficulty) {
                    ForEach(BotDifficulty.allCases, id: \.self) { d in
                        Text(d.rawValue).tag(d)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Coach Mode") {
                Toggle("Show move feedback", isOn: $coachMode)
                Text("After each of your moves, the app will evaluate your choice and suggest improvements.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section {
                Button {
                    onStart(selectedColor, selectedDifficulty, coachMode)
                } label: {
                    HStack {
                        Spacer()
                        Text("Start Game")
                            .font(.headline)
                        Spacer()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

// MARK: - Coach Feedback View

struct CoachFeedbackView: View {
    let feedback: CoachFeedback
    let onDismiss: () -> Void

    var qualityColor: Color {
        switch feedback.quality {
        case .excellent: return .green
        case .good:      return .blue
        case .inaccuracy: return .orange
        case .blunder:   return .red
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 3)
                .fill(qualityColor)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 4) {
                Text(feedback.quality.rawValue)
                    .font(.headline)
                    .foregroundStyle(qualityColor)
                Text(feedback.explanation)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                if let sug = feedback.suggestedMove {
                    Text("Better: \(sug.uci)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Promotion Picker

struct PromotionPickerView: View {
    let color: PieceColor
    let onSelect: (PieceType) -> Void

    let types: [PieceType] = [.queen, .rook, .bishop, .knight]

    var body: some View {
        VStack(spacing: 12) {
            Text("Promote Pawn")
                .font(.headline)
                .padding(.top)
            HStack(spacing: 20) {
                ForEach(types, id: \.self) { type in
                    Button(action: { onSelect(type) }) {
                        Text(Piece(type, color).symbolString)
                            .font(.system(size: 48))
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Move is Identifiable for sheet

extension Move: Identifiable {
    public var id: String { uci }
}

#Preview {
    PlayView()
}
