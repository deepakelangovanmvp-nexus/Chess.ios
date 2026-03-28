import SwiftUI

struct ChessTheme {
    static let lightSquare = Color(red: 0.65, green: 0.67, blue: 0.68)  // Light stone marble
    static let darkSquare = Color(red: 0.25, green: 0.28, blue: 0.30)   // Dark slate/obsidian
    static let selectedSquare = Color(red: 0.30, green: 0.60, blue: 0.80).opacity(0.8) // Mystical blue glow
    static let lastMoveLightSquare = Color(red: 0.55, green: 0.65, blue: 0.70)
    static let lastMoveDarkSquare = Color(red: 0.20, green: 0.35, blue: 0.45)
    static let validMoveDot = Color.black.opacity(0.6)
    static let checkSquare = Color(red: 0.80, green: 0.10, blue: 0.20).opacity(0.8) // Blood red

    static let background = Color(red: 0.15, green: 0.15, blue: 0.18)
    static let panelBackground = Color(red: 0.20, green: 0.20, blue: 0.24)
    static let cardBackground = Color(red: 0.25, green: 0.25, blue: 0.30)
    static let accent = Color(red: 0.85, green: 0.70, blue: 0.35)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let whitePiece = Color.white
    static let blackPiece = Color(red: 0.15, green: 0.15, blue: 0.18)

    static let boardBorder = Color(red: 0.30, green: 0.22, blue: 0.14)
    static let boardBorderWidth: CGFloat = 6
    static let cornerRadius: CGFloat = 12
    static let pieceFont: Font = .system(size: 40, weight: .medium)
    static let smallPieceFont: Font = .system(size: 20)
    static let labelFont: Font = .system(size: 10, weight: .semibold, design: .monospaced)
}
