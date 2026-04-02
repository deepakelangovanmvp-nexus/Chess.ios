import SwiftUI

// MARK: - Board View

struct BoardView: View {
    let board: Board
    var selectedSquare: Square? = nil
    var legalMoveTargets: [Square] = []
    var highlightedSquares: [Square] = []      // last move highlights
    var flipped: Bool = false
    var onSquareTapped: ((Square) -> Void)? = nil

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let squareSize = size / 8

            ZStack {
                // Board squares
                ForEach(0..<64, id: \.self) { index in
                    let sq = squareIndex(index)
                    SquareView(
                        square: sq,
                        piece: board[sq],
                        squareSize: squareSize,
                        isSelected: sq == selectedSquare,
                        isLegalTarget: legalMoveTargets.contains(sq),
                        isHighlighted: highlightedSquares.contains(sq)
                    )
                    .position(position(for: sq, squareSize: squareSize, boardSize: size))
                    .onTapGesture {
                        onSquareTapped?(sq)
                    }
                }

                // Rank and file labels
                ForEach(0..<8, id: \.self) { i in
                    let rank = flipped ? i : 7 - i
                    let label = "\(rank + 1)"
                    Text(label)
                        .font(.system(size: squareSize * 0.22, weight: .semibold))
                        .foregroundStyle((rank % 2 == 0) ? Color(red: 0.94, green: 0.85, blue: 0.72).opacity(0.9) : Color(red: 0.71, green: 0.53, blue: 0.39).opacity(0.9))
                        .position(x: squareSize * 0.15, y: squareSize * CGFloat(i) + squareSize * 0.18)

                    let file = flipped ? 7 - i : i
                    let fileLabel = String("abcdefgh"["abcdefgh".index("abcdefgh".startIndex, offsetBy: file)])
                    Text(fileLabel)
                        .font(.system(size: squareSize * 0.22, weight: .semibold))
                        .foregroundStyle(((file + 0) % 2 == 0) ? Color(red: 0.71, green: 0.53, blue: 0.39).opacity(0.9) : Color(red: 0.94, green: 0.85, blue: 0.72).opacity(0.9))
                        .position(x: squareSize * CGFloat(i) + squareSize * 0.85, y: size - squareSize * 0.18)
                }
            }
            .frame(width: size, height: size)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    // Map display index (0-63) to a square number
    private func squareIndex(_ displayIndex: Int) -> Square {
        let displayRank = displayIndex / 8
        let displayFile = displayIndex % 8
        let boardRank = flipped ? displayRank : 7 - displayRank
        let boardFile = flipped ? 7 - displayFile : displayFile
        return boardFile + boardRank * 8
    }

    private func position(for sq: Square, squareSize: CGFloat, boardSize: CGFloat) -> CGPoint {
        let file = CGFloat(sq.file)
        let rank = CGFloat(sq.rank)
        let displayFile = flipped ? 7 - file : file
        let displayRank = flipped ? rank : 7 - rank
        return CGPoint(
            x: displayFile * squareSize + squareSize / 2,
            y: displayRank * squareSize + squareSize / 2
        )
    }
}

// MARK: - Square View

struct SquareView: View {
    let square: Square
    let piece: Piece?
    let squareSize: CGFloat
    let isSelected: Bool
    let isLegalTarget: Bool
    let isHighlighted: Bool

    var isLight: Bool {
        (square.file + square.rank) % 2 != 0
    }

    var backgroundColor: Color {
        if isSelected {
            return Color.yellow.opacity(0.75)
        } else if isHighlighted {
            return Color.orange.opacity(0.6)
        } else {
            return isLight ? Color(red: 0.94, green: 0.85, blue: 0.72) : Color(red: 0.71, green: 0.53, blue: 0.39)
        }
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(backgroundColor)
                .frame(width: squareSize, height: squareSize)

            // Legal move indicator
            if isLegalTarget {
                if piece != nil {
                    // Capture ring
                    Circle()
                        .strokeBorder(Color.black.opacity(0.3), lineWidth: squareSize * 0.06)
                        .frame(width: squareSize * 0.9, height: squareSize * 0.9)
                } else {
                    // Move dot
                    Circle()
                        .fill(Color.black.opacity(0.22))
                        .frame(width: squareSize * 0.3, height: squareSize * 0.3)
                }
            }

            // Piece
            if let piece = piece {
                Text(piece.symbolString)
                    .font(.system(size: squareSize * 0.78))
                    .shadow(color: .black.opacity(0.3), radius: 1, x: 1, y: 1)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    BoardView(board: (try? FENParser.board(from: Board.startFEN)) ?? Board())
        .padding()
}
