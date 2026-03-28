import Foundation

struct Board {
    var squares: [[Piece?]]

    init() {
        squares = Array(repeating: Array(repeating: nil, count: 8), count: 8)
        setupStartingPosition()
    }

    init(squares: [[Piece?]]) {
        self.squares = squares
    }

    mutating func setupStartingPosition() {
        let backRank: [PieceType] = [.rook, .knight, .bishop, .queen, .king, .bishop, .knight, .rook]
        for col in 0..<8 {
            squares[0][col] = Piece(type: backRank[col], color: .white)
            squares[1][col] = Piece(type: .pawn, color: .white)
            squares[6][col] = Piece(type: .pawn, color: .black)
            squares[7][col] = Piece(type: backRank[col], color: .black)
        }
    }

    func piece(at position: Position) -> Piece? {
        guard position.isValid else { return nil }
        return squares[position.row][position.col]
    }

    mutating func setPiece(_ piece: Piece?, at position: Position) {
        guard position.isValid else { return }
        squares[position.row][position.col] = piece
    }

    func findKing(color: PieceColor) -> Position? {
        for row in 0..<8 {
            for col in 0..<8 {
                if let piece = squares[row][col], piece.type == .king, piece.color == color {
                    return Position(row: row, col: col)
                }
            }
        }
        return nil
    }

    func allPieces(of color: PieceColor) -> [(Position, Piece)] {
        var result: [(Position, Piece)] = []
        for row in 0..<8 {
            for col in 0..<8 {
                if let piece = squares[row][col], piece.color == color {
                    result.append((Position(row: row, col: col), piece))
                }
            }
        }
        return result
    }

    func copy() -> Board {
        Board(squares: squares.map { $0 })
    }
}
