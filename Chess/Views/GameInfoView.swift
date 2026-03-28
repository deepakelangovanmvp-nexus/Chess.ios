import SwiftUI

struct GameInfoView: View {
    @ObservedObject var game: GameManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Status
            HStack {
                Circle()
                    .fill(game.currentTurn == .white ? Color.white : ChessTheme.blackPiece)
                    .frame(width: 14, height: 14)
                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                Text(game.statusText)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(ChessTheme.textPrimary)
                if game.isThinking {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: ChessTheme.accent))
                        .scaleEffect(0.7)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(ChessTheme.cardBackground)
            .cornerRadius(10)

            // Captured pieces
            VStack(alignment: .leading, spacing: 6) {
                capturedRow(pieces: game.capturedByWhite, label: "White captured")
                capturedRow(pieces: game.capturedByBlack, label: "Black captured")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(ChessTheme.cardBackground)
            .cornerRadius(10)

            // Move history
            VStack(alignment: .leading, spacing: 6) {
                Text("Moves")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(ChessTheme.textSecondary)

                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 2) {
                            ForEach(0..<((game.moveNotations.count + 1) / 2), id: \.self) { i in
                                let moveNum = i + 1
                                HStack(spacing: 4) {
                                    Text("\(moveNum).")
                                        .font(.system(size: 12, design: .monospaced))
                                        .foregroundColor(ChessTheme.textSecondary)
                                        .frame(width: 28, alignment: .trailing)
                                    Text(game.moveNotations[i * 2])
                                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                                        .foregroundColor(ChessTheme.textPrimary)
                                        .frame(width: 60, alignment: .leading)
                                    if i * 2 + 1 < game.moveNotations.count {
                                        Text(game.moveNotations[i * 2 + 1])
                                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                                            .foregroundColor(ChessTheme.textPrimary)
                                            .frame(width: 60, alignment: .leading)
                                    }
                                    Spacer()
                                }
                                .id(moveNum)
                            }
                        }
                    }
                    .frame(maxHeight: 150)
                    .onChange(of: game.moveNotations.count) {
                        if let last = (0..<((game.moveNotations.count + 1) / 2)).last {
                            proxy.scrollTo(last + 1, anchor: .bottom)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(ChessTheme.cardBackground)
            .cornerRadius(10)
        }
    }

    func capturedRow(pieces: [Piece], label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(ChessTheme.textSecondary)
            if pieces.isEmpty {
                Text("—")
                    .font(.system(size: 14))
                    .foregroundColor(ChessTheme.textSecondary.opacity(0.5))
            } else {
                Text(pieces.sorted(by: { $0.type.value > $1.type.value }).map { $0.symbol }.joined())
                    .font(.system(size: 18))
            }
        }
    }
}
