import Foundation

// MARK: - Board

public struct Board: Equatable, Sendable {
    // 64 squares; nil = empty
    public private(set) var squares: [Piece?]
    public private(set) var sideToMove: PieceColor
    public private(set) var castlingRights: CastlingRights
    public private(set) var enPassantSquare: Square      // Square.none if none
    public private(set) var halfMoveClock: Int
    public private(set) var fullMoveNumber: Int

    // History for undo
    private var history: [BoardSnapshot] = []

    public static let startFEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

    public init() {
        squares = Array(repeating: nil, count: 64)
        sideToMove = .white
        castlingRights = .all
        enPassantSquare = Square.none
        halfMoveClock = 0
        fullMoveNumber = 1
    }

    // MARK: Piece access

    public subscript(square: Square) -> Piece? {
        get { squares[square] }
    }

    // MARK: King square helpers

    public func kingSquare(for color: PieceColor) -> Square {
        for sq in 0..<64 {
            if let p = squares[sq], p.type == .king, p.color == color { return sq }
        }
        return Square.none
    }

    // MARK: Apply move (returns new board)

    @discardableResult
    public mutating func apply(_ move: Move) -> CapturedInfo {
        guard let movingPiece = squares[move.from] else {
            return CapturedInfo(captured: nil, enPassantTarget: Square.none)
        }

        let captured = squares[move.to]
        var capturedInfo = CapturedInfo(captured: captured, enPassantTarget: enPassantSquare)

        // Save snapshot for undo
        history.append(BoardSnapshot(
            squares: squares,
            sideToMove: sideToMove,
            castlingRights: castlingRights,
            enPassantSquare: enPassantSquare,
            halfMoveClock: halfMoveClock,
            fullMoveNumber: fullMoveNumber
        ))

        // En passant capture
        if movingPiece.type == .pawn, move.to == enPassantSquare, enPassantSquare != Square.none {
            let capturedPawnRank = movingPiece.color == .white ? move.to.rank - 1 : move.to.rank + 1
            let capturedPawnSquare = move.to.file + capturedPawnRank * 8
            capturedInfo = CapturedInfo(captured: squares[capturedPawnSquare], enPassantTarget: enPassantSquare)
            squares[capturedPawnSquare] = nil
        }

        // Move piece
        squares[move.to] = movingPiece
        squares[move.from] = nil

        // Promotion
        if movingPiece.type == .pawn,
           (move.to.rank == 7 && movingPiece.color == .white) ||
           (move.to.rank == 0 && movingPiece.color == .black) {
            let promoType = move.promotion ?? .queen
            squares[move.to] = Piece(promoType, movingPiece.color)
        }

        // Castling – move rook
        if movingPiece.type == .king {
            let fileDiff = move.to.file - move.from.file
            if abs(fileDiff) == 2 {
                let rookFromFile = fileDiff > 0 ? 7 : 0
                let rookToFile   = fileDiff > 0 ? 5 : 3
                let rankRow = move.from.rank * 8
                squares[rookToFile + rankRow] = squares[rookFromFile + rankRow]
                squares[rookFromFile + rankRow] = nil
            }
        }

        // Update castling rights
        updateCastlingRights(piece: movingPiece, from: move.from, to: move.to)

        // En passant square
        if movingPiece.type == .pawn, abs(move.to.rank - move.from.rank) == 2 {
            enPassantSquare = move.from.file + (move.from.rank + (movingPiece.color == .white ? 1 : -1)) * 8
        } else {
            enPassantSquare = Square.none
        }

        // Clocks
        if movingPiece.type == .pawn || captured != nil {
            halfMoveClock = 0
        } else {
            halfMoveClock += 1
        }
        if sideToMove == .black { fullMoveNumber += 1 }

        sideToMove = sideToMove.opposite
        return capturedInfo
    }

    // MARK: Undo last move

    public mutating func undoLastMove() {
        guard let snapshot = history.popLast() else { return }
        squares = snapshot.squares
        sideToMove = snapshot.sideToMove
        castlingRights = snapshot.castlingRights
        enPassantSquare = snapshot.enPassantSquare
        halfMoveClock = snapshot.halfMoveClock
        fullMoveNumber = snapshot.fullMoveNumber
    }

    // MARK: Private helpers

    private mutating func updateCastlingRights(piece: Piece, from: Square, to: Square) {
        switch from {
        case 4:  castlingRights.remove([.whiteKingside, .whiteQueenside])  // e1
        case 60: castlingRights.remove([.blackKingside, .blackQueenside])  // e8
        case 0:  castlingRights.remove(.whiteQueenside)                    // a1
        case 7:  castlingRights.remove(.whiteKingside)                     // h1
        case 56: castlingRights.remove(.blackQueenside)                    // a8
        case 63: castlingRights.remove(.blackKingside)                     // h8
        default: break
        }
        switch to {
        case 0:  castlingRights.remove(.whiteQueenside)
        case 7:  castlingRights.remove(.whiteKingside)
        case 56: castlingRights.remove(.blackQueenside)
        case 63: castlingRights.remove(.blackKingside)
        default: break
        }
    }
}

// MARK: - CapturedInfo

public struct CapturedInfo: Sendable {
    public let captured: Piece?
    public let enPassantTarget: Square
}

// MARK: - Equatable (explicit, ignores undo history)

extension Board {
    public static func == (lhs: Board, rhs: Board) -> Bool {
        lhs.squares == rhs.squares &&
        lhs.sideToMove == rhs.sideToMove &&
        lhs.castlingRights == rhs.castlingRights &&
        lhs.enPassantSquare == rhs.enPassantSquare &&
        lhs.halfMoveClock == rhs.halfMoveClock &&
        lhs.fullMoveNumber == rhs.fullMoveNumber
    }
}

// MARK: - FEN helpers (internal mutation; private setters accessible here in same file)

extension Board {
    mutating func unsafeSetSquare(_ square: Square, piece: Piece?) {
        guard square >= 0, square < 64 else { return }
        squares[square] = piece
    }
    mutating func unsafeSetSideToMove(_ color: PieceColor) { sideToMove = color }
    mutating func unsafeSetCastlingRights(_ rights: CastlingRights) { castlingRights = rights }
    mutating func unsafeSetEnPassant(_ sq: Square) { enPassantSquare = sq }
    mutating func unsafeSetClocks(half: Int, full: Int) {
        halfMoveClock = half
        fullMoveNumber = full
    }
}

// MARK: - BoardSnapshot (for undo)

private struct BoardSnapshot: Sendable {
    let squares: [Piece?]
    let sideToMove: PieceColor
    let castlingRights: CastlingRights
    let enPassantSquare: Square
    let halfMoveClock: Int
    let fullMoveNumber: Int
}
