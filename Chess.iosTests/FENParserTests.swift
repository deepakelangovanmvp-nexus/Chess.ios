import XCTest
@testable import Chess_ios

final class FENParserTests: XCTestCase {

    func testStartPositionFEN() throws {
        let fen = Board.startFEN
        let board = try FENParser.board(from: fen)
        XCTAssertEqual(board.sideToMove, .white)
        XCTAssertEqual(board.castlingRights, .all)
        XCTAssertEqual(board.enPassantSquare, Square.none)
        XCTAssertEqual(board.halfMoveClock, 0)
        XCTAssertEqual(board.fullMoveNumber, 1)
    }

    func testWhiteKingOnE1() throws {
        let board = try FENParser.board(from: Board.startFEN)
        let e1 = Square(algebraic: "e1")!
        XCTAssertEqual(board[e1], Piece(.king, .white))
    }

    func testBlackQueenOnD8() throws {
        let board = try FENParser.board(from: Board.startFEN)
        let d8 = Square(algebraic: "d8")!
        XCTAssertEqual(board[d8], Piece(.queen, .black))
    }

    func testRoundTrip() throws {
        let fen = Board.startFEN
        let board = try FENParser.board(from: fen)
        let exported = FENParser.fen(from: board)
        XCTAssertEqual(exported, fen)
    }

    func testCustomFEN() throws {
        // Rook endgame FEN: white rook on a1, both kings
        let fen = "8/8/8/8/8/8/8/R3K2R w KQ - 0 1"
        let board = try FENParser.board(from: fen)
        XCTAssertEqual(board[Square(algebraic: "a1")!]?.type, .rook)
        XCTAssertEqual(board[Square(algebraic: "e1")!]?.type, .king)
        XCTAssertTrue(board.castlingRights.contains(.whiteKingside))
        XCTAssertTrue(board.castlingRights.contains(.whiteQueenside))
        XCTAssertFalse(board.castlingRights.contains(.blackKingside))
    }

    func testEnPassantSquareParsed() throws {
        let fen = "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1"
        let board = try FENParser.board(from: fen)
        let e3 = Square(algebraic: "e3")!
        XCTAssertEqual(board.enPassantSquare, e3)
    }

    func testInvalidFENThrows() {
        XCTAssertThrowsError(try FENParser.board(from: "invalid"))
    }

    func testEmptyBoard() throws {
        let fen = "8/8/8/8/8/8/8/8 w - - 0 1"
        let board = try FENParser.board(from: fen)
        for sq in 0..<64 {
            XCTAssertNil(board[sq])
        }
    }
}
