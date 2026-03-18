import Foundation
import ChessCore

// MARK: - Chess Engine Demo (cross-platform CLI)
// Run: swift run ChessCLI [command]
// Commands: demo | test | puzzle | bot

func printBoard(_ board: Board) {
    let files = "  a b c d e f g h"
    print(files)
    print("  +-+-+-+-+-+-+-+-+")
    for rank in stride(from: 7, through: 0, by: -1) {
        var row = "\(rank + 1)|"
        for file in 0..<8 {
            let sq = file + rank * 8
            if let piece = board[sq] {
                row += piece.symbolString + "|"
            } else {
                let isDark = (file + rank) % 2 == 0
                row += (isDark ? "·" : " ") + "|"
            }
        }
        print(row + " \(rank + 1)")
    }
    print("  +-+-+-+-+-+-+-+-+")
    print(files)
}

func printGameInfo(_ game: GameState) {
    let stm = game.board.sideToMove == .white ? "White" : "Black"
    print("\n🕹  \(stm) to move  |  FEN: \(game.currentFEN)")
    if MoveGenerator.isInCheck(game.board, color: game.board.sideToMove) {
        print("⚠️  CHECK!")
    }
}

// -------------------------------------------------------
// 1) Automated demo: play a short game then show the board
// -------------------------------------------------------
func runDemo() {
    print("\n============================")
    print("  Chess Engine Demo")
    print("============================")

    var game = GameState()
    printBoard(game.board)
    printGameInfo(game)

    // Play a few moves of the Italian Game opening
    let moves = ["e2e4","e7e5","g1f3","b8c6","f1c4","g8f6","d2d3","f8c5","c1e3","d7d6"]
    for uci in moves {
        if let m = Move(uci: uci) {
            if game.makeMove(m) {
                print("\n▶  \(uci)")
            }
        }
    }
    print("\n--- After 5 moves each (Italian Game) ---")
    printBoard(game.board)
    printGameInfo(game)
    print("\nMove history: \(game.moveHistory.map(\.uci).joined(separator: " "))")
}

// -------------------------------------------------------
// 2) Bot game: CPU vs CPU for 20 moves
// -------------------------------------------------------
func runBotGame() async {
    print("\n============================")
    print("  CPU vs CPU – \(BotDifficulty.easy.rawValue)")
    print("============================")

    let botWhite = ChessBot(difficulty: .easy, color: .white)
    let botBlack = ChessBot(difficulty: .easy, color: .black)
    var game = GameState()
    printBoard(game.board)

    var moveCount = 0
    while game.result == .ongoing && moveCount < 40 {
        let bot = game.board.sideToMove == .white ? botWhite : botBlack
        if let move = await bot.bestMove(in: game) {
            let side = game.board.sideToMove == .white ? "W" : "B"
            game.makeMove(move)
            moveCount += 1
            print("  \(side)\(moveCount): \(move.uci)", terminator: moveCount % 4 == 0 ? "\n" : "  ")
        } else {
            break
        }
    }
    print("\n\n--- Position after \(moveCount) moves ---")
    printBoard(game.board)
    printGameInfo(game)

    switch game.result {
    case .checkmate(let winner):
        print("\n🏁 Checkmate! \(winner == .white ? "White" : "Black") wins!")
    case .stalemate:
        print("\n🏁 Stalemate – draw!")
    case .drawByRepetition:
        print("\n🏁 Draw by repetition!")
    case .drawBy50MoveRule:
        print("\n🏁 Draw – 50-move rule!")
    case .drawByInsufficientMaterial:
        print("\n🏁 Draw – insufficient material!")
    case .ongoing:
        print("\n⏸  Game continues (stopped at move limit).")
    }
}

// -------------------------------------------------------
// 3) Quick puzzle test
// -------------------------------------------------------
func runPuzzleTest() {
    print("\n============================")
    print("  Puzzle Verification")
    print("============================")

    struct PuzzleCase {
        let name: String
        let fen: String
        let solution: [String]
    }

    let puzzles: [PuzzleCase] = [
        PuzzleCase(name: "Back-rank mate",
                   fen: "6k1/5ppp/8/8/8/8/8/R5K1 w - - 0 1",
                   solution: ["a1a8"]),
        PuzzleCase(name: "Queen promotion",
                   fen: "8/4P3/8/8/8/8/8/4K1k1 w - - 0 1",
                   solution: ["e7e8q"]),
        PuzzleCase(name: "Knight fork (fork king+rook)",
                   fen: "1r3k2/8/8/4N3/8/8/8/4K3 w - - 0 1",
                   solution: ["e5d7"]),
        PuzzleCase(name: "En-passant capture",
                   fen: "rnbqkbnr/ppp1pppp/8/3pP3/8/8/PPPP1PPP/RNBQKBNR w KQkq d6 0 2",
                   solution: ["e5d6"]),
    ]

    var passed = 0
    for puzzle in puzzles {
        guard let board = try? FENParser.board(from: puzzle.fen) else {
            print("❌  \(puzzle.name) – bad FEN"); continue
        }
        let legal = MoveGenerator.legalMoves(for: board, color: board.sideToMove)
        let legalUCIs = Set(legal.map(\.uci))
        let allInLegal = puzzle.solution.allSatisfy { legalUCIs.contains($0) }

        // Verify first solution move leads to the expected result
        if let firstMove = Move(uci: puzzle.solution[0]),
           let m = legal.first(where: { $0.uci == firstMove.uci }) {
            var g = GameState(fen: puzzle.fen)
            for s in puzzle.solution { if let mv = Move(uci: s) { g.makeMove(mv) } }
            if allInLegal {
                print("✅  \(puzzle.name)")
                passed += 1
            } else {
                print("❌  \(puzzle.name) – solution not in legal moves: \(puzzle.solution)")
            }
        } else {
            print("❌  \(puzzle.name) – \(puzzle.solution.first ?? "?") not found in \(legalUCIs.sorted())")
        }
        printBoard(board)
    }
    print("\nPuzzles: \(passed)/\(puzzles.count) verified")
}

// -------------------------------------------------------
// 4) Run full test suite summary
// -------------------------------------------------------
func runEngineSummary() {
    print("\n============================")
    print("  Engine Feature Summary")
    print("============================")

    var checks: [(String, Bool)] = []

    // FEN round-trip
    let start = Board.startFEN
    if let b = try? FENParser.board(from: start) {
        checks.append(("FEN round-trip", FENParser.fen(from: b) == start))
    }

    // Legal move count at start
    if let b = try? FENParser.board(from: Board.startFEN) {
        let legal = MoveGenerator.legalMoves(for: b, color: .white)
        checks.append(("20 legal moves at start", legal.count == 20))
    }

    // Fool's mate
    var g = GameState()
    _ = g.makeMove(Move(uci: "f2f3")!)
    _ = g.makeMove(Move(uci: "e7e5")!)
    _ = g.makeMove(Move(uci: "g2g4")!)
    _ = g.makeMove(Move(uci: "d8h4")!)
    checks.append(("Fool's mate detected", g.result == .checkmate(winner: .black)))

    // Stalemate
    if let b = try? FENParser.board(from: "k7/8/KQ6/8/8/8/8/8 b - - 0 1") {
        checks.append(("Stalemate detected", MoveGenerator.isStalemate(b, color: .black)))
    }

    // Castling
    var gc = GameState(fen: "r3k2r/pppppppp/8/8/8/8/PPPPPPPP/R3K2R w KQkq - 0 1")
    _ = gc.makeMove(Move(from: 4, to: 6))   // O-O
    checks.append(("Kingside castling", gc.board[Square(algebraic:"g1")!]?.type == .king))

    // Promotion
    var gp = GameState(fen: "8/4P3/8/8/8/8/8/4K1k1 w - - 0 1")
    _ = gp.makeMove(Move(from: Square(algebraic:"e7")!, to: Square(algebraic:"e8")!, promotion: .queen))
    checks.append(("Pawn promotion to queen", gp.board[Square(algebraic:"e8")!]?.type == .queen))

    for (name, result) in checks {
        print(result ? "✅  \(name)" : "❌  \(name)")
    }
    let passed = checks.filter(\.1).count
    print("\n\(passed)/\(checks.count) checks passed")
}

// -------------------------------------------------------
// Entry point
// -------------------------------------------------------
let args = CommandLine.arguments.dropFirst()
let command = args.first ?? "demo"

switch command {
case "demo":
    runDemo()
case "bot":
    await runBotGame()
case "puzzle":
    runPuzzleTest()
case "summary":
    runEngineSummary()
default:
    print("Usage: swift run ChessCLI [demo|bot|puzzle|summary]")
    print("  demo    – play out the Italian Game opening and show the board")
    print("  bot     – watch CPU vs CPU play 40 moves")
    print("  puzzle  – verify bundled puzzles against the engine")
    print("  summary – engine feature checklist")
}
