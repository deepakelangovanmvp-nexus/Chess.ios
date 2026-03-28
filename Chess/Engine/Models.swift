import Foundation

// MARK: - Piece Types

enum PieceType: String, CaseIterable, Codable {
    case king, queen, rook, bishop, knight, pawn

    var value: Int {
        switch self {
        case .pawn: return 100
        case .knight: return 320
        case .bishop: return 330
        case .rook: return 500
        case .queen: return 900
        case .king: return 20000
        }
    }

    var symbol: String {
        switch self {
        case .king: return "K"
        case .queen: return "Q"
        case .rook: return "R"
        case .bishop: return "B"
        case .knight: return "N"
        case .pawn: return ""
        }
    }
}

enum PieceColor: String, CaseIterable, Codable {
    case white, black

    var opposite: PieceColor {
        self == .white ? .black : .white
    }

    var displayName: String {
        rawValue.capitalized
    }
}

// MARK: - Piece

struct Piece: Equatable, Hashable, Codable {
    let type: PieceType
    let color: PieceColor

    var symbol: String {
        switch (type, color) {
        case (.king, .white): return "♔"
        case (.queen, .white): return "♕"
        case (.rook, .white): return "♖"
        case (.bishop, .white): return "♗"
        case (.knight, .white): return "♘"
        case (.pawn, .white): return "♙"
        case (.king, .black): return "♚"
        case (.queen, .black): return "♛"
        case (.rook, .black): return "♜"
        case (.bishop, .black): return "♝"
        case (.knight, .black): return "♞"
        case (.pawn, .black): return "♟"
        }
    }
}

// MARK: - Position

struct Position: Equatable, Hashable, Codable {
    let row: Int
    let col: Int

    var isValid: Bool {
        row >= 0 && row < 8 && col >= 0 && col < 8
    }

    var algebraic: String {
        guard isValid else { return "??" }
        let file = String(Character(UnicodeScalar(97 + col)!))
        let rank = "\(row + 1)"
        return "\(file)\(rank)"
    }

    init(row: Int, col: Int) {
        self.row = row
        self.col = col
    }

    init?(algebraic: String) {
        guard algebraic.count == 2 else { return nil }
        let chars = Array(algebraic)
        guard let colValue = chars[0].asciiValue, colValue >= 97, colValue <= 104 else { return nil }
        guard let rowValue = Int(String(chars[1])), rowValue >= 1, rowValue <= 8 else { return nil }
        self.col = Int(colValue) - 97
        self.row = rowValue - 1
    }
}

// MARK: - Move

enum MoveType: Equatable, Codable {
    case normal
    case doublePawnPush
    case enPassant
    case castleKingside
    case castleQueenside
    case promotion
}

struct Move: Equatable {
    let from: Position
    let to: Position
    let piece: Piece
    var capturedPiece: Piece?
    var promotionType: PieceType?
    var moveType: MoveType

    var isCapture: Bool { capturedPiece != nil }

    var algebraicNotation: String {
        switch moveType {
        case .castleKingside: return "O-O"
        case .castleQueenside: return "O-O-O"
        default: break
        }
        var notation = ""
        if piece.type != .pawn {
            notation += piece.type.symbol
        }
        if isCapture {
            if piece.type == .pawn {
                notation += String(Character(UnicodeScalar(97 + from.col)!))
            }
            notation += "x"
        }
        notation += to.algebraic
        if let promo = promotionType {
            notation += "=\(promo.symbol)"
        }
        return notation
    }

    static func == (lhs: Move, rhs: Move) -> Bool {
        lhs.from == rhs.from && lhs.to == rhs.to &&
        lhs.piece == rhs.piece && lhs.moveType == rhs.moveType &&
        lhs.promotionType == rhs.promotionType
    }
}

// MARK: - Game State

struct CastlingRights: Equatable {
    var whiteKingside = true
    var whiteQueenside = true
    var blackKingside = true
    var blackQueenside = true
}

struct MoveRecord {
    let move: Move
    let castlingRights: CastlingRights
    let enPassantTarget: Position?
    let halfMoveClock: Int
}

enum GameState: Equatable {
    case playing
    case check(PieceColor)
    case checkmate(winner: PieceColor)
    case stalemate
    case resigned(PieceColor)

    var isGameOver: Bool {
        switch self {
        case .playing, .check: return false
        default: return true
        }
    }
}

enum GameMode: String, CaseIterable {
    case humanVsHuman = "vs Human"
    case humanVsAI = "vs Computer"
}

enum AIDifficulty: String, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case pro = "Pro"

    var searchDepth: Int {
        switch self {
        case .beginner: return 2
        case .intermediate: return 3
        case .pro: return 4
        }
    }
}
