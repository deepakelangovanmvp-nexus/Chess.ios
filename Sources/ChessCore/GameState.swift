import Foundation

// MARK: - Game State

public enum GameResult: Equatable, Sendable {
    case ongoing
    case checkmate(winner: PieceColor)
    case stalemate
    case drawByRepetition
    case drawBy50MoveRule
    case drawByInsufficientMaterial
}

public struct GameState: Sendable {
    public private(set) var board: Board
    public private(set) var moveHistory: [Move]
    public private(set) var positionHistory: [String]   // FEN positions
    public private(set) var result: GameResult

    public init(fen: String = Board.startFEN) {
        board = (try? FENParser.board(from: fen)) ?? Board()
        moveHistory = []
        positionHistory = []
        result = .ongoing
    }

    public var currentFEN: String { FENParser.fen(from: board) }

    // MARK: Make move

    @discardableResult
    public mutating func makeMove(_ move: Move) -> Bool {
        guard result == .ongoing else { return false }
        let legal = MoveGenerator.legalMoves(for: board, color: board.sideToMove)
        guard legal.contains(move) else { return false }

        positionHistory.append(FENParser.fen(from: board))
        board.apply(move)
        moveHistory.append(move)
        result = computeResult()
        return true
    }

    // MARK: Undo

    public mutating func undoLastMove() {
        guard !moveHistory.isEmpty else { return }
        moveHistory.removeLast()
        positionHistory.removeLast()
        board.undoLastMove()
        result = .ongoing
    }

    // MARK: Legal moves for current position

    public func legalMoves(from square: Square) -> [Move] {
        guard result == .ongoing else { return [] }
        return MoveGenerator.legalMoves(for: board, from: square)
    }

    public var allLegalMoves: [Move] {
        MoveGenerator.legalMoves(for: board, color: board.sideToMove)
    }

    // MARK: Result computation

    private func computeResult() -> GameResult {
        let side = board.sideToMove

        if MoveGenerator.isCheckmate(board, color: side) {
            return .checkmate(winner: side.opposite)
        }
        if MoveGenerator.isStalemate(board, color: side) {
            return .stalemate
        }
        if board.halfMoveClock >= 100 {
            return .drawBy50MoveRule
        }
        if isInsufficientMaterial() {
            return .drawByInsufficientMaterial
        }
        // Simple repetition check (3-fold)
        let currentFENBase = fenBase(FENParser.fen(from: board))
        let count = positionHistory.filter { fenBase($0) == currentFENBase }.count
        if count >= 2 {
            return .drawByRepetition
        }
        return .ongoing
    }

    private func fenBase(_ fen: String) -> String {
        // Use only board + side + castling + ep for repetition
        fen.split(separator: " ").prefix(4).joined(separator: " ")
    }

    private func isInsufficientMaterial() -> Bool {
        var pieces: [Piece] = []
        for sq in 0..<64 {
            if let p = board[sq] { pieces.append(p) }
        }
        // K vs K
        if pieces.count == 2 { return true }
        // K+B vs K or K+N vs K
        if pieces.count == 3 {
            let minor = pieces.first(where: { $0.type != .king })
            return minor?.type == .bishop || minor?.type == .knight
        }
        // K+B vs K+B same color squares
        if pieces.count == 4 {
            let bishops = pieces.filter { $0.type == .bishop }
            if bishops.count == 2 {
                var bishopSquares: [Square] = []
                for sq in 0..<64 {
                    if let p = board[sq], p.type == .bishop { bishopSquares.append(sq) }
                }
                if bishopSquares.count == 2 {
                    let sameColor = (bishopSquares[0].file + bishopSquares[0].rank) % 2 ==
                                    (bishopSquares[1].file + bishopSquares[1].rank) % 2
                    return sameColor
                }
            }
        }
        return false
    }
}
