import Foundation

struct MoveValidator {

    // MARK: - Public Interface

    static func legalMoves(for position: Position, board: Board,
                           enPassantTarget: Position?, castlingRights: CastlingRights) -> [Move] {
        guard let piece = board.piece(at: position) else { return [] }
        let pseudo = pseudoLegalMoves(for: position, piece: piece, board: board,
                                      enPassantTarget: enPassantTarget, castlingRights: castlingRights)
        return pseudo.filter { move in
            var testBoard = board.copy()
            applyMove(move, to: &testBoard)
            return !isInCheck(color: piece.color, board: testBoard)
        }
    }

    static func allLegalMoves(for color: PieceColor, board: Board,
                              enPassantTarget: Position?, castlingRights: CastlingRights) -> [Move] {
        var moves: [Move] = []
        for row in 0..<8 {
            for col in 0..<8 {
                let pos = Position(row: row, col: col)
                if let piece = board.piece(at: pos), piece.color == color {
                    moves.append(contentsOf: legalMoves(for: pos, board: board,
                                                        enPassantTarget: enPassantTarget,
                                                        castlingRights: castlingRights))
                }
            }
        }
        return moves
    }

    static func isInCheck(color: PieceColor, board: Board) -> Bool {
        guard let kingPos = board.findKing(color: color) else { return false }
        return isSquareAttacked(kingPos, by: color.opposite, board: board)
    }

    static func isCheckmate(color: PieceColor, board: Board,
                            enPassantTarget: Position?, castlingRights: CastlingRights) -> Bool {
        guard isInCheck(color: color, board: board) else { return false }
        return allLegalMoves(for: color, board: board,
                             enPassantTarget: enPassantTarget, castlingRights: castlingRights).isEmpty
    }

    static func isStalemate(color: PieceColor, board: Board,
                            enPassantTarget: Position?, castlingRights: CastlingRights) -> Bool {
        guard !isInCheck(color: color, board: board) else { return false }
        return allLegalMoves(for: color, board: board,
                             enPassantTarget: enPassantTarget, castlingRights: castlingRights).isEmpty
    }

    static func isInsufficientMaterial(board: Board) -> Bool {
        let white = board.allPieces(of: .white)
        let black = board.allPieces(of: .black)
        if white.count == 1 && black.count == 1 { return true }
        if white.count == 1 && black.count == 2 {
            if let p = black.first(where: { $0.1.type != .king }),
               (p.1.type == .bishop || p.1.type == .knight) { return true }
        }
        if black.count == 1 && white.count == 2 {
            if let p = white.first(where: { $0.1.type != .king }),
               (p.1.type == .bishop || p.1.type == .knight) { return true }
        }
        return false
    }

    // MARK: - Move Application

    static func applyMove(_ move: Move, to board: inout Board) {
        board.setPiece(nil, at: move.from)
        var movedPiece = move.piece
        if move.moveType == .promotion, let promoType = move.promotionType {
            movedPiece = Piece(type: promoType, color: move.piece.color)
        }
        board.setPiece(movedPiece, at: move.to)

        if move.moveType == .enPassant {
            let capturedRow = move.piece.color == .white ? move.to.row - 1 : move.to.row + 1
            board.setPiece(nil, at: Position(row: capturedRow, col: move.to.col))
        }
        if move.moveType == .castleKingside {
            let row = move.from.row
            let rook = board.piece(at: Position(row: row, col: 7))
            board.setPiece(nil, at: Position(row: row, col: 7))
            board.setPiece(rook, at: Position(row: row, col: 5))
        }
        if move.moveType == .castleQueenside {
            let row = move.from.row
            let rook = board.piece(at: Position(row: row, col: 0))
            board.setPiece(nil, at: Position(row: row, col: 0))
            board.setPiece(rook, at: Position(row: row, col: 3))
        }
    }

    // MARK: - Attack Detection

    static func isSquareAttacked(_ position: Position, by color: PieceColor, board: Board) -> Bool {
        let pawnDir = color == .white ? -1 : 1
        for dc in [-1, 1] {
            let p = Position(row: position.row + pawnDir, col: position.col + dc)
            if p.isValid, let pc = board.piece(at: p), pc.color == color, pc.type == .pawn { return true }
        }
        let knightOffsets = [(-2,-1),(-2,1),(-1,-2),(-1,2),(1,-2),(1,2),(2,-1),(2,1)]
        for (dr, dc) in knightOffsets {
            let p = Position(row: position.row + dr, col: position.col + dc)
            if p.isValid, let pc = board.piece(at: p), pc.color == color, pc.type == .knight { return true }
        }
        for dr in -1...1 {
            for dc in -1...1 {
                if dr == 0 && dc == 0 { continue }
                let p = Position(row: position.row + dr, col: position.col + dc)
                if p.isValid, let pc = board.piece(at: p), pc.color == color, pc.type == .king { return true }
            }
        }
        for (dr, dc) in [(-1,-1),(-1,1),(1,-1),(1,1)] {
            if checkSliding(from: position, dr: dr, dc: dc, color: color, types: [.bishop, .queen], board: board) { return true }
        }
        for (dr, dc) in [(-1,0),(1,0),(0,-1),(0,1)] {
            if checkSliding(from: position, dr: dr, dc: dc, color: color, types: [.rook, .queen], board: board) { return true }
        }
        return false
    }

    private static func checkSliding(from pos: Position, dr: Int, dc: Int,
                                     color: PieceColor, types: [PieceType], board: Board) -> Bool {
        var r = pos.row + dr, c = pos.col + dc
        while r >= 0 && r < 8 && c >= 0 && c < 8 {
            if let pc = board.piece(at: Position(row: r, col: c)) {
                return pc.color == color && types.contains(pc.type)
            }
            r += dr; c += dc
        }
        return false
    }

    // MARK: - Pseudo-Legal Move Generation

    private static func pseudoLegalMoves(for position: Position, piece: Piece, board: Board,
                                         enPassantTarget: Position?, castlingRights: CastlingRights) -> [Move] {
        switch piece.type {
        case .pawn:   return pawnMoves(from: position, piece: piece, board: board, enPassantTarget: enPassantTarget)
        case .knight: return knightMoves(from: position, piece: piece, board: board)
        case .bishop: return slidingMoves(from: position, piece: piece, board: board, dirs: [(-1,-1),(-1,1),(1,-1),(1,1)])
        case .rook:   return slidingMoves(from: position, piece: piece, board: board, dirs: [(-1,0),(1,0),(0,-1),(0,1)])
        case .queen:  return slidingMoves(from: position, piece: piece, board: board, dirs: [(-1,-1),(-1,1),(1,-1),(1,1),(-1,0),(1,0),(0,-1),(0,1)])
        case .king:   return kingMoves(from: position, piece: piece, board: board, castlingRights: castlingRights)
        }
    }

    private static func pawnMoves(from pos: Position, piece: Piece, board: Board, enPassantTarget: Position?) -> [Move] {
        var moves: [Move] = []
        let dir = piece.color == .white ? 1 : -1
        let startRow = piece.color == .white ? 1 : 6
        let promoRow = piece.color == .white ? 7 : 0

        let oneF = Position(row: pos.row + dir, col: pos.col)
        if oneF.isValid && board.piece(at: oneF) == nil {
            if oneF.row == promoRow {
                for pt in [PieceType.queen, .rook, .bishop, .knight] {
                    moves.append(Move(from: pos, to: oneF, piece: piece, promotionType: pt, moveType: .promotion))
                }
            } else {
                moves.append(Move(from: pos, to: oneF, piece: piece, moveType: .normal))
                if pos.row == startRow {
                    let twoF = Position(row: pos.row + 2 * dir, col: pos.col)
                    if board.piece(at: twoF) == nil {
                        moves.append(Move(from: pos, to: twoF, piece: piece, moveType: .doublePawnPush))
                    }
                }
            }
        }
        for dc in [-1, 1] {
            let cap = Position(row: pos.row + dir, col: pos.col + dc)
            guard cap.isValid else { continue }
            if let target = board.piece(at: cap), target.color != piece.color {
                if cap.row == promoRow {
                    for pt in [PieceType.queen, .rook, .bishop, .knight] {
                        moves.append(Move(from: pos, to: cap, piece: piece, capturedPiece: target, promotionType: pt, moveType: .promotion))
                    }
                } else {
                    moves.append(Move(from: pos, to: cap, piece: piece, capturedPiece: target, moveType: .normal))
                }
            }
            if let ep = enPassantTarget, cap == ep {
                let cpPos = Position(row: pos.row, col: cap.col)
                let cpPiece = board.piece(at: cpPos)
                moves.append(Move(from: pos, to: cap, piece: piece, capturedPiece: cpPiece, moveType: .enPassant))
            }
        }
        return moves
    }

    private static func knightMoves(from pos: Position, piece: Piece, board: Board) -> [Move] {
        var moves: [Move] = []
        for (dr, dc) in [(-2,-1),(-2,1),(-1,-2),(-1,2),(1,-2),(1,2),(2,-1),(2,1)] {
            let to = Position(row: pos.row + dr, col: pos.col + dc)
            guard to.isValid else { continue }
            if let target = board.piece(at: to) {
                if target.color != piece.color {
                    moves.append(Move(from: pos, to: to, piece: piece, capturedPiece: target, moveType: .normal))
                }
            } else {
                moves.append(Move(from: pos, to: to, piece: piece, moveType: .normal))
            }
        }
        return moves
    }

    private static func slidingMoves(from pos: Position, piece: Piece, board: Board, dirs: [(Int, Int)]) -> [Move] {
        var moves: [Move] = []
        for (dr, dc) in dirs {
            var r = pos.row + dr, c = pos.col + dc
            while r >= 0 && r < 8 && c >= 0 && c < 8 {
                let to = Position(row: r, col: c)
                if let target = board.piece(at: to) {
                    if target.color != piece.color {
                        moves.append(Move(from: pos, to: to, piece: piece, capturedPiece: target, moveType: .normal))
                    }
                    break
                }
                moves.append(Move(from: pos, to: to, piece: piece, moveType: .normal))
                r += dr; c += dc
            }
        }
        return moves
    }

    private static func kingMoves(from pos: Position, piece: Piece, board: Board, castlingRights: CastlingRights) -> [Move] {
        var moves: [Move] = []
        for dr in -1...1 {
            for dc in -1...1 {
                if dr == 0 && dc == 0 { continue }
                let to = Position(row: pos.row + dr, col: pos.col + dc)
                guard to.isValid else { continue }
                if let target = board.piece(at: to) {
                    if target.color != piece.color {
                        moves.append(Move(from: pos, to: to, piece: piece, capturedPiece: target, moveType: .normal))
                    }
                } else {
                    moves.append(Move(from: pos, to: to, piece: piece, moveType: .normal))
                }
            }
        }
        // Castling
        let enemy = piece.color.opposite
        if piece.color == .white && pos == Position(row: 0, col: 4) {
            if castlingRights.whiteKingside && board.piece(at: Position(row: 0, col: 5)) == nil
                && board.piece(at: Position(row: 0, col: 6)) == nil
                && board.piece(at: Position(row: 0, col: 7))?.type == .rook
                && !isSquareAttacked(Position(row: 0, col: 4), by: enemy, board: board)
                && !isSquareAttacked(Position(row: 0, col: 5), by: enemy, board: board)
                && !isSquareAttacked(Position(row: 0, col: 6), by: enemy, board: board) {
                moves.append(Move(from: pos, to: Position(row: 0, col: 6), piece: piece, moveType: .castleKingside))
            }
            if castlingRights.whiteQueenside && board.piece(at: Position(row: 0, col: 3)) == nil
                && board.piece(at: Position(row: 0, col: 2)) == nil
                && board.piece(at: Position(row: 0, col: 1)) == nil
                && board.piece(at: Position(row: 0, col: 0))?.type == .rook
                && !isSquareAttacked(Position(row: 0, col: 4), by: enemy, board: board)
                && !isSquareAttacked(Position(row: 0, col: 3), by: enemy, board: board)
                && !isSquareAttacked(Position(row: 0, col: 2), by: enemy, board: board) {
                moves.append(Move(from: pos, to: Position(row: 0, col: 2), piece: piece, moveType: .castleQueenside))
            }
        }
        if piece.color == .black && pos == Position(row: 7, col: 4) {
            if castlingRights.blackKingside && board.piece(at: Position(row: 7, col: 5)) == nil
                && board.piece(at: Position(row: 7, col: 6)) == nil
                && board.piece(at: Position(row: 7, col: 7))?.type == .rook
                && !isSquareAttacked(Position(row: 7, col: 4), by: enemy, board: board)
                && !isSquareAttacked(Position(row: 7, col: 5), by: enemy, board: board)
                && !isSquareAttacked(Position(row: 7, col: 6), by: enemy, board: board) {
                moves.append(Move(from: pos, to: Position(row: 7, col: 6), piece: piece, moveType: .castleKingside))
            }
            if castlingRights.blackQueenside && board.piece(at: Position(row: 7, col: 3)) == nil
                && board.piece(at: Position(row: 7, col: 2)) == nil
                && board.piece(at: Position(row: 7, col: 1)) == nil
                && board.piece(at: Position(row: 7, col: 0))?.type == .rook
                && !isSquareAttacked(Position(row: 7, col: 4), by: enemy, board: board)
                && !isSquareAttacked(Position(row: 7, col: 3), by: enemy, board: board)
                && !isSquareAttacked(Position(row: 7, col: 2), by: enemy, board: board) {
                moves.append(Move(from: pos, to: Position(row: 7, col: 2), piece: piece, moveType: .castleQueenside))
            }
        }
        return moves
    }
}
