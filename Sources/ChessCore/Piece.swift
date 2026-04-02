import Foundation

// MARK: - Piece Color

public enum PieceColor: Int, Codable, CaseIterable, Sendable {
    case white = 0
    case black = 1

    public var opposite: PieceColor {
        self == .white ? .black : .white
    }
}

// MARK: - Piece Type

public enum PieceType: Int, Codable, CaseIterable, Sendable {
    case pawn   = 0
    case knight = 1
    case bishop = 2
    case rook   = 3
    case queen  = 4
    case king   = 5

    public var fenChar: Character {
        switch self {
        case .pawn:   return "p"
        case .knight: return "n"
        case .bishop: return "b"
        case .rook:   return "r"
        case .queen:  return "q"
        case .king:   return "k"
        }
    }

    public var symbol: String {
        switch self {
        case .pawn:   return "♟"
        case .knight: return "♞"
        case .bishop: return "♝"
        case .rook:   return "♜"
        case .queen:  return "♛"
        case .king:   return "♚"
        }
    }

    public var materialValue: Int {
        switch self {
        case .pawn:   return 100
        case .knight: return 320
        case .bishop: return 330
        case .rook:   return 500
        case .queen:  return 900
        case .king:   return 20000
        }
    }
}

// MARK: - Piece

public struct Piece: Equatable, Hashable, Codable, Sendable {
    public let type: PieceType
    public let color: PieceColor

    public init(_ type: PieceType, _ color: PieceColor) {
        self.type = type
        self.color = color
    }

    public var fenChar: Character {
        let c = type.fenChar
        return color == .white ? Character(c.uppercased()) : c
    }

    public var symbolString: String {
        switch (color, type) {
        case (.white, .king):   return "♔"
        case (.white, .queen):  return "♕"
        case (.white, .rook):   return "♖"
        case (.white, .bishop): return "♗"
        case (.white, .knight): return "♘"
        case (.white, .pawn):   return "♙"
        case (.black, .king):   return "♚"
        case (.black, .queen):  return "♛"
        case (.black, .rook):   return "♜"
        case (.black, .bishop): return "♝"
        case (.black, .knight): return "♞"
        case (.black, .pawn):   return "♟"
        }
    }
}
