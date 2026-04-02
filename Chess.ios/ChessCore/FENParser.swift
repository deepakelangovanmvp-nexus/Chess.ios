import Foundation

// MARK: - FENParser

public enum FENParser {

    public static func board(from fen: String) throws -> Board {
        let parts = fen.split(separator: " ", omittingEmptySubsequences: false).map(String.init)
        guard parts.count >= 2 else { throw FENError.invalidFEN }

        var board = Board()

        // 1. Piece placement
        let rows = parts[0].split(separator: "/").map(String.init)
        guard rows.count == 8 else { throw FENError.invalidFEN }

        var sq = 56 // start at a8 (rank 7, file 0)
        for row in rows {
            var file = 0
            for ch in row {
                if let empty = ch.wholeNumberValue {
                    file += empty
                } else {
                    let piece = try piece(from: ch)
                    // Board is not directly writable via subscript;
                    // we use internal unsafe access via FEN helper
                    board.unsafeSetSquare(sq + file, piece: piece)
                    file += 1
                }
            }
            sq -= 8
        }

        // 2. Side to move
        switch parts[1] {
        case "w": board.unsafeSetSideToMove(.white)
        case "b": board.unsafeSetSideToMove(.black)
        default: throw FENError.invalidFEN
        }

        // 3. Castling rights
        var rights: CastlingRights = []
        let castling = parts.count > 2 ? parts[2] : "-"
        if castling != "-" {
            if castling.contains("K") { rights.insert(.whiteKingside) }
            if castling.contains("Q") { rights.insert(.whiteQueenside) }
            if castling.contains("k") { rights.insert(.blackKingside) }
            if castling.contains("q") { rights.insert(.blackQueenside) }
        }
        board.unsafeSetCastlingRights(rights)

        // 4. En passant
        let ep = parts.count > 3 ? parts[3] : "-"
        board.unsafeSetEnPassant(ep == "-" ? Square.none : (Square(algebraic: ep) ?? Square.none))

        // 5. Clocks
        let halfMove = parts.count > 4 ? Int(parts[4]) ?? 0 : 0
        let fullMove = parts.count > 5 ? Int(parts[5]) ?? 1 : 1
        board.unsafeSetClocks(half: halfMove, full: fullMove)

        return board
    }

    public static func fen(from board: Board) -> String {
        var result = ""

        // Piece placement (rank 8 first)
        for rank in stride(from: 7, through: 0, by: -1) {
            var empty = 0
            for file in 0..<8 {
                let sq = file + rank * 8
                if let piece = board[sq] {
                    if empty > 0 { result += "\(empty)"; empty = 0 }
                    result.append(piece.fenChar)
                } else {
                    empty += 1
                }
            }
            if empty > 0 { result += "\(empty)" }
            if rank > 0 { result += "/" }
        }

        result += " "
        result += board.sideToMove == .white ? "w" : "b"
        result += " "

        var castling = ""
        if board.castlingRights.contains(.whiteKingside)  { castling += "K" }
        if board.castlingRights.contains(.whiteQueenside) { castling += "Q" }
        if board.castlingRights.contains(.blackKingside)  { castling += "k" }
        if board.castlingRights.contains(.blackQueenside) { castling += "q" }
        result += castling.isEmpty ? "-" : castling
        result += " "
        result += board.enPassantSquare == Square.none ? "-" : board.enPassantSquare.algebraic
        result += " \(board.halfMoveClock) \(board.fullMoveNumber)"

        return result
    }

    // MARK: Private

    private static func piece(from char: Character) throws -> Piece {
        let isUpper = char.isUppercase
        let color: PieceColor = isUpper ? .white : .black
        switch char.lowercased() {
        case "p": return Piece(.pawn,   color)
        case "n": return Piece(.knight, color)
        case "b": return Piece(.bishop, color)
        case "r": return Piece(.rook,   color)
        case "q": return Piece(.queen,  color)
        case "k": return Piece(.king,   color)
        default: throw FENError.invalidPiece(char)
        }
    }
}

// MARK: - FENError

public enum FENError: Error, LocalizedError {
    case invalidFEN
    case invalidPiece(Character)

    public var errorDescription: String? {
        switch self {
        case .invalidFEN: return "Invalid FEN string"
        case .invalidPiece(let c): return "Unknown piece character: \(c)"
        }
    }
}
