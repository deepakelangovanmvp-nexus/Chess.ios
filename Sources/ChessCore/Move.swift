import Foundation

// MARK: - Square (0-63, a1=0, h8=63)

public typealias Square = Int

public extension Square {
    static let none = -1

    var file: Int { self & 7 }   // 0=a … 7=h
    var rank: Int { self >> 3 }  // 0=1 … 7=8

    var algebraic: String {
        guard self >= 0, self < 64 else { return "-" }
        let files = ["a","b","c","d","e","f","g","h"]
        return "\(files[file])\(rank + 1)"
    }

    init?(algebraic: String) {
        guard algebraic.count == 2 else { return nil }
        let chars = Array(algebraic)
        guard let fileIdx = "abcdefgh".firstIndex(of: chars[0]),
              let rankNum = chars[1].wholeNumberValue,
              rankNum >= 1, rankNum <= 8 else { return nil }
        let f = "abcdefgh".distance(from: "abcdefgh".startIndex, to: fileIdx)
        self = f + (rankNum - 1) * 8
    }

    func offset(df: Int, dr: Int) -> Square? {
        let newFile = file + df
        let newRank = rank + dr
        guard newFile >= 0, newFile < 8, newRank >= 0, newRank < 8 else { return nil }
        return newFile + newRank * 8
    }
}

// MARK: - Move

public struct Move: Equatable, Hashable, Codable, Sendable {
    public let from: Square
    public let to: Square
    public let promotion: PieceType?

    public init(from: Square, to: Square, promotion: PieceType? = nil) {
        self.from = from
        self.to = to
        self.promotion = promotion
    }

    public var uci: String {
        let promo = promotion.map { String($0.fenChar) } ?? ""
        return "\(from.algebraic)\(to.algebraic)\(promo)"
    }

    public init?(uci: String) {
        let s = uci.trimmingCharacters(in: .whitespaces)
        guard s.count >= 4 else { return nil }
        let fromStr = String(s.prefix(2))
        let toStr = String(s.dropFirst(2).prefix(2))
        guard let f = Square(algebraic: fromStr), let t = Square(algebraic: toStr) else { return nil }
        from = f
        to = t
        if s.count == 5 {
            let promoChar = s.last!
            switch promoChar {
            case "q": promotion = .queen
            case "r": promotion = .rook
            case "b": promotion = .bishop
            case "n": promotion = .knight
            default: promotion = nil
            }
        } else {
            promotion = nil
        }
    }
}

// MARK: - Castling Rights

public struct CastlingRights: OptionSet, Codable, Sendable, Hashable {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }

    public static let whiteKingside  = CastlingRights(rawValue: 1)
    public static let whiteQueenside = CastlingRights(rawValue: 2)
    public static let blackKingside  = CastlingRights(rawValue: 4)
    public static let blackQueenside = CastlingRights(rawValue: 8)
    public static let all: CastlingRights = [.whiteKingside, .whiteQueenside, .blackKingside, .blackQueenside]
    public static let none: CastlingRights = []
}
