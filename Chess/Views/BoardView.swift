import SwiftUI

struct BoardView: View {
    @ObservedObject var game: GameManager

    var body: some View {
        GeometryReader { geometry in
            let boardSize = min(geometry.size.width, geometry.size.height)
            let squareSize = (boardSize - ChessTheme.boardBorderWidth * 2) / 8

            VStack(spacing: 0) {
                ForEach((0..<8).reversed(), id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<8, id: \.self) { col in
                            let pos = Position(row: row, col: col)
                            let isHint = game.isCoachModeEnabled && (game.suggestedMove?.from == pos || game.suggestedMove?.to == pos)
                            ZStack {
                                SquareView(
                                    position: pos,
                                    piece: game.board.piece(at: pos),
                                    isSelected: game.selectedPosition == pos,
                                    isValidMove: game.validMoves.contains(where: { $0.to == pos }),
                                    isLastMoveFrom: game.lastMove?.from == pos,
                                    isLastMoveTo: game.lastMove?.to == pos,
                                    isKingInCheck: game.isKingInCheck(at: pos),
                                    isCoachHint: isHint,
                                    squareSize: squareSize
                                )
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        game.handleTap(at: pos)
                                    }
                                }

                                if let anim = game.activeAnimation, anim.position == pos {
                                    SuperpowerEffectView(animation: anim, squareSize: squareSize)
                                }
                            }
                        }
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(ChessTheme.boardBorder, lineWidth: ChessTheme.boardBorderWidth)
            )
            // Illuminated glass-and-marble board glow — cyan from beneath, purple haze depth
            .shadow(color: Color.cyan.opacity(0.18), radius: 28, x: 0, y: 0)
            .shadow(color: Color(red: 0.35, green: 0.20, blue: 0.55).opacity(0.22), radius: 50, x: 0, y: 12)
            .shadow(color: Color.black.opacity(0.60), radius: 10, x: 0, y: 6)
            .frame(width: boardSize, height: boardSize)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
