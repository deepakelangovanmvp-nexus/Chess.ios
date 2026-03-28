import SwiftUI

struct PromotionView: View {
    @ObservedObject var game: GameManager

    let promotionTypes: [PieceType] = [.queen, .rook, .bishop, .knight]

    var body: some View {
        if game.showingPromotion {
            ZStack {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    Text("Promote Pawn")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(ChessTheme.textPrimary)

                    HStack(spacing: 12) {
                        ForEach(promotionTypes, id: \.self) { type in
                            let color = game.pendingPromotionMove?.piece.color ?? .white
                            let piece = Piece(type: type, color: color)

                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    game.completePromotion(with: type)
                                }
                            }) {
                                VStack(spacing: 4) {
                                    Text(piece.symbol)
                                        .font(.system(size: 44))
                                    Text(type.rawValue.capitalized)
                                        .font(.system(size: 11, weight: .medium, design: .rounded))
                                        .foregroundColor(ChessTheme.textSecondary)
                                }
                                .frame(width: 70, height: 80)
                                .background(ChessTheme.cardBackground)
                                .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding(24)
                .background(ChessTheme.panelBackground)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.5), radius: 20)
            }
            .transition(.opacity)
        }
    }
}
