import Foundation

// MARK: - MoveGenerator

public struct MoveGenerator {

    // Returns all pseudo-legal moves (may leave king in check)
    public static func pseudoLegalMoves(for board: Board, color: PieceColor) -> [Move] {
        var moves: [Move] = []
        for sq in 0..<64 {
            guard let piece = board[sq], piece.color == color else { continue }
            moves.append(contentsOf: movesForPiece(on: board, at: sq, piece: piece))
        }
        return moves
    }

    // Returns only legal moves (king not in check after move)
    public static func legalMoves(for board: Board, color: PieceColor) -> [Move] {
        pseudoLegalMoves(for: board, color: color).filter { move in
            var copy = board
            copy.apply(move)
            return !isInCheck(copy, color: color)
        }
    }

    public static func legalMoves(for board: Board, from square: Square) -> [Move] {
        guard let piece = board[square] else { return [] }
        let color = piece.color
        return movesForPiece(on: board, at: square, piece: piece).filter { move in
            var copy = board
            copy.apply(move)
            return !isInCheck(copy, color: color)
        }
    }

    // MARK: Check / Checkmate / Stalemate

    public static func isInCheck(_ board: Board, color: PieceColor) -> Bool {
        let kingSq = board.kingSquare(for: color)
        guard kingSq != Square.none else { return false }
        return isSquareAttacked(board, square: kingSq, by: color.opposite)
    }

    public static func isCheckmate(_ board: Board, color: PieceColor) -> Bool {
        isInCheck(board, color: color) && legalMoves(for: board, color: color).isEmpty
    }

    public static func isStalemate(_ board: Board, color: PieceColor) -> Bool {
        !isInCheck(board, color: color) && legalMoves(for: board, color: color).isEmpty
    }

    public static func isSquareAttacked(_ board: Board, square: Square, by attacker: PieceColor) -> Bool {
        // Check all attacker's pseudo-legal moves to see if any reach the square
        for sq in 0..<64 {
            guard let piece = board[sq], piece.color == attacker else { continue }
            let moves = movesForPiece(on: board, at: sq, piece: piece)
            if moves.contains(where: { $0.to == square }) { return true }
        }
        return false
    }

    // MARK: - Move generation per piece

    private static func movesForPiece(on board: Board, at sq: Square, piece: Piece) -> [Move] {
        switch piece.type {
        case .pawn:   return pawnMoves(board: board, sq: sq, color: piece.color)
        case .knight: return leaperMoves(board: board, sq: sq, color: piece.color, deltas: knightDeltas)
        case .bishop: return sliderMoves(board: board, sq: sq, color: piece.color, directions: bishopDirs)
        case .rook:   return sliderMoves(board: board, sq: sq, color: piece.color, directions: rookDirs)
        case .queen:  return sliderMoves(board: board, sq: sq, color: piece.color, directions: queenDirs)
        case .king:   return kingMoves(board: board, sq: sq, color: piece.color)
        }
    }

    // MARK: Pawn

    private static func pawnMoves(board: Board, sq: Square, color: PieceColor) -> [Move] {
        var moves: [Move] = []
        let dir = color == .white ? 1 : -1
        let startRank = color == .white ? 1 : 6
        let promoRank = color == .white ? 7 : 0

        // Single push
        if let ahead = sq.offset(df: 0, dr: dir), board[ahead] == nil {
            if ahead.rank == promoRank {
                for pt in [PieceType.queen, .rook, .bishop, .knight] {
                    moves.append(Move(from: sq, to: ahead, promotion: pt))
                }
            } else {
                moves.append(Move(from: sq, to: ahead))
            }
            // Double push from start rank
            if sq.rank == startRank, let doubleAhead = ahead.offset(df: 0, dr: dir), board[doubleAhead] == nil {
                moves.append(Move(from: sq, to: doubleAhead))
            }
        }

        // Captures (including en passant)
        for df in [-1, 1] {
            guard let target = sq.offset(df: df, dr: dir) else { continue }
            let isEnPassant = target == board.enPassantSquare && board.enPassantSquare != Square.none
            if let occupant = board[target], occupant.color != color {
                if target.rank == promoRank {
                    for pt in [PieceType.queen, .rook, .bishop, .knight] {
                        moves.append(Move(from: sq, to: target, promotion: pt))
                    }
                } else {
                    moves.append(Move(from: sq, to: target))
                }
            } else if isEnPassant {
                moves.append(Move(from: sq, to: target))
            }
        }
        return moves
    }

    // MARK: Leaper (knight, king captures)

    private static let knightDeltas = [(-2,-1),(-2,1),(-1,-2),(-1,2),(1,-2),(1,2),(2,-1),(2,1)]

    private static func leaperMoves(board: Board, sq: Square, color: PieceColor, deltas: [(Int,Int)]) -> [Move] {
        var moves: [Move] = []
        for (df, dr) in deltas {
            guard let target = sq.offset(df: df, dr: dr) else { continue }
            if let occupant = board[target], occupant.color == color { continue }
            moves.append(Move(from: sq, to: target))
        }
        return moves
    }

    // MARK: Slider (bishop, rook, queen)

    private static let bishopDirs = [(-1,-1),(-1,1),(1,-1),(1,1)]
    private static let rookDirs   = [(-1,0),(1,0),(0,-1),(0,1)]
    private static let queenDirs  = [(-1,-1),(-1,1),(1,-1),(1,1),(-1,0),(1,0),(0,-1),(0,1)]

    private static func sliderMoves(board: Board, sq: Square, color: PieceColor, directions: [(Int,Int)]) -> [Move] {
        var moves: [Move] = []
        for (df, dr) in directions {
            var cur = sq
            while true {
                guard let next = cur.offset(df: df, dr: dr) else { break }
                if let occupant = board[next] {
                    if occupant.color != color { moves.append(Move(from: sq, to: next)) }
                    break
                }
                moves.append(Move(from: sq, to: next))
                cur = next
            }
        }
        return moves
    }

    // MARK: King (including castling)

    private static let kingDeltas = [(-1,-1),(-1,0),(-1,1),(0,-1),(0,1),(1,-1),(1,0),(1,1)]

    private static func kingMoves(board: Board, sq: Square, color: PieceColor) -> [Move] {
        var moves = leaperMoves(board: board, sq: sq, color: color, deltas: kingDeltas)

        // Castling
        guard !isSquareAttacked(board, square: sq, by: color.opposite) else { return moves }

        if color == .white {
            // Kingside
            if board.castlingRights.contains(.whiteKingside),
               board[5] == nil, board[6] == nil,
               !isSquareAttacked(board, square: 5, by: .black),
               !isSquareAttacked(board, square: 6, by: .black) {
                moves.append(Move(from: 4, to: 6))
            }
            // Queenside
            if board.castlingRights.contains(.whiteQueenside),
               board[3] == nil, board[2] == nil, board[1] == nil,
               !isSquareAttacked(board, square: 3, by: .black),
               !isSquareAttacked(board, square: 2, by: .black) {
                moves.append(Move(from: 4, to: 2))
            }
        } else {
            // Kingside
            if board.castlingRights.contains(.blackKingside),
               board[61] == nil, board[62] == nil,
               !isSquareAttacked(board, square: 61, by: .white),
               !isSquareAttacked(board, square: 62, by: .white) {
                moves.append(Move(from: 60, to: 62))
            }
            // Queenside
            if board.castlingRights.contains(.blackQueenside),
               board[59] == nil, board[58] == nil, board[57] == nil,
               !isSquareAttacked(board, square: 59, by: .white),
               !isSquareAttacked(board, square: 58, by: .white) {
                moves.append(Move(from: 60, to: 58))
            }
        }
        return moves
    }
}
