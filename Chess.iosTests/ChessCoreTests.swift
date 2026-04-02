import XCTest
@testable import Chess_ios

final class ChessCoreTests: XCTestCase {

    // MARK: - Move legality tests

    func testStartingPawnMoves() throws {
        var game = GameState()
        let e2 = Square(algebraic: "e2")!
        let moves = game.legalMoves(from: e2)
        let targets = Set(moves.map { $0.to })
        XCTAssertTrue(targets.contains(Square(algebraic: "e3")!))
        XCTAssertTrue(targets.contains(Square(algebraic: "e4")!))
        XCTAssertEqual(moves.count, 2)
    }

    func testKnightMovesFromB1() throws {
        let game = GameState()
        let b1 = Square(algebraic: "b1")!
        let moves = game.legalMoves(from: b1)
        let targets = Set(moves.map { $0.to.algebraic })
        XCTAssertTrue(targets.contains("a3"))
        XCTAssertTrue(targets.contains("c3"))
        XCTAssertEqual(moves.count, 2)
    }

    func testNoMovesFromEmptySquare() {
        let game = GameState()
        let e4 = Square(algebraic: "e4")!
        XCTAssertTrue(game.legalMoves(from: e4).isEmpty)
    }

    // MARK: - Check detection

    func testCheckDetected() throws {
        // White queen attacks black king directly
        let fen = "4k3/8/8/8/8/8/8/4K2Q w - - 0 1"
        var game = GameState(fen: fen)
        game.makeMove(Move(from: Square(algebraic: "h1")!, to: Square(algebraic: "e8")!))
        XCTAssertTrue(MoveGenerator.isInCheck(game.board, color: .black))
    }

    func testNoCheckInStartPosition() {
        let board = (try? FENParser.board(from: Board.startFEN))!
        XCTAssertFalse(MoveGenerator.isInCheck(board, color: .white))
        XCTAssertFalse(MoveGenerator.isInCheck(board, color: .black))
    }

    func testKingCannotMoveIntoCheck() throws {
        // White king on e1, black rook on e8, nothing else
        let fen = "4r3/8/8/8/8/8/8/4K3 w - - 0 1"
        let game = GameState(fen: fen)
        let e1 = Square(algebraic: "e1")!
        let targets = game.legalMoves(from: e1).map(\.to.algebraic)
        // King cannot move to e2 (attacked by rook on e8)
        XCTAssertFalse(targets.contains("e2"))
    }

    // MARK: - Checkmate / stalemate

    func testFoolsMate() throws {
        // f3 e5 g4 Qh4#
        var game = GameState()
        XCTAssertTrue(game.makeMove(Move(uci: "f2f3")!))
        XCTAssertTrue(game.makeMove(Move(uci: "e7e5")!))
        XCTAssertTrue(game.makeMove(Move(uci: "g2g4")!))
        XCTAssertTrue(game.makeMove(Move(uci: "d8h4")!))
        XCTAssertEqual(game.result, .checkmate(winner: .black))
    }

    func testStalemateDetection() throws {
        // Classic stalemate: black king on a8, white queen on b6, white king on a6
        let fen = "k7/8/KQ6/8/8/8/8/8 b - - 0 1"
        let board = try FENParser.board(from: fen)
        XCTAssertTrue(MoveGenerator.isStalemate(board, color: .black))
        XCTAssertFalse(MoveGenerator.isCheckmate(board, color: .black))
    }

    // MARK: - Castling

    func testWhiteKingsideCastle() throws {
        let fen = "r3k2r/pppppppp/8/8/8/8/PPPPPPPP/R3K2R w KQkq - 0 1"
        var game = GameState(fen: fen)
        let castleMove = Move(from: Square(algebraic: "e1")!, to: Square(algebraic: "g1")!)
        XCTAssertTrue(game.makeMove(castleMove))
        XCTAssertEqual(game.board[Square(algebraic: "g1")!]?.type, .king)
        XCTAssertEqual(game.board[Square(algebraic: "f1")!]?.type, .rook)
    }

    func testWhiteQueensideCastle() throws {
        let fen = "r3k2r/pppppppp/8/8/8/8/PPPPPPPP/R3K2R w KQkq - 0 1"
        var game = GameState(fen: fen)
        let castleMove = Move(from: Square(algebraic: "e1")!, to: Square(algebraic: "c1")!)
        XCTAssertTrue(game.makeMove(castleMove))
        XCTAssertEqual(game.board[Square(algebraic: "c1")!]?.type, .king)
        XCTAssertEqual(game.board[Square(algebraic: "d1")!]?.type, .rook)
    }

    // MARK: - En passant

    func testEnPassantCapture() throws {
        // White pawn on e5, black pawn just played d7-d5
        let fen = "rnbqkbnr/ppp1pppp/8/3pP3/8/8/PPPP1PPP/RNBQKBNR w KQkq d6 0 2"
        var game = GameState(fen: fen)
        let epMove = Move(from: Square(algebraic: "e5")!, to: Square(algebraic: "d6")!)
        XCTAssertTrue(game.makeMove(epMove))
        // Black pawn on d5 should be captured
        XCTAssertNil(game.board[Square(algebraic: "d5")!])
        XCTAssertEqual(game.board[Square(algebraic: "d6")!]?.type, .pawn)
    }

    // MARK: - Promotion

    func testPawnPromotion() throws {
        // White pawn on e7, can promote
        let fen = "8/4P3/8/8/8/8/8/4K1k1 w - - 0 1"
        var game = GameState(fen: fen)
        let promoMove = Move(from: Square(algebraic: "e7")!, to: Square(algebraic: "e8")!, promotion: .queen)
        XCTAssertTrue(game.makeMove(promoMove))
        XCTAssertEqual(game.board[Square(algebraic: "e8")!]?.type, .queen)
        XCTAssertEqual(game.board[Square(algebraic: "e8")!]?.color, .white)
    }

    // MARK: - Undo

    func testUndoMove() throws {
        var game = GameState()
        let before = game.currentFEN
        game.makeMove(Move(uci: "e2e4")!)
        game.undoLastMove()
        XCTAssertEqual(game.currentFEN, before)
    }

    // MARK: - Bot test (shallow)

    func testBotReturnsMove() async throws {
        let game = GameState()
        let bot = ChessBot(difficulty: .beginner, color: .white)
        let move = await bot.bestMove(in: game)
        XCTAssertNotNil(move)
    }
}
