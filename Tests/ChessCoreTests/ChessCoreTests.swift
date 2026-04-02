import XCTest
import ChessCore

final class ChessCoreTests: XCTestCase {

    // MARK: - Move legality tests

    func testStartingPawnMoves() {
        let game = GameState()
        let e2 = Square(algebraic: "e2")!
        let moves = game.legalMoves(from: e2)
        let targets = Set(moves.map { $0.to })
        XCTAssertTrue(targets.contains(Square(algebraic: "e3")!))
        XCTAssertTrue(targets.contains(Square(algebraic: "e4")!))
        XCTAssertEqual(moves.count, 2)
    }

    func testKnightMovesFromB1() {
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

    func testWhiteHas20MovesAtStart() {
        let game = GameState()
        XCTAssertEqual(game.allLegalMoves.count, 20)
    }

    // MARK: - Check detection

    func testCheckDetected() {
        // White rook gives check along e-file
        let fen = "4k3/8/8/8/8/8/4R3/4K3 b - - 0 1"
        let game = GameState(fen: fen)
        XCTAssertTrue(MoveGenerator.isInCheck(game.board, color: .black))
    }

    func testNoCheckInStartPosition() {
        let board = (try? FENParser.board(from: Board.startFEN))!
        XCTAssertFalse(MoveGenerator.isInCheck(board, color: .white))
        XCTAssertFalse(MoveGenerator.isInCheck(board, color: .black))
    }

    func testKingCannotMoveIntoCheck() {
        // Black rook on e8, white king on e1
        let fen = "4r3/8/8/8/8/8/8/4K3 w - - 0 1"
        let game = GameState(fen: fen)
        let e1 = Square(algebraic: "e1")!
        let targets = game.legalMoves(from: e1).map(\.to.algebraic)
        // King cannot step to e2 (attacked by rook on e8)
        XCTAssertFalse(targets.contains("e2"))
    }

    // MARK: - Checkmate / stalemate

    func testFoolsMate() {
        var game = GameState()
        XCTAssertTrue(game.makeMove(Move(uci: "f2f3")!))
        XCTAssertTrue(game.makeMove(Move(uci: "e7e5")!))
        XCTAssertTrue(game.makeMove(Move(uci: "g2g4")!))
        XCTAssertTrue(game.makeMove(Move(uci: "d8h4")!))
        XCTAssertEqual(game.result, .checkmate(winner: .black))
    }

    func testStalemateDetection() throws {
        let fen = "k7/8/KQ6/8/8/8/8/8 b - - 0 1"
        let board = try FENParser.board(from: fen)
        XCTAssertTrue(MoveGenerator.isStalemate(board, color: .black))
        XCTAssertFalse(MoveGenerator.isCheckmate(board, color: .black))
    }

    func testCheckmateDetection() throws {
        // Scholar's mate position
        let fen = "r1bqkb1r/pppp1Qpp/2n2n2/4p3/2B1P3/8/PPPP1PPP/RNB1K1NR b KQkq - 0 4"
        let board = try FENParser.board(from: fen)
        XCTAssertTrue(MoveGenerator.isCheckmate(board, color: .black))
    }

    // MARK: - Castling

    func testWhiteKingsideCastle() {
        let fen = "r3k2r/pppppppp/8/8/8/8/PPPPPPPP/R3K2R w KQkq - 0 1"
        var game = GameState(fen: fen)
        let castleMove = Move(from: Square(algebraic: "e1")!, to: Square(algebraic: "g1")!)
        XCTAssertTrue(game.makeMove(castleMove))
        XCTAssertEqual(game.board[Square(algebraic: "g1")!]?.type, .king)
        XCTAssertEqual(game.board[Square(algebraic: "f1")!]?.type, .rook)
    }

    func testWhiteQueensideCastle() {
        let fen = "r3k2r/pppppppp/8/8/8/8/PPPPPPPP/R3K2R w KQkq - 0 1"
        var game = GameState(fen: fen)
        let castleMove = Move(from: Square(algebraic: "e1")!, to: Square(algebraic: "c1")!)
        XCTAssertTrue(game.makeMove(castleMove))
        XCTAssertEqual(game.board[Square(algebraic: "c1")!]?.type, .king)
        XCTAssertEqual(game.board[Square(algebraic: "d1")!]?.type, .rook)
    }

    func testCastlingRightsRemovedAfterKingMove() {
        let fen = "r3k2r/pppppppp/8/8/8/8/PPPPPPPP/R3K2R w KQkq - 0 1"
        var game = GameState(fen: fen)
        // Move king one square to d1 (removing both castling rights)
        _ = game.makeMove(Move(from: Square(algebraic: "e1")!, to: Square(algebraic: "d1")!))
        XCTAssertFalse(game.board.castlingRights.contains(.whiteKingside))
        XCTAssertFalse(game.board.castlingRights.contains(.whiteQueenside))
    }

    // MARK: - En passant

    func testEnPassantCapture() throws {
        let fen = "rnbqkbnr/ppp1pppp/8/3pP3/8/8/PPPP1PPP/RNBQKBNR w KQkq d6 0 2"
        var game = GameState(fen: fen)
        let epMove = Move(from: Square(algebraic: "e5")!, to: Square(algebraic: "d6")!)
        XCTAssertTrue(game.makeMove(epMove))
        XCTAssertNil(game.board[Square(algebraic: "d5")!])
        XCTAssertEqual(game.board[Square(algebraic: "d6")!]?.type, .pawn)
    }

    func testEnPassantSquareClearedAfterOtherMove() throws {
        // After a different move the EP square should be gone
        let fen = "rnbqkbnr/ppp1pppp/8/3pP3/8/8/PPPP1PPP/RNBQKBNR w KQkq d6 0 2"
        var game = GameState(fen: fen)
        _ = game.makeMove(Move(uci: "a2a3")!)
        XCTAssertEqual(game.board.enPassantSquare, Square.none)
    }

    // MARK: - Promotion

    func testPawnPromotion() {
        let fen = "8/4P3/8/8/8/8/8/4K1k1 w - - 0 1"
        var game = GameState(fen: fen)
        let promoMove = Move(from: Square(algebraic: "e7")!, to: Square(algebraic: "e8")!, promotion: .queen)
        XCTAssertTrue(game.makeMove(promoMove))
        XCTAssertEqual(game.board[Square(algebraic: "e8")!]?.type, .queen)
        XCTAssertEqual(game.board[Square(algebraic: "e8")!]?.color, .white)
    }

    func testPawnPromotionToKnight() {
        let fen = "8/4P3/8/8/8/8/8/4K1k1 w - - 0 1"
        var game = GameState(fen: fen)
        let promoMove = Move(from: Square(algebraic: "e7")!, to: Square(algebraic: "e8")!, promotion: .knight)
        XCTAssertTrue(game.makeMove(promoMove))
        XCTAssertEqual(game.board[Square(algebraic: "e8")!]?.type, .knight)
    }

    // MARK: - Undo

    func testUndoMove() {
        var game = GameState()
        let before = game.currentFEN
        _ = game.makeMove(Move(uci: "e2e4")!)
        game.undoLastMove()
        XCTAssertEqual(game.currentFEN, before)
    }

    func testUndoRestoresCastlingRights() {
        let fen = "r3k2r/pppppppp/8/8/8/8/PPPPPPPP/R3K2R w KQkq - 0 1"
        var game = GameState(fen: fen)
        let before = game.board.castlingRights
        _ = game.makeMove(Move(from: Square(algebraic: "e1")!, to: Square(algebraic: "g1")!))
        game.undoLastMove()
        XCTAssertEqual(game.board.castlingRights, before)
    }

    // MARK: - UCI notation

    func testUCIRoundTrip() {
        let m = Move(from: Square(algebraic: "e2")!, to: Square(algebraic: "e4")!)
        XCTAssertEqual(Move(uci: m.uci)?.from, m.from)
        XCTAssertEqual(Move(uci: m.uci)?.to, m.to)
    }

    func testUCIPromotion() {
        let m = Move(from: Square(algebraic: "e7")!, to: Square(algebraic: "e8")!, promotion: .queen)
        XCTAssertEqual(m.uci, "e7e8q")
        XCTAssertEqual(Move(uci: "e7e8q")?.promotion, .queen)
    }

    // MARK: - Bot

    func testBotReturnsMove() async {
        let game = GameState()
        let bot = ChessBot(difficulty: .beginner, color: .white)
        let move = await bot.bestMove(in: game)
        XCTAssertNotNil(move)
    }

    func testBotMoveIsLegal() async {
        let game = GameState()
        let bot = ChessBot(difficulty: .easy, color: .white)
        let move = await bot.bestMove(in: game)
        guard let move else { return XCTFail("Bot returned nil") }
        let legal = MoveGenerator.legalMoves(for: game.board, color: .white)
        XCTAssertTrue(legal.contains(move), "Bot move \(move.uci) is not legal")
    }

    func testBotPicksMateInOne() async {
        // Back-rank mate: Ra8# available
        let fen = "6k1/5ppp/8/8/8/8/8/R5K1 w - - 0 1"
        let game = GameState(fen: fen)
        let bot = ChessBot(difficulty: .medium, color: .white)
        let move = await bot.bestMove(in: game)
        // The move should be Ra8 (a1a8)
        XCTAssertEqual(move?.uci, "a1a8", "Bot should find Ra8#")
    }

    // MARK: - Material values

    func testMaterialValues() {
        XCTAssertEqual(PieceType.pawn.materialValue,   100)
        XCTAssertEqual(PieceType.knight.materialValue, 320)
        XCTAssertEqual(PieceType.bishop.materialValue, 330)
        XCTAssertEqual(PieceType.rook.materialValue,   500)
        XCTAssertEqual(PieceType.queen.materialValue,  900)
    }

    // MARK: - Algebraic helpers

    func testSquareAlgebraic() {
        XCTAssertEqual(Square(algebraic: "a1"), 0)
        XCTAssertEqual(Square(algebraic: "h1"), 7)
        XCTAssertEqual(Square(algebraic: "a8"), 56)
        XCTAssertEqual(Square(algebraic: "h8"), 63)
        XCTAssertEqual(Square(algebraic: "e4"), 28)
    }

    func testSquareAlgebraicRoundTrip() {
        for sq in 0..<64 {
            let alg = sq.algebraic
            XCTAssertEqual(Square(algebraic: alg), sq, "Failed round-trip for square \(sq) (\(alg))")
        }
    }
}
