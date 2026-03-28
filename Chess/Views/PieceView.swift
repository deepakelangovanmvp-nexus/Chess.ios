import SwiftUI

// MARK: - Entry point (API unchanged)

struct PieceView: View {
    let piece: Piece
    var size: CGFloat = 40

    var body: some View {
        BananaChessPiece(piece: piece)
            .frame(width: size, height: size)
            .shadow(color: .black.opacity(0.50), radius: 3, x: 1, y: 2)
    }
}

// MARK: - Banana-Themed Renderer

/// Renders a realistic Staunton-style chess piece silhouette.
/// White pieces use a warm banana-yellow → golden gradient.
/// Black pieces use a dark ebony → near-black gradient.
struct BananaChessPiece: View {
    let piece: Piece

    private var fillColors: [Color] {
        piece.color == .white
            ? [Color(red: 1.00, green: 0.94, blue: 0.35),
               Color(red: 0.96, green: 0.78, blue: 0.10)]
            : [Color(red: 0.24, green: 0.14, blue: 0.04),
               Color(red: 0.10, green: 0.05, blue: 0.01)]
    }

    private var strokeColor: Color {
        piece.color == .white
            ? Color(red: 0.62, green: 0.44, blue: 0.04)
            : Color(red: 0.96, green: 0.76, blue: 0.12)
    }

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            let lw   = max(1.0, side * 0.04)
            let s    = pieceShape
            ZStack {
                s.fill(LinearGradient(colors: fillColors,
                                      startPoint: .topLeading,
                                      endPoint: .bottomTrailing))
                // Subtle top-left shine to suggest roundness
                s.fill(RadialGradient(
                    colors: [Color.white.opacity(piece.color == .white ? 0.48 : 0.18),
                             Color.clear],
                    center: UnitPoint(x: 0.32, y: 0.24),
                    startRadius: 0,
                    endRadius: side * 0.55))
                s.stroke(strokeColor, lineWidth: lw)
            }
            .frame(width: side, height: side)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
    }

    private var pieceShape: AnyShape {
        switch piece.type {
        case .king:   AnyShape(KingPiece())
        case .queen:  AnyShape(QueenPiece())
        case .rook:   AnyShape(RookPiece())
        case .bishop: AnyShape(BishopPiece())
        case .knight: AnyShape(KnightPiece())
        case .pawn:   AnyShape(PawnPiece())
        }
    }
}

// MARK: - Piece Shapes
// All coordinates are expressed as fractions of rect.width / rect.height
// so pieces scale correctly at any size.

// ── Pawn ──────────────────────────────────────────────────────────────────────
struct PawnPiece: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        let x = rect.minX,  y = rect.minY
        let cx = x + w / 2

        // Head
        p.addEllipse(in: CGRect(x: cx - w*0.20, y: y + h*0.05,
                                width: w*0.40, height: h*0.38))
        // Neck
        p.move(to: CGPoint(x: cx - w*0.08, y: y + h*0.40))
        p.addLine(to: CGPoint(x: cx - w*0.08, y: y + h*0.54))
        p.addLine(to: CGPoint(x: cx + w*0.08, y: y + h*0.54))
        p.addLine(to: CGPoint(x: cx + w*0.08, y: y + h*0.40))
        p.closeSubpath()
        // Body
        p.addEllipse(in: CGRect(x: cx - w*0.24, y: y + h*0.50,
                                width: w*0.48, height: h*0.24))
        // Stem (trapezoid)
        p.move(to: CGPoint(x: cx - w*0.15, y: y + h*0.72))
        p.addLine(to: CGPoint(x: cx - w*0.19, y: y + h*0.84))
        p.addLine(to: CGPoint(x: cx + w*0.19, y: y + h*0.84))
        p.addLine(to: CGPoint(x: cx + w*0.15, y: y + h*0.72))
        p.closeSubpath()
        // Base
        p.addEllipse(in: CGRect(x: x + w*0.10, y: y + h*0.82,
                                width: w*0.80, height: h*0.14))
        return p
    }
}

// ── Rook ──────────────────────────────────────────────────────────────────────
struct RookPiece: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        let x = rect.minX,  y = rect.minY

        // Three crenellations (battlements)
        for bx: CGFloat in [0.10, 0.40, 0.70] {
            p.addRect(CGRect(x: x + w*bx, y: y + h*0.04,
                             width: w*0.20, height: h*0.20))
        }
        // Main body
        p.addRoundedRect(
            in: CGRect(x: x + w*0.18, y: y + h*0.18,
                       width: w*0.64, height: h*0.62),
            cornerSize: CGSize(width: w*0.05, height: h*0.05))
        // Stem
        p.move(to: CGPoint(x: x + w*0.22, y: y + h*0.78))
        p.addLine(to: CGPoint(x: x + w*0.12, y: y + h*0.84))
        p.addLine(to: CGPoint(x: x + w*0.88, y: y + h*0.84))
        p.addLine(to: CGPoint(x: x + w*0.78, y: y + h*0.78))
        p.closeSubpath()
        // Base
        p.addEllipse(in: CGRect(x: x + w*0.08, y: y + h*0.82,
                                width: w*0.84, height: h*0.14))
        return p
    }
}

// ── Knight ────────────────────────────────────────────────────────────────────
struct KnightPiece: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        let x = rect.minX,  y = rect.minY

        func pt(_ rx: CGFloat, _ ry: CGFloat) -> CGPoint {
            CGPoint(x: x + w * rx, y: y + h * ry)
        }

        // Horse-head silhouette facing right
        p.move(to: pt(0.16, 0.92))
        p.addQuadCurve(to: pt(0.84, 0.92), control: pt(0.50, 0.99)) // base arc
        p.addLine(to: pt(0.72, 0.80))
        p.addLine(to: pt(0.64, 0.64))
        p.addQuadCurve(to: pt(0.72, 0.50), control: pt(0.72, 0.58)) // chin dip
        p.addLine(to: pt(0.74, 0.40))
        p.addQuadCurve(to: pt(0.66, 0.28), control: pt(0.80, 0.32)) // muzzle bridge
        p.addLine(to: pt(0.66, 0.18))
        p.addLine(to: pt(0.72, 0.06))                                // ear tip
        p.addLine(to: pt(0.60, 0.15))                                // ear back
        p.addQuadCurve(to: pt(0.34, 0.22), control: pt(0.50, 0.09)) // crown/mane
        p.addQuadCurve(to: pt(0.24, 0.50), control: pt(0.26, 0.34)) // back of neck
        p.addLine(to: pt(0.28, 0.80))
        p.closeSubpath()
        // Separate base disc
        p.addEllipse(in: CGRect(x: x + w*0.08, y: y + h*0.88,
                                width: w*0.84, height: h*0.10))
        return p
    }
}

// ── Bishop ────────────────────────────────────────────────────────────────────
struct BishopPiece: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        let x = rect.minX,  y = rect.minY
        let cx = x + w / 2

        // Finial ball at tip
        p.addEllipse(in: CGRect(x: cx - w*0.08, y: y + h*0.02,
                                width: w*0.16, height: h*0.14))
        // Mitre (bishop's hat — tall diamond-curve)
        p.move(to: CGPoint(x: cx, y: y + h*0.06))
        p.addQuadCurve(to: CGPoint(x: cx + w*0.22, y: y + h*0.40),
                       control: CGPoint(x: cx + w*0.30, y: y + h*0.22))
        p.addLine(to: CGPoint(x: cx - w*0.22, y: y + h*0.40))
        p.addQuadCurve(to: CGPoint(x: cx, y: y + h*0.06),
                       control: CGPoint(x: cx - w*0.30, y: y + h*0.22))
        p.closeSubpath()
        // Collar
        p.addEllipse(in: CGRect(x: cx - w*0.27, y: y + h*0.38,
                                width: w*0.54, height: h*0.14))
        // Body
        p.addEllipse(in: CGRect(x: cx - w*0.22, y: y + h*0.48,
                                width: w*0.44, height: h*0.24))
        // Stem
        p.move(to: CGPoint(x: cx - w*0.14, y: y + h*0.70))
        p.addLine(to: CGPoint(x: cx - w*0.19, y: y + h*0.84))
        p.addLine(to: CGPoint(x: cx + w*0.19, y: y + h*0.84))
        p.addLine(to: CGPoint(x: cx + w*0.14, y: y + h*0.70))
        p.closeSubpath()
        // Base
        p.addEllipse(in: CGRect(x: x + w*0.08, y: y + h*0.82,
                                width: w*0.84, height: h*0.14))
        return p
    }
}

// ── Queen ─────────────────────────────────────────────────────────────────────
struct QueenPiece: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        let x = rect.minX,  y = rect.minY
        let cx = x + w / 2

        // Five crown balls
        let ballR = w * 0.07
        for bx: CGFloat in [0.12, 0.28, 0.50, 0.72, 0.88] {
            p.addEllipse(in: CGRect(x: x + w*bx - ballR, y: y + h*0.04 - ballR,
                                    width: ballR * 2, height: ballR * 2))
        }
        // Crown zigzag + body outline
        p.move(to: CGPoint(x: x + w*0.08, y: y + h*0.32))
        p.addLine(to: CGPoint(x: x + w*0.12, y: y + h*0.14))
        p.addLine(to: CGPoint(x: x + w*0.24, y: y + h*0.24))
        p.addLine(to: CGPoint(x: x + w*0.30, y: y + h*0.10))
        p.addLine(to: CGPoint(x: x + w*0.42, y: y + h*0.22))
        p.addLine(to: CGPoint(x: cx,          y: y + h*0.08))
        p.addLine(to: CGPoint(x: x + w*0.58, y: y + h*0.22))
        p.addLine(to: CGPoint(x: x + w*0.70, y: y + h*0.10))
        p.addLine(to: CGPoint(x: x + w*0.76, y: y + h*0.24))
        p.addLine(to: CGPoint(x: x + w*0.88, y: y + h*0.14))
        p.addLine(to: CGPoint(x: x + w*0.92, y: y + h*0.32))
        p.addQuadCurve(to: CGPoint(x: cx + w*0.30, y: y + h*0.72),
                       control: CGPoint(x: x + w*0.94, y: y + h*0.54))
        p.addLine(to: CGPoint(x: cx + w*0.18, y: y + h*0.84))
        p.addQuadCurve(to: CGPoint(x: cx - w*0.18, y: y + h*0.84),
                       control: CGPoint(x: cx, y: y + h*0.96))
        p.addLine(to: CGPoint(x: cx - w*0.30, y: y + h*0.72))
        p.addQuadCurve(to: CGPoint(x: x + w*0.08, y: y + h*0.32),
                       control: CGPoint(x: x + w*0.06, y: y + h*0.54))
        p.closeSubpath()
        // Base
        p.addEllipse(in: CGRect(x: x + w*0.08, y: y + h*0.82,
                                width: w*0.84, height: h*0.14))
        return p
    }
}

// ── King ──────────────────────────────────────────────────────────────────────
struct KingPiece: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        let x = rect.minX,  y = rect.minY
        let cx = x + w / 2

        // Cross — vertical arm
        p.addRoundedRect(
            in: CGRect(x: cx - w*0.07, y: y + h*0.02,
                       width: w*0.14, height: h*0.26),
            cornerSize: CGSize(width: w*0.03, height: h*0.03))
        // Cross — horizontal arm
        p.addRoundedRect(
            in: CGRect(x: cx - w*0.18, y: y + h*0.08,
                       width: w*0.36, height: h*0.10),
            cornerSize: CGSize(width: w*0.03, height: h*0.03))
        // Collar below cross
        p.addEllipse(in: CGRect(x: cx - w*0.26, y: y + h*0.24,
                                width: w*0.52, height: h*0.12))
        // Body
        p.addEllipse(in: CGRect(x: cx - w*0.26, y: y + h*0.32,
                                width: w*0.52, height: h*0.28))
        // Stem
        p.move(to: CGPoint(x: cx - w*0.14, y: y + h*0.58))
        p.addLine(to: CGPoint(x: cx - w*0.18, y: y + h*0.84))
        p.addLine(to: CGPoint(x: cx + w*0.18, y: y + h*0.84))
        p.addLine(to: CGPoint(x: cx + w*0.14, y: y + h*0.58))
        p.closeSubpath()
        // Base
        p.addEllipse(in: CGRect(x: x + w*0.08, y: y + h*0.82,
                                width: w*0.84, height: h*0.14))
        return p
    }
}
