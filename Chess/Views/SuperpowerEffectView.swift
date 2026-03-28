import SwiftUI

// Struct to track an ongoing animation
struct ActiveAnimation: Equatable {
    let position: Position
    let piece: Piece
    let id = UUID()
}

struct SuperpowerEffectView: View {
    let animation: ActiveAnimation?
    let squareSize: CGFloat

    @State private var phase: Double = 0.0

    var body: some View {
        ZStack {
            if let animation = animation {
                effect(for: animation.piece)
                    .onAppear {
                        phase = 0.0
                        withAnimation(.easeOut(duration: 0.8)) {
                            phase = 1.0
                        }
                    }
                    .id(animation.id)
            }
        }
        .frame(width: squareSize, height: squareSize)
        .allowsHitTesting(false)
    }

    @ViewBuilder
    func effect(for piece: Piece) -> some View {
        let isWhite = piece.color == .white
        switch piece.type {
        case .king:
            if isWhite {
                // Iron Man Repulsor
                Circle()
                    .fill(Color.cyan)
                    .opacity(1.0 - phase)
                    .scaleEffect(0.2 + (phase * 2.0))
            } else {
                // Batman Smoke
                Circle()
                    .fill(Color.gray.opacity(0.8))
                    .blur(radius: phase * 10)
                    .opacity(1.0 - phase)
                    .scaleEffect(0.5 + phase * 1.5)
            }
        case .queen:
            if isWhite {
                // Captain Marvel Cosmic
                Circle()
                    .fill(RadialGradient(gradient: Gradient(colors: [.yellow, .blue, .clear]), center: .center, startRadius: 0, endRadius: squareSize))
                    .opacity(1.0 - phase)
                    .scaleEffect(phase * 1.5)
            } else {
                // Wonder Woman Lasso/Shield Clash
                Circle()
                    .stroke(Color.yellow, lineWidth: 5)
                    .opacity(1.0 - (phase * 1.5))
                    .scaleEffect(phase * 2.0)
            }
        case .rook:
            if isWhite {
                // Hulk Smash (Green Shockwave)
                Circle()
                    .stroke(Color.green, lineWidth: 10 * (1.0 - phase))
                    .scaleEffect(phase * 1.5)
                    .opacity(1.0 - phase)
            } else {
                // Superman Heat Vision Flash
                Rectangle()
                    .fill(Color.red)
                    .opacity((1.0 - phase) * 0.8)
            }
        case .bishop:
            if isWhite {
                // Doctor Strange Portal
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 4, dash: [10, 5]))
                    .foregroundColor(.orange)
                    .rotationEffect(.degrees(phase * 360))
                    .scaleEffect(0.5 + phase * 0.6)
                    .opacity(1.0 - phase)
            } else {
                // Green Lantern Ring
                Circle()
                    .stroke(Color.green, lineWidth: 8)
                    .shadow(color: .green, radius: 10)
                    .scaleEffect(0.4 + phase)
                    .opacity(1.0 - phase)
            }
        case .knight:
            if isWhite {
                // Thor Lightning Flashes
                ZStack {
                    Path { path in
                        path.move(to: CGPoint(x: squareSize * 0.2, y: 0))
                        path.addLine(to: CGPoint(x: squareSize * 0.5, y: squareSize * 0.5))
                        path.addLine(to: CGPoint(x: squareSize * 0.3, y: squareSize * 0.6))
                        path.addLine(to: CGPoint(x: squareSize * 0.8, y: squareSize))
                    }
                    .stroke(Color.yellow, lineWidth: 4)
                }
                .opacity((phase < 0.2 || (phase > 0.4 && phase < 0.6)) ? 1 : 0) // Flicker
            } else {
                // Flash Speed Streak
                Rectangle()
                    .fill(LinearGradient(gradient: Gradient(colors: [.yellow, .red, .clear]), startPoint: .leading, endPoint: .trailing))
                    .frame(height: 10)
                    .offset(x: -squareSize + (phase * squareSize * 2))
                    .opacity(1.0 - phase)
            }
        case .pawn:
            if isWhite {
                // Spider-Man Web Spread
                ZStack {
                    Rectangle().frame(width: 2, height: squareSize * phase)
                    Rectangle().frame(width: squareSize * phase, height: 2)
                    Rectangle().frame(width: 2, height: squareSize * phase).rotationEffect(.degrees(45))
                    Rectangle().frame(width: squareSize * phase, height: 2).rotationEffect(.degrees(45))
                }
                .foregroundColor(.white)
                .opacity(1.0 - phase)
            } else {
                // Aquaman Splash
                ZStack {
                    Circle().fill(Color.blue).frame(width: 8).offset(x: -15 * phase, y: -20 * phase)
                    Circle().fill(Color.blue).frame(width: 6).offset(x: 10 * phase, y: -25 * phase)
                    Circle().fill(Color.blue).frame(width: 10).offset(x: 5 * phase, y: -15 * phase)
                }
                .opacity(1.0 - phase)
            }
        }
    }
}
