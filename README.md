# Chess.ios

An **offline-first chess teaching app** built with SwiftUI, supporting iPhone, iPad, and macOS (Apple Silicon + Intel).

---

## Features

| Tab | What you can do |
|-----|-----------------|
| **Learn** | Step through lessons on pieces, tactics, and openings. Interactive checkpoints ask you to find the right move. |
| **Puzzles** | Solve curated puzzles (mate-in-1/2, forks, pins, promotions). The engine validates every move and plays the opponent's response automatically. |
| **Play** | Play against a CPU opponent at Beginner / Easy / Medium. Coach Mode gives feedback after each of your moves. Undo is supported. |
| **Progress** | Track XP, streak, lessons completed, and puzzle accuracy — all stored on-device. |

All content and logic ship in the app bundle. **No internet connection required.**

---

## Requirements

| Platform | Minimum version |
|----------|----------------|
| iOS / iPadOS | 17.0 |
| macOS | 14.0 (Sonoma) |
| Xcode | 15.0 or later |
| Swift | 5.9 or later |

---

## Getting Started (iOS / macOS)

```bash
# Clone the repository
git clone https://github.com/deepakelangovanmvp-nexus/Chess.ios.git
cd Chess.ios
```

Open the Xcode project:

```bash
open Chess.ios.xcodeproj
```

1. Select the **Chess.ios** scheme.
2. Choose your target device (iPhone Simulator / Mac).
3. Press **⌘R** to build and run.

> **Tip (macOS):** If the project opens in iPad mode on macOS, choose  
> **Product → Destination → My Mac (Designed for iPad)** or  
> **My Mac (Mac Catalyst)** from the scheme menu.

---

## Running Tests in Xcode

Press **⌘U** to run the full test suite. The tests live in `Chess.iosTests/` and cover:

- FEN parsing (round-trip, custom positions, en-passant square)
- Move legality (all piece types, castling, en passant, promotion)
- Check, checkmate, and stalemate detection
- Bot move generation (legality + mate-in-one)

---

## Running Tests & CLI Without Xcode (Swift Package Manager)

The repository includes a `Package.swift` that wraps the chess engine as a Swift package.  
You can build, test, and run the CLI demo on **Linux, macOS, or any platform with Swift 5.9+**.

### Build

```bash
swift build
```

### Run the test suite

```bash
swift test
```

Expected output: all **26 tests** pass (24 engine tests + FEN parser tests).

### Interactive CLI demos

```bash
# Show the board after the Italian Game opening (5 moves each side)
swift run ChessCLI demo

# Watch the CPU play itself for up to 40 moves
swift run ChessCLI bot

# Verify puzzle positions and solutions against the engine
swift run ChessCLI puzzle

# Engine feature checklist (FEN, legal moves, checkmate, stalemate, castling, promotion)
swift run ChessCLI summary
```

---

## Project Structure

```
Chess.ios/
├── Chess.ios.xcodeproj/        Xcode project (iOS + macOS multiplatform target)
├── Package.swift               Swift Package (build engine + tests on any platform)
│
├── Chess.ios/                  App sources
│   ├── ChessCore/              Pure-Swift chess engine (no UIKit/SwiftUI dependencies)
│   │   ├── Piece.swift         Piece types, colours, material values
│   │   ├── Move.swift          Move representation, UCI notation, castling rights
│   │   ├── Board.swift         64-square board with undo history
│   │   ├── FENParser.swift     FEN import / export
│   │   ├── MoveGenerator.swift Legal move generation, check/checkmate/stalemate
│   │   ├── GameState.swift     Game lifecycle, repetition & 50-move rule
│   │   └── ChessBot.swift      Minimax + alpha-beta (Beginner/Easy/Medium)
│   │
│   ├── UIComponents/
│   │   └── BoardView.swift     Responsive chess board (tap + drag, legal-move dots)
│   │
│   ├── Features/
│   │   ├── Learn/              Lesson viewer with interactive FEN checkpoints
│   │   ├── Puzzles/            Puzzle solver with auto-opponent response
│   │   ├── Play/               Human vs CPU with promotion sheet & coach feedback
│   │   └── Progress/           XP, streak, lesson & puzzle stats
│   │
│   ├── Content/
│   │   ├── Lessons.json        4 lessons (Basics, Tactics, Strategy)
│   │   └── Puzzles.json        10 puzzles (Easy / Medium)
│   │
│   ├── Persistence/
│   │   └── ProgressStore.swift UserDefaults-backed progress store (@MainActor)
│   │
│   └── ContentView.swift       Navigation shell (TabView on iOS, Sidebar on macOS)
│
├── Chess.iosTests/             XCTest targets (Xcode)
├── Sources/ChessCore/          SPM library sources (mirror of Chess.ios/ChessCore/)
├── Sources/ChessCLI/           CLI demo executable
└── Tests/ChessCoreTests/       SPM test targets
```

---

## Chess Engine Highlights

- **Board representation:** 64-element `[Piece?]` array with rank/file helpers.
- **Move generation:** Pseudo-legal generation + legality filter (copy-apply-check). Handles castling (with attack detection on transit squares), en passant, and all promotion pieces.
- **Attack detection:** Direct per-piece attack pattern checks (no recursion). Pawn attacks are diagonal-only, king attacks are adjacent-only (no castling re-entry).
- **Game end detection:** Checkmate, stalemate, draw by threefold repetition, 50-move rule, and insufficient material.
- **Bot:** Iterative minimax with alpha-beta pruning. Depth 1 (Beginner) / 2 (Easy) / 3 (Medium). Material + simple positional evaluation. Coach Mode evaluates material swing post-move.
- **FEN:** Full import and export with round-trip fidelity.

---

## Offline

All lessons, puzzles, and engine logic ship inside the app bundle.  
No account, no network, no server — everything runs on-device.

