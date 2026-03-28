import Foundation

class ChessAI {

    // Piece-square tables for positional evaluation
    private let pawnTable: [[Int]] = [
        [  0,  0,  0,  0,  0,  0,  0,  0],
        [ 50, 50, 50, 50, 50, 50, 50, 50],
        [ 10, 10, 20, 30, 30, 20, 10, 10],
        [  5,  5, 10, 25, 25, 10,  5,  5],
        [  0,  0,  0, 20, 20,  0,  0,  0],
        [  5, -5,-10,  0,  0,-10, -5,  5],
        [  5, 10, 10,-20,-20, 10, 10,  5],
        [  0,  0,  0,  0,  0,  0,  0,  0]
    ]

    private let knightTable: [[Int]] = [
        [-50,-40,-30,-30,-30,-30,-40,-50],
        [-40,-20,  0,  0,  0,  0,-20,-40],
        [-30,  0, 10, 15, 15, 10,  0,-30],
        [-30,  5, 15, 20, 20, 15,  5,-30],
        [-30,  0, 15, 20, 20, 15,  0,-30],
        [-30,  5, 10, 15, 15, 10,  5,-30],
        [-40,-20,  0,  5,  5,  0,-20,-40],
        [-50,-40,-30,-30,-30,-30,-40,-50]
    ]

    private let bishopTable: [[Int]] = [
        [-20,-10,-10,-10,-10,-10,-10,-20],
        [-10,  0,  0,  0,  0,  0,  0,-10],
        [-10,  0, 10, 10, 10, 10,  0,-10],
        [-10,  5,  5, 10, 10,  5,  5,-10],
        [-10,  0,  5, 10, 10,  5,  0,-10],
        [-10, 10, 10, 10, 10, 10, 10,-10],
        [-10,  5,  0,  0,  0,  0,  5,-10],
        [-20,-10,-10,-10,-10,-10,-10,-20]
    ]

    private let rookTable: [[Int]] = [
        [  0,  0,  0,  0,  0,  0,  0,  0],
        [  5, 10, 10, 10, 10, 10, 10,  5],
        [ -5,  0,  0,  0,  0,  0,  0, -5],
        [ -5,  0,  0,  0,  0,  0,  0, -5],
        [ -5,  0,  0,  0,  0,  0,  0, -5],
        [ -5,  0,  0,  0,  0,  0,  0, -5],
        [ -5,  0,  0,  0,  0,  0,  0, -5],
        [  0,  0,  0,  5,  5,  0,  0,  0]
    ]

    private let kingMiddleTable: [[Int]] = [
        [-30,-40,-40,-50,-50,-40,-40,-30],
        [-30,-40,-40,-50,-50,-40,-40,-30],
        [-30,-40,-40,-50,-50,-40,-40,-30],
        [-30,-40,-40,-50,-50,-40,-40,-30],
        [-20,-30,-30,-40,-40,-30,-30,-20],
        [-10,-20,-20,-20,-20,-20,-20,-10],
        [ 20, 20,  0,  0,  0,  0, 20, 20],
        [ 20, 30, 10,  0,  0, 10, 30, 20]
    ]

    func bestMove(board: Board, color: PieceColor, depth: Int,
                  enPassantTarget: Position?, castlingRights: CastlingRights) -> Move? {
        let moves = MoveValidator.allLegalMoves(for: color, board: board,
                                                 enPassantTarget: enPassantTarget,
                                                 castlingRights: castlingRights)
        guard !moves.isEmpty else { return nil }

        var bestScore = Int.min
        var bestMoves: [Move] = []

        for move in moves {
            var newBoard = board.copy()
            MoveValidator.applyMove(move, to: &newBoard)
            let newEP = move.moveType == .doublePawnPush
                ? Position(row: (move.from.row + move.to.row) / 2, col: move.from.col)
                : nil
            var newCR = castlingRights
            updateCastlingRights(&newCR, after: move)

            let score = -negamax(board: newBoard, color: color.opposite, depth: depth - 1,
                                 alpha: Int.min + 1, beta: Int.max - 1,
                                 enPassantTarget: newEP, castlingRights: newCR)
            if score > bestScore {
                bestScore = score
                bestMoves = [move]
            } else if score == bestScore {
                bestMoves.append(move)
            }
        }
        return bestMoves.randomElement()
    }

    private func negamax(board: Board, color: PieceColor, depth: Int,
                         alpha: Int, beta: Int,
                         enPassantTarget: Position?, castlingRights: CastlingRights) -> Int {
        if depth == 0 {
            return evaluate(board: board, color: color)
        }

        let moves = MoveValidator.allLegalMoves(for: color, board: board,
                                                 enPassantTarget: enPassantTarget,
                                                 castlingRights: castlingRights)
        if moves.isEmpty {
            if MoveValidator.isInCheck(color: color, board: board) {
                return -100000 + (4 - depth) * 100 // prefer shorter mates
            }
            return 0 // stalemate
        }

        var alpha = alpha
        let sortedMoves = moves.sorted { m1, m2 in
            moveOrderScore(m1) > moveOrderScore(m2)
        }

        for move in sortedMoves {
            var newBoard = board.copy()
            MoveValidator.applyMove(move, to: &newBoard)
            let newEP = move.moveType == .doublePawnPush
                ? Position(row: (move.from.row + move.to.row) / 2, col: move.from.col)
                : nil
            var newCR = castlingRights
            updateCastlingRights(&newCR, after: move)

            let score = -negamax(board: newBoard, color: color.opposite, depth: depth - 1,
                                 alpha: -beta, beta: -alpha,
                                 enPassantTarget: newEP, castlingRights: newCR)
            if score >= beta { return beta }
            if score > alpha { alpha = score }
        }
        return alpha
    }

    private func moveOrderScore(_ move: Move) -> Int {
        var score = 0
        if let captured = move.capturedPiece {
            score += captured.type.value - move.piece.type.value / 10
        }
        if move.moveType == .promotion { score += 800 }
        return score
    }

    private func evaluate(board: Board, color: PieceColor) -> Int {
        var score = 0
        for row in 0..<8 {
            for col in 0..<8 {
                guard let piece = board.squares[row][col] else { continue }
                let sign = piece.color == color ? 1 : -1
                score += sign * piece.type.value
                score += sign * positionalBonus(piece: piece, row: row, col: col)
            }
        }
        return score
    }

    private func positionalBonus(piece: Piece, row: Int, col: Int) -> Int {
        let r = piece.color == .white ? (7 - row) : row
        let c = col
        switch piece.type {
        case .pawn:   return pawnTable[r][c]
        case .knight: return knightTable[r][c]
        case .bishop: return bishopTable[r][c]
        case .rook:   return rookTable[r][c]
        case .queen:  return bishopTable[r][c] / 2
        case .king:   return kingMiddleTable[r][c]
        }
    }

    private func updateCastlingRights(_ cr: inout CastlingRights, after move: Move) {
        if move.piece.type == .king {
            if move.piece.color == .white { cr.whiteKingside = false; cr.whiteQueenside = false }
            else { cr.blackKingside = false; cr.blackQueenside = false }
        }
        if move.piece.type == .rook {
            if move.from == Position(row: 0, col: 0) { cr.whiteQueenside = false }
            if move.from == Position(row: 0, col: 7) { cr.whiteKingside = false }
            if move.from == Position(row: 7, col: 0) { cr.blackQueenside = false }
            if move.from == Position(row: 7, col: 7) { cr.blackKingside = false }
        }
        if move.to == Position(row: 0, col: 0) { cr.whiteQueenside = false }
        if move.to == Position(row: 0, col: 7) { cr.whiteKingside = false }
        if move.to == Position(row: 7, col: 0) { cr.blackQueenside = false }
        if move.to == Position(row: 7, col: 7) { cr.blackKingside = false }
    }
}
