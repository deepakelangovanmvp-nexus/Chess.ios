import SwiftUI

struct ChessTheme {
    // Board squares — illuminated glass-marble surface
    static let lightSquare = Color(red: 0.68, green: 0.72, blue: 0.78)  // Luminous glass-marble
    static let darkSquare  = Color(red: 0.14, green: 0.15, blue: 0.20)  // Dark obsidian slab
    static let selectedSquare = Color(red: 0.15, green: 0.72, blue: 0.92).opacity(0.85) // Cyan arc-glow
    static let lastMoveLightSquare = Color(red: 0.56, green: 0.66, blue: 0.74)
    static let lastMoveDarkSquare  = Color(red: 0.18, green: 0.32, blue: 0.46)
    static let validMoveDot = Color.black.opacity(0.65)
    static let checkSquare  = Color(red: 0.82, green: 0.10, blue: 0.18).opacity(0.85) // Blood red

    // Cinematic dark background — deep space / volumetric shadow
    static let background      = Color(red: 0.06, green: 0.06, blue: 0.10)
    static let panelBackground = Color(red: 0.12, green: 0.12, blue: 0.17)
    static let cardBackground  = Color(red: 0.18, green: 0.18, blue: 0.24)
    static let accent          = Color(red: 0.85, green: 0.70, blue: 0.35)
    static let textPrimary     = Color.white
    static let textSecondary   = Color.white.opacity(0.70)
    static let whitePiece      = Color.white
    static let blackPiece      = Color(red: 0.10, green: 0.10, blue: 0.14)

    // Board frame — dark metallic border
    static let boardBorder      = Color(red: 0.22, green: 0.18, blue: 0.30)
    static let boardBorderWidth: CGFloat = 6
    static let cornerRadius:     CGFloat = 12
    static let pieceFont:        Font    = .system(size: 40, weight: .medium)
    static let smallPieceFont:   Font    = .system(size: 20)
    static let labelFont:        Font    = .system(size: 10, weight: .semibold, design: .monospaced)
}
