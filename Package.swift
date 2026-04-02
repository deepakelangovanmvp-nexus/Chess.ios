// swift-tools-version: 5.9
// Chess.ios – Swift Package for cross-platform engine builds and tests.
//
// Usage:
//   swift build                      # build everything
//   swift test                       # run all chess-engine unit tests
//   swift run ChessCLI demo          # show the board after the Italian Game opening
//   swift run ChessCLI bot           # watch CPU vs CPU play 40 moves
//   swift run ChessCLI puzzle        # verify bundled puzzles against the engine
//   swift run ChessCLI summary       # engine feature checklist

import PackageDescription

let package = Package(
    name: "Chess.ios",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        // The chess engine as a reusable library.
        .library(
            name: "ChessCore",
            targets: ["ChessCore"]
        ),
        // A command-line demo / smoke-test runner.
        .executable(
            name: "ChessCLI",
            targets: ["ChessCLI"]
        ),
    ],
    targets: [
        // MARK: Core library
        .target(
            name: "ChessCore",
            path: "Sources/ChessCore",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        ),

        // MARK: CLI demo executable
        .executableTarget(
            name: "ChessCLI",
            dependencies: ["ChessCore"],
            path: "Sources/ChessCLI"
        ),

        // MARK: Unit tests
        .testTarget(
            name: "ChessCoreTests",
            dependencies: ["ChessCore"],
            path: "Tests/ChessCoreTests"
        ),
    ]
)
