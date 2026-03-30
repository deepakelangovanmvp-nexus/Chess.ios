import SwiftUI

struct SquareView: View {
    let position: Position
    let piece: Piece?
    let isSelected: Bool
    let isValidMove: Bool
    let isLastMoveFrom: Bool
    let isLastMoveTo: Bool
    let isKingInCheck: Bool
    let isCoachHint: Bool
    let squareSize: CGFloat

    var isLight: Bool {
        (position.row + position.col) % 2 != 0
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(backgroundColor)

            if isValidMove {
                if piece != nil {
                    Circle()
                        .strokeBorder(ChessTheme.validMoveDot, lineWidth: 3)
                        .frame(width: squareSize * 0.85, height: squareSize * 0.85)
                } else {
                    Circle()
                        .fill(ChessTheme.validMoveDot)
                        .frame(width: squareSize * 0.28, height: squareSize * 0.28)
                }
            }

            if let piece = piece {
                PieceView(piece: piece, size: squareSize * 0.95)
                    .transition(.scale)
            }

            if isCoachHint {
                Rectangle()
                    .stroke(Color.cyan, lineWidth: 3)
                    .shadow(color: .cyan, radius: 4)
            }
        }
        .frame(width: squareSize, height: squareSize)
    }

    var backgroundColor: Color {
        if isKingInCheck { return ChessTheme.checkSquare }
        if isSelected { return ChessTheme.selectedSquare }
        if isLastMoveFrom || isLastMoveTo {
            return isLight ? ChessTheme.lastMoveLightSquare : ChessTheme.lastMoveDarkSquare
        }
        return isLight ? ChessTheme.lightSquare : ChessTheme.darkSquare
    }
}
