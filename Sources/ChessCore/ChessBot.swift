import Foundation

// MARK: - Chess Bot (Minimax + Alpha-Beta)

public enum BotDifficulty: String, CaseIterable, Codable, Sendable {
    case beginner = "Beginner"
    case easy     = "Easy"
    case medium   = "Medium"

    var depth: Int {
        switch self {
        case .beginner: return 1
        case .easy:     return 2
        case .medium:   return 3
        }
    }
}

public struct ChessBot: Sendable {
    public let difficulty: BotDifficulty
    public let color: PieceColor

    public init(difficulty: BotDifficulty, color: PieceColor) {
        self.difficulty = difficulty
        self.color = color
    }

    // MARK: - Best move (async)

    public func bestMove(in state: GameState) async -> Move? {
        // Run the (potentially slow) sync search without blocking the current actor.
        // Callers (e.g. PlayViewModel) already dispatch from a background Task.
        return bestMoveSync(in: state)
    }

    public func bestMoveSync(in state: GameState) -> Move? {
        let moves = MoveGenerator.legalMoves(for: state.board, color: color)
        guard !moves.isEmpty else { return nil }

        let isMaximizing = color == .white
        var bestScore = isMaximizing ? Int.min : Int.max
        var bestMove: Move? = nil

        for move in moves {
            var copy = state
            copy.makeMove(move)
            let score = minimax(state: copy, depth: difficulty.depth - 1,
                                alpha: Int.min, beta: Int.max,
                                maximizing: !isMaximizing)
            if isMaximizing ? score > bestScore : score < bestScore {
                bestScore = score
                bestMove = move
            }
        }
        return bestMove
    }

    // MARK: - Minimax with alpha-beta

    private func minimax(state: GameState, depth: Int, alpha: Int, beta: Int, maximizing: Bool) -> Int {
        if depth == 0 || state.result != .ongoing {
            return evaluate(state: state)
        }

        let moves = MoveGenerator.legalMoves(for: state.board, color: state.board.sideToMove)
        if moves.isEmpty { return evaluate(state: state) }

        var a = alpha
        var b = beta

        if maximizing {
            var best = Int.min
            for move in moves {
                var copy = state
                copy.makeMove(move)
                let score = minimax(state: copy, depth: depth - 1, alpha: a, beta: b, maximizing: false)
                best = max(best, score)
                a = max(a, score)
                if b <= a { break }
            }
            return best
        } else {
            var best = Int.max
            for move in moves {
                var copy = state
                copy.makeMove(move)
                let score = minimax(state: copy, depth: depth - 1, alpha: a, beta: b, maximizing: true)
                best = min(best, score)
                b = min(b, score)
                if b <= a { break }
            }
            return best
        }
    }

    // MARK: - Static evaluation

    private func evaluate(state: GameState) -> Int {
        switch state.result {
        case .checkmate(let winner):
            return winner == .white ? 100000 : -100000
        case .stalemate, .drawByRepetition, .drawBy50MoveRule, .drawByInsufficientMaterial:
            return 0
        case .ongoing:
            break
        }
        return materialBalance(board: state.board) + positionalBonus(board: state.board)
    }

    private func materialBalance(board: Board) -> Int {
        var score = 0
        for sq in 0..<64 {
            guard let piece = board[sq] else { continue }
            let val = piece.type.materialValue
            score += piece.color == .white ? val : -val
        }
        return score
    }

    private func positionalBonus(board: Board) -> Int {
        var score = 0
        for sq in 0..<64 {
            guard let piece = board[sq] else { continue }
            let bonus = positionalValue(piece: piece, square: sq)
            score += piece.color == .white ? bonus : -bonus
        }
        return score
    }

    private func positionalValue(piece: Piece, square: Square) -> Int {
        let rank = piece.color == .white ? square.rank : 7 - square.rank
        let file = square.file
        let idx = rank * 8 + file

        switch piece.type {
        case .pawn:
            let table = [
                 0,  0,  0,  0,  0,  0,  0,  0,
                50, 50, 50, 50, 50, 50, 50, 50,
                10, 10, 20, 30, 30, 20, 10, 10,
                 5,  5, 10, 25, 25, 10,  5,  5,
                 0,  0,  0, 20, 20,  0,  0,  0,
                 5, -5,-10,  0,  0,-10, -5,  5,
                 5, 10, 10,-20,-20, 10, 10,  5,
                 0,  0,  0,  0,  0,  0,  0,  0
            ]
            return table[idx]
        case .knight:
            let table = [
                -50,-40,-30,-30,-30,-30,-40,-50,
                -40,-20,  0,  0,  0,  0,-20,-40,
                -30,  0, 10, 15, 15, 10,  0,-30,
                -30,  5, 15, 20, 20, 15,  5,-30,
                -30,  0, 15, 20, 20, 15,  0,-30,
                -30,  5, 10, 15, 15, 10,  5,-30,
                -40,-20,  0,  5,  5,  0,-20,-40,
                -50,-40,-30,-30,-30,-30,-40,-50
            ]
            return table[idx]
        case .bishop:
            let table = [
                -20,-10,-10,-10,-10,-10,-10,-20,
                -10,  0,  0,  0,  0,  0,  0,-10,
                -10,  0,  5, 10, 10,  5,  0,-10,
                -10,  5,  5, 10, 10,  5,  5,-10,
                -10,  0, 10, 10, 10, 10,  0,-10,
                -10, 10, 10, 10, 10, 10, 10,-10,
                -10,  5,  0,  0,  0,  0,  5,-10,
                -20,-10,-10,-10,-10,-10,-10,-20
            ]
            return table[idx]
        case .rook:
            let table = [
                 0,  0,  0,  0,  0,  0,  0,  0,
                 5, 10, 10, 10, 10, 10, 10,  5,
                -5,  0,  0,  0,  0,  0,  0, -5,
                -5,  0,  0,  0,  0,  0,  0, -5,
                -5,  0,  0,  0,  0,  0,  0, -5,
                -5,  0,  0,  0,  0,  0,  0, -5,
                -5,  0,  0,  0,  0,  0,  0, -5,
                 0,  0,  0,  5,  5,  0,  0,  0
            ]
            return table[idx]
        case .queen:
            let table = [
                -20,-10,-10, -5, -5,-10,-10,-20,
                -10,  0,  0,  0,  0,  0,  0,-10,
                -10,  0,  5,  5,  5,  5,  0,-10,
                 -5,  0,  5,  5,  5,  5,  0, -5,
                  0,  0,  5,  5,  5,  5,  0, -5,
                -10,  5,  5,  5,  5,  5,  0,-10,
                -10,  0,  5,  0,  0,  0,  0,-10,
                -20,-10,-10, -5, -5,-10,-10,-20
            ]
            return table[idx]
        case .king:
            let table = [
                -30,-40,-40,-50,-50,-40,-40,-30,
                -30,-40,-40,-50,-50,-40,-40,-30,
                -30,-40,-40,-50,-50,-40,-40,-30,
                -30,-40,-40,-50,-50,-40,-40,-30,
                -20,-30,-30,-40,-40,-30,-30,-20,
                -10,-20,-20,-20,-20,-20,-20,-10,
                 20, 20,  0,  0,  0,  0, 20, 20,
                 20, 30, 10,  0,  0, 10, 30, 20
            ]
            return table[idx]
        }
    }
}

// MARK: - Coach feedback

public struct CoachFeedback: Sendable {
    public enum Quality: String, Sendable {
        case excellent = "Excellent! 🌟"
        case good      = "Good move! ✓"
        case inaccuracy = "Inaccuracy ⚠️"
        case blunder   = "Blunder! ✗"
    }

    public let quality: Quality
    public let explanation: String
    public let suggestedMove: Move?
}

public struct CoachMode: Sendable {
    private let bot: ChessBot

    public init(botDifficulty: BotDifficulty = .medium) {
        // Coach always analyses as the side that just moved (opposite of current player)
        bot = ChessBot(difficulty: botDifficulty, color: .white) // color unused in eval
    }

    public func evaluate(stateBefore: GameState, movePlayedBy color: PieceColor, move: Move) -> CoachFeedback {
        let bestBot = ChessBot(difficulty: .medium, color: color)
        let suggested = bestBot.bestMoveSync(in: stateBefore)

        // Score before
        let scoreBefore = staticEval(stateBefore)

        // Score after player's move
        var stateAfterPlayer = stateBefore
        stateAfterPlayer.makeMove(move)
        let scoreAfterPlayer = staticEval(stateAfterPlayer)

        // Score after suggested move
        var scoreAfterSuggested = scoreBefore
        if let sug = suggested {
            var stateAfterSug = stateBefore
            stateAfterSug.makeMove(sug)
            scoreAfterSuggested = staticEval(stateAfterSug)
        }

        let sign = color == .white ? 1 : -1
        let playerDelta = (scoreAfterPlayer - scoreBefore) * sign
        let sugDelta    = (scoreAfterSuggested - scoreBefore) * sign
        let loss = sugDelta - playerDelta

        let quality: CoachFeedback.Quality
        let explanation: String
        if loss <= 0 {
            quality = .excellent
            explanation = "Best move in this position!"
        } else if loss < 50 {
            quality = .good
            explanation = "Solid play."
        } else if loss < 200 {
            quality = .inaccuracy
            explanation = "There was a stronger option."
        } else {
            quality = .blunder
            explanation = "This loses material or misses a tactic."
        }

        let showSuggested = loss >= 50 ? suggested : nil
        return CoachFeedback(quality: quality, explanation: explanation, suggestedMove: showSuggested)
    }

    private func staticEval(_ state: GameState) -> Int {
        var score = 0
        for sq in 0..<64 {
            if let p = state.board[sq] {
                score += p.color == .white ? p.type.materialValue : -p.type.materialValue
            }
        }
        return score
    }
}
