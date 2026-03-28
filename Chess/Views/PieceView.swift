import SwiftUI

// MARK: - Hero Colour Palette

struct HeroColors {
    let highlight: Color
    let main:      Color
    let shade:     Color
    let accent:    Color
    let glow:      Color
}

private extension HeroColors {
    var bodyGrad: LinearGradient {
        LinearGradient(colors: [highlight, main, shade],
                       startPoint: UnitPoint(x: 0.22, y: 0.05),
                       endPoint:   UnitPoint(x: 0.82, y: 0.95))
    }
    var headGrad: RadialGradient {
        RadialGradient(colors: [highlight, main, shade],
                       center: UnitPoint(x: 0.34, y: 0.28),
                       startRadius: 0, endRadius: 40)
    }
    var baseGrad: LinearGradient {
        LinearGradient(colors: [main, shade],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

// MARK: - PieceView

struct PieceView: View {
    let piece: Piece
    var size: CGFloat = 40

    var body: some View {
        heroPiece
            .frame(width: size, height: size)
            .shadow(color: palette.glow.opacity(0.70), radius: 10, x: 0, y: 4)
            .shadow(color: palette.glow.opacity(0.28), radius: 22, x: 0, y: 0)
            .shadow(color: .black.opacity(0.55), radius: 4, x: 1, y: 3)
    }

    @ViewBuilder
    private var heroPiece: some View {
        switch (piece.color, piece.type) {
        case (.white, .king):   IronManPiece(c: palette)
        case (.white, .queen):  CaptainMarvelPiece(c: palette)
        case (.white, .rook):   HulkPiece(c: palette)
        case (.white, .bishop): DrStrangePiece(c: palette)
        case (.white, .knight): ThorPiece(c: palette)
        case (.white, .pawn):   SpiderManPiece(c: palette)
        case (.black, .king):   BatmanPiece(c: palette)
        case (.black, .queen):  WonderWomanPiece(c: palette)
        case (.black, .rook):   SupermanPiece(c: palette)
        case (.black, .bishop): GreenLanternPiece(c: palette)
        case (.black, .knight): FlashPiece(c: palette)
        case (.black, .pawn):   AquamanPiece(c: palette)
        default:                EmptyView()
        }
    }

    // swiftlint:disable cyclomatic_complexity
    private var palette: HeroColors {
        switch (piece.color, piece.type) {
        case (.white, .king):
            return HeroColors(highlight: Color(red:1.00,green:0.90,blue:0.55),
                              main: Color(red:0.80,green:0.10,blue:0.08),
                              shade: Color(red:0.36,green:0.04,blue:0.04),
                              accent: Color(red:1.00,green:0.72,blue:0.00), glow: .cyan)
        case (.white, .queen):
            return HeroColors(highlight: Color(red:0.72,green:0.88,blue:1.00),
                              main: Color(red:0.10,green:0.24,blue:0.76),
                              shade: Color(red:0.04,green:0.10,blue:0.40),
                              accent: Color(red:0.90,green:0.14,blue:0.10),
                              glow: Color(red:0.40,green:0.70,blue:1.00))
        case (.white, .rook):
            return HeroColors(highlight: Color(red:0.62,green:1.00,blue:0.52),
                              main: Color(red:0.14,green:0.58,blue:0.14),
                              shade: Color(red:0.05,green:0.24,blue:0.05),
                              accent: Color(red:0.40,green:0.80,blue:0.30),
                              glow: Color(red:0.28,green:0.90,blue:0.28))
        case (.white, .bishop):
            return HeroColors(highlight: Color(red:1.00,green:0.80,blue:0.30),
                              main: Color(red:0.52,green:0.06,blue:0.52),
                              shade: Color(red:0.22,green:0.02,blue:0.30),
                              accent: Color(red:1.00,green:0.58,blue:0.00),
                              glow: Color(red:0.90,green:0.60,blue:0.10))
        case (.white, .knight):
            return HeroColors(highlight: Color(red:0.92,green:0.95,blue:1.00),
                              main: Color(red:0.52,green:0.58,blue:0.78),
                              shade: Color(red:0.20,green:0.24,blue:0.46),
                              accent: Color(red:0.85,green:0.12,blue:0.10),
                              glow: Color(red:0.60,green:0.70,blue:1.00))
        case (.white, .pawn):
            return HeroColors(highlight: Color(red:1.00,green:0.62,blue:0.58),
                              main: Color(red:0.84,green:0.10,blue:0.10),
                              shade: Color(red:0.40,green:0.04,blue:0.04),
                              accent: Color(red:0.10,green:0.12,blue:0.80),
                              glow: Color(red:1.00,green:0.28,blue:0.28))
        case (.black, .king):
            return HeroColors(highlight: Color(red:0.60,green:0.60,blue:0.68),
                              main: Color(red:0.17,green:0.17,blue:0.22),
                              shade: Color(red:0.04,green:0.04,blue:0.06),
                              accent: Color(red:0.92,green:0.76,blue:0.10),
                              glow: Color(red:0.90,green:0.75,blue:0.10))
        case (.black, .queen):
            return HeroColors(highlight: Color(red:1.00,green:0.80,blue:0.50),
                              main: Color(red:0.58,green:0.06,blue:0.06),
                              shade: Color(red:0.26,green:0.02,blue:0.02),
                              accent: Color(red:0.95,green:0.76,blue:0.10),
                              glow: Color(red:1.00,green:0.65,blue:0.10))
        case (.black, .rook):
            return HeroColors(highlight: Color(red:0.55,green:0.62,blue:1.00),
                              main: Color(red:0.10,green:0.14,blue:0.72),
                              shade: Color(red:0.04,green:0.06,blue:0.36),
                              accent: Color(red:0.90,green:0.10,blue:0.10),
                              glow: Color(red:0.30,green:0.40,blue:1.00))
        case (.black, .bishop):
            return HeroColors(highlight: Color(red:0.40,green:1.00,blue:0.40),
                              main: Color(red:0.05,green:0.08,blue:0.05),
                              shade: Color(red:0.02,green:0.04,blue:0.02),
                              accent: Color(red:0.10,green:0.92,blue:0.10),
                              glow: Color(red:0.10,green:0.90,blue:0.20))
        case (.black, .knight):
            return HeroColors(highlight: Color(red:1.00,green:0.90,blue:0.50),
                              main: Color(red:0.84,green:0.10,blue:0.06),
                              shade: Color(red:0.40,green:0.04,blue:0.02),
                              accent: Color(red:1.00,green:0.82,blue:0.00),
                              glow: Color(red:1.00,green:0.80,blue:0.00))
        case (.black, .pawn):
            return HeroColors(highlight: Color(red:0.38,green:0.86,blue:1.00),
                              main: Color(red:0.05,green:0.28,blue:0.56),
                              shade: Color(red:0.02,green:0.12,blue:0.28),
                              accent: Color(red:0.92,green:0.76,blue:0.10),
                              glow: Color(red:0.20,green:0.70,blue:1.00))
        default:
            return HeroColors(highlight: .white, main: .gray, shade: .black,
                              accent: .white, glow: .white)
        }
    }
    // swiftlint:enable cyclomatic_complexity
}

// MARK: - Shared helpers

/// Wide oval base at the bottom of every piece.
private func pieceBase(w: CGFloat, h: CGFloat, c: HeroColors) -> some View {
    Ellipse()
        .fill(c.baseGrad)
        .shadow(color: .black.opacity(0.45), radius: 3, x: 0, y: 2)
        .frame(width: w * 0.86, height: h * 0.12)
        .position(x: w / 2, y: h * 0.93)
}

// MARK: - Reusable shapes

struct LightningBoltShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        p.move(to:    CGPoint(x: w*0.62, y: 0))
        p.addLine(to: CGPoint(x: w*0.24, y: h*0.48))
        p.addLine(to: CGPoint(x: w*0.50, y: h*0.48))
        p.addLine(to: CGPoint(x: w*0.38, y: h))
        p.addLine(to: CGPoint(x: w*0.76, y: h*0.52))
        p.addLine(to: CGPoint(x: w*0.50, y: h*0.52))
        p.closeSubpath()
        return p
    }
}

struct StarShape: Shape {
    let points: Int
    func path(in rect: CGRect) -> Path {
        let cx = rect.midX, cy = rect.midY
        let outer = min(rect.width, rect.height) / 2
        let inner = outer * 0.42
        let step  = Double.pi * 2 / Double(points)
        var p = Path()
        for i in 0..<points {
            let a1 = step * Double(i) - Double.pi / 2
            let a2 = a1 + step / 2
            let op = CGPoint(x: cx + CGFloat(cos(a1))*outer, y: cy + CGFloat(sin(a1))*outer)
            let ip = CGPoint(x: cx + CGFloat(cos(a2))*inner, y: cy + CGFloat(sin(a2))*inner)
            if i == 0 { p.move(to: op) } else { p.addLine(to: op) }
            p.addLine(to: ip)
        }
        p.closeSubpath()
        return p
    }
}

struct BatSignalShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        p.move(to:    CGPoint(x: w*0.50, y: 0))
        p.addLine(to: CGPoint(x: w*0.35, y: h*0.38))
        p.addLine(to: CGPoint(x: w*0.10, y: h*0.28))
        p.addLine(to: CGPoint(x: w*0.20, y: h))
        p.addLine(to: CGPoint(x: w*0.35, y: h*0.65))
        p.addLine(to: CGPoint(x: w*0.50, y: h))
        p.addLine(to: CGPoint(x: w*0.65, y: h*0.65))
        p.addLine(to: CGPoint(x: w*0.80, y: h))
        p.addLine(to: CGPoint(x: w*0.90, y: h*0.28))
        p.addLine(to: CGPoint(x: w*0.65, y: h*0.38))
        p.closeSubpath()
        return p
    }
}

// MARK: - Iron Man (King)
// Angular red-gold armour · angular helmet · cyan arc reactor · glowing eye slits

struct IronManPiece: View {
    let c: HeroColors
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack {
                pieceBase(w: w, h: h, c: c)
                // Armoured body
                Path { p in
                    p.move(to: CGPoint(x: w*0.10, y: h*0.82))
                    p.addLine(to: CGPoint(x: w*0.90, y: h*0.82))
                    p.addLine(to: CGPoint(x: w*0.78, y: h*0.38))
                    p.addLine(to: CGPoint(x: w*0.58, y: h*0.34))
                    p.addLine(to: CGPoint(x: w*0.42, y: h*0.34))
                    p.addLine(to: CGPoint(x: w*0.22, y: h*0.38))
                    p.closeSubpath()
                }.fill(c.bodyGrad)
                // Arc reactor
                Circle()
                    .fill(RadialGradient(colors: [Color.cyan, Color.cyan.opacity(0.3), .clear],
                                        center: .center, startRadius: 0, endRadius: 8))
                    .frame(width: w*0.16, height: w*0.16)
                    .position(x: w/2, y: h*0.59)
                Circle()
                    .strokeBorder(Color.cyan.opacity(0.70), lineWidth: 1)
                    .frame(width: w*0.20, height: w*0.20)
                    .position(x: w/2, y: h*0.59)
                // Angular helmet
                Path { p in
                    p.move(to: CGPoint(x: w*0.30, y: h*0.34))
                    p.addLine(to: CGPoint(x: w*0.70, y: h*0.34))
                    p.addLine(to: CGPoint(x: w*0.80, y: h*0.22))
                    p.addLine(to: CGPoint(x: w*0.76, y: h*0.08))
                    p.addLine(to: CGPoint(x: w*0.60, y: h*0.02))
                    p.addLine(to: CGPoint(x: w*0.40, y: h*0.02))
                    p.addLine(to: CGPoint(x: w*0.24, y: h*0.08))
                    p.addLine(to: CGPoint(x: w*0.20, y: h*0.22))
                    p.closeSubpath()
                }.fill(c.bodyGrad)
                // Gold faceplate
                Path { p in
                    p.move(to: CGPoint(x: w*0.34, y: h*0.32))
                    p.addLine(to: CGPoint(x: w*0.66, y: h*0.32))
                    p.addLine(to: CGPoint(x: w*0.62, y: h*0.14))
                    p.addLine(to: CGPoint(x: w*0.50, y: h*0.09))
                    p.addLine(to: CGPoint(x: w*0.38, y: h*0.14))
                    p.closeSubpath()
                }.fill(LinearGradient(colors: [c.accent, c.accent.opacity(0.60)],
                                      startPoint: .top, endPoint: .bottom))
                // Glowing cyan eye slits
                ForEach([CGFloat(-0.10), 0.10], id: \.self) { offset in
                    Capsule()
                        .fill(Color.cyan)
                        .shadow(color: Color.cyan, radius: 2)
                        .frame(width: w*0.12, height: h*0.030)
                        .position(x: w/2 + offset*w, y: h*0.236)
                }
                // Specular
                Ellipse()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: w*0.10, height: h*0.06)
                    .position(x: w*0.36, y: h*0.11)
            }
        }
    }
}

// MARK: - Captain Marvel (Queen)
// Blue-red figure · red sash · gold 4-pointed star · mohawk crest

struct CaptainMarvelPiece: View {
    let c: HeroColors
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack {
                pieceBase(w: w, h: h, c: c)
                // Body
                Path { p in
                    p.move(to: CGPoint(x: w*0.10, y: h*0.82))
                    p.addLine(to: CGPoint(x: w*0.90, y: h*0.82))
                    p.addCurve(to: CGPoint(x: w*0.72, y: h*0.36),
                               control1: CGPoint(x: w*0.90, y: h*0.62),
                               control2: CGPoint(x: w*0.80, y: h*0.42))
                    p.addLine(to: CGPoint(x: w*0.60, y: h*0.32))
                    p.addLine(to: CGPoint(x: w*0.40, y: h*0.32))
                    p.addLine(to: CGPoint(x: w*0.28, y: h*0.36))
                    p.addCurve(to: CGPoint(x: w*0.10, y: h*0.82),
                               control1: CGPoint(x: w*0.20, y: h*0.42),
                               control2: CGPoint(x: w*0.10, y: h*0.62))
                    p.closeSubpath()
                }.fill(c.bodyGrad)
                // Red sash band
                Path { p in
                    p.move(to: CGPoint(x: w*0.14, y: h*0.68))
                    p.addLine(to: CGPoint(x: w*0.86, y: h*0.68))
                    p.addLine(to: CGPoint(x: w*0.82, y: h*0.58))
                    p.addLine(to: CGPoint(x: w*0.18, y: h*0.58))
                    p.closeSubpath()
                }.fill(c.accent.opacity(0.80))
                // Gold 4-pointed star
                StarShape(points: 4)
                    .fill(c.accent)
                    .frame(width: w*0.20, height: w*0.20)
                    .position(x: w/2, y: h*0.50)
                // Head
                Circle()
                    .fill(c.headGrad)
                    .frame(width: w*0.42, height: w*0.42)
                    .position(x: w/2, y: h*0.23)
                // Mohawk crest
                Path { p in
                    p.move(to: CGPoint(x: w*0.44, y: h*0.11))
                    p.addLine(to: CGPoint(x: w*0.50, y: h*0.01))
                    p.addLine(to: CGPoint(x: w*0.56, y: h*0.11))
                    p.closeSubpath()
                }.fill(c.accent)
                // Specular
                Ellipse()
                    .fill(Color.white.opacity(0.40))
                    .frame(width: w*0.10, height: w*0.07)
                    .position(x: w*0.40, y: h*0.16)
            }
        }
    }
}

// MARK: - Hulk (Rook)
// Massive full-width green figure · large head · angry brow · purple shorts

struct HulkPiece: View {
    let c: HeroColors
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack {
                pieceBase(w: w, h: h, c: c)
                // Massive torso – fills the full width
                Path { p in
                    p.move(to: CGPoint(x: w*0.00, y: h*0.82))
                    p.addLine(to: CGPoint(x: w*1.00, y: h*0.82))
                    p.addLine(to: CGPoint(x: w*0.85, y: h*0.40))
                    p.addLine(to: CGPoint(x: w*0.62, y: h*0.34))
                    p.addLine(to: CGPoint(x: w*0.38, y: h*0.34))
                    p.addLine(to: CGPoint(x: w*0.15, y: h*0.40))
                    p.closeSubpath()
                }.fill(c.bodyGrad)
                // Purple shorts
                Path { p in
                    p.move(to: CGPoint(x: w*0.18, y: h*0.82))
                    p.addLine(to: CGPoint(x: w*0.82, y: h*0.82))
                    p.addLine(to: CGPoint(x: w*0.76, y: h*0.66))
                    p.addLine(to: CGPoint(x: w*0.24, y: h*0.66))
                    p.closeSubpath()
                }.fill(Color(red: 0.36, green: 0.05, blue: 0.55).opacity(0.72))
                // Big round head
                Circle()
                    .fill(c.headGrad)
                    .frame(width: w*0.54, height: w*0.54)
                    .position(x: w/2, y: h*0.24)
                // Angry brow ridge
                Path { p in
                    p.move(to: CGPoint(x: w*0.26, y: h*0.18))
                    p.addLine(to: CGPoint(x: w*0.42, y: h*0.23))
                    p.move(to: CGPoint(x: w*0.74, y: h*0.18))
                    p.addLine(to: CGPoint(x: w*0.58, y: h*0.23))
                }.stroke(c.shade, style: StrokeStyle(lineWidth: 2.8, lineCap: .round))
                // Eyes
                ForEach([CGFloat(-0.12), 0.12], id: \.self) { offset in
                    Circle()
                        .fill(c.shade)
                        .frame(width: w*0.08, height: w*0.08)
                        .position(x: w/2 + offset*w, y: h*0.255)
                }
                // Specular
                Ellipse()
                    .fill(Color.white.opacity(0.35))
                    .frame(width: w*0.14, height: w*0.09)
                    .position(x: w*0.37, y: h*0.155)
            }
        }
    }
}

// MARK: - Doctor Strange (Bishop)
// Dark-red cloak · glowing Eye of Agamotto · v-collar · temple streaks

struct DrStrangePiece: View {
    let c: HeroColors
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack {
                pieceBase(w: w, h: h, c: c)
                // Cloak body
                Path { p in
                    p.move(to: CGPoint(x: w*0.10, y: h*0.82))
                    p.addLine(to: CGPoint(x: w*0.90, y: h*0.82))
                    p.addCurve(to: CGPoint(x: w*0.68, y: h*0.36),
                               control1: CGPoint(x: w*0.88, y: h*0.60),
                               control2: CGPoint(x: w*0.76, y: h*0.44))
                    p.addLine(to: CGPoint(x: w*0.58, y: h*0.32))
                    p.addLine(to: CGPoint(x: w*0.42, y: h*0.32))
                    p.addLine(to: CGPoint(x: w*0.32, y: h*0.36))
                    p.addCurve(to: CGPoint(x: w*0.10, y: h*0.82),
                               control1: CGPoint(x: w*0.24, y: h*0.44),
                               control2: CGPoint(x: w*0.12, y: h*0.60))
                    p.closeSubpath()
                }.fill(c.bodyGrad)
                // Eye of Agamotto
                Circle()
                    .fill(LinearGradient(colors: [c.accent, c.accent.opacity(0.50)],
                                        startPoint: .top, endPoint: .bottom))
                    .shadow(color: c.accent.opacity(0.60), radius: 4)
                    .frame(width: w*0.17, height: w*0.17)
                    .position(x: w/2, y: h*0.57)
                Circle()
                    .strokeBorder(c.highlight.opacity(0.65), lineWidth: 1)
                    .frame(width: w*0.23, height: w*0.23)
                    .position(x: w/2, y: h*0.57)
                // Head
                Circle()
                    .fill(c.headGrad)
                    .frame(width: w*0.40, height: w*0.40)
                    .position(x: w/2, y: h*0.24)
                // V-collar
                Path { p in
                    p.move(to: CGPoint(x: w*0.35, y: h*0.32))
                    p.addLine(to: CGPoint(x: w*0.50, y: h*0.40))
                    p.addLine(to: CGPoint(x: w*0.65, y: h*0.32))
                }.stroke(c.accent, style: StrokeStyle(lineWidth: 2.2, lineCap: .round))
                // Temple grey streaks
                Path { p in
                    p.move(to: CGPoint(x: w*0.33, y: h*0.17))
                    p.addLine(to: CGPoint(x: w*0.38, y: h*0.24))
                    p.move(to: CGPoint(x: w*0.67, y: h*0.17))
                    p.addLine(to: CGPoint(x: w*0.62, y: h*0.24))
                }.stroke(Color.white.opacity(0.55), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                // Specular
                Ellipse()
                    .fill(Color.white.opacity(0.38))
                    .frame(width: w*0.10, height: w*0.07)
                    .position(x: w*0.40, y: h*0.18)
            }
        }
    }
}

// MARK: - Thor (Knight)
// Blue-grey armour · winged helmet · lightning bolt on chest

struct ThorPiece: View {
    let c: HeroColors
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack {
                pieceBase(w: w, h: h, c: c)
                // Body
                RoundedRectangle(cornerRadius: w*0.10)
                    .fill(c.bodyGrad)
                    .frame(width: w*0.64, height: h*0.46)
                    .position(x: w/2, y: h*0.62)
                // Lightning bolt
                LightningBoltShape()
                    .fill(c.accent)
                    .frame(width: w*0.22, height: h*0.20)
                    .position(x: w/2, y: h*0.59)
                // Head
                Circle()
                    .fill(c.headGrad)
                    .frame(width: w*0.42, height: w*0.42)
                    .position(x: w/2, y: h*0.26)
                // Left helmet wing
                Path { p in
                    p.move(to: CGPoint(x: w*0.29, y: h*0.28))
                    p.addCurve(to: CGPoint(x: w*0.08, y: h*0.20),
                               control1: CGPoint(x: w*0.20, y: h*0.26),
                               control2: CGPoint(x: w*0.10, y: h*0.22))
                    p.addLine(to: CGPoint(x: w*0.14, y: h*0.34))
                    p.addLine(to: CGPoint(x: w*0.29, y: h*0.32))
                    p.closeSubpath()
                }.fill(c.highlight.opacity(0.88))
                // Right helmet wing
                Path { p in
                    p.move(to: CGPoint(x: w*0.71, y: h*0.28))
                    p.addCurve(to: CGPoint(x: w*0.92, y: h*0.20),
                               control1: CGPoint(x: w*0.80, y: h*0.26),
                               control2: CGPoint(x: w*0.90, y: h*0.22))
                    p.addLine(to: CGPoint(x: w*0.86, y: h*0.34))
                    p.addLine(to: CGPoint(x: w*0.71, y: h*0.32))
                    p.closeSubpath()
                }.fill(c.highlight.opacity(0.88))
                // Specular
                Ellipse()
                    .fill(Color.white.opacity(0.38))
                    .frame(width: w*0.10, height: w*0.07)
                    .position(x: w*0.40, y: h*0.19)
            }
        }
    }
}

// MARK: - Spider-Man (Pawn)
// Compact red-blue figure · iconic large white oval eyes on spider mask

struct SpiderManPiece: View {
    let c: HeroColors
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack {
                pieceBase(w: w, h: h, c: c)
                // Red torso
                RoundedRectangle(cornerRadius: w*0.08)
                    .fill(c.bodyGrad)
                    .frame(width: w*0.58, height: h*0.40)
                    .position(x: w/2, y: h*0.65)
                // Blue lower body
                RoundedRectangle(cornerRadius: w*0.06)
                    .fill(LinearGradient(colors: [c.accent, c.accent.opacity(0.65)],
                                        startPoint: .top, endPoint: .bottom))
                    .frame(width: w*0.55, height: h*0.18)
                    .position(x: w/2, y: h*0.76)
                // Spider chest ring
                Circle()
                    .strokeBorder(c.shade.opacity(0.80), lineWidth: 1.8)
                    .frame(width: w*0.16, height: w*0.16)
                    .position(x: w/2, y: h*0.56)
                // Red mask head
                Circle()
                    .fill(c.headGrad)
                    .frame(width: w*0.44, height: w*0.44)
                    .position(x: w/2, y: h*0.30)
                // Iconic large white oval eyes
                ForEach([CGFloat(-0.10), 0.10], id: \.self) { offset in
                    Ellipse()
                        .fill(Color.white.opacity(0.94))
                        .frame(width: w*0.14, height: w*0.10)
                        .rotationEffect(.degrees(offset > 0 ? 12 : -12))
                        .position(x: w/2 + offset*w, y: h*0.275)
                    Ellipse()
                        .strokeBorder(c.shade.opacity(0.35), lineWidth: 0.8)
                        .frame(width: w*0.14, height: w*0.10)
                        .rotationEffect(.degrees(offset > 0 ? 12 : -12))
                        .position(x: w/2 + offset*w, y: h*0.275)
                }
                // Specular
                Ellipse()
                    .fill(Color.white.opacity(0.30))
                    .frame(width: w*0.10, height: w*0.07)
                    .position(x: w*0.39, y: h*0.22)
            }
        }
    }
}

// MARK: - Batman (King)
// Dark dramatic cape · bat-cowl with pointed ears · yellow bat signal

struct BatmanPiece: View {
    let c: HeroColors
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack {
                pieceBase(w: w, h: h, c: c)
                // Dark cape body (dramatic full-width)
                Path { p in
                    p.move(to: CGPoint(x: w*0.00, y: h*0.82))
                    p.addLine(to: CGPoint(x: w*1.00, y: h*0.82))
                    p.addLine(to: CGPoint(x: w*0.82, y: h*0.42))
                    p.addLine(to: CGPoint(x: w*0.66, y: h*0.34))
                    p.addLine(to: CGPoint(x: w*0.56, y: h*0.32))
                    p.addLine(to: CGPoint(x: w*0.44, y: h*0.32))
                    p.addLine(to: CGPoint(x: w*0.34, y: h*0.34))
                    p.addLine(to: CGPoint(x: w*0.18, y: h*0.42))
                    p.closeSubpath()
                }.fill(c.bodyGrad)
                // Bat signal on chest
                BatSignalShape()
                    .fill(c.accent)
                    .frame(width: w*0.36, height: h*0.16)
                    .position(x: w/2, y: h*0.57)
                // Bat-cowl head
                Circle()
                    .fill(c.headGrad)
                    .frame(width: w*0.44, height: w*0.44)
                    .position(x: w/2, y: h*0.24)
                // Left pointed ear
                Path { p in
                    p.move(to: CGPoint(x: w*0.31, y: h*0.14))
                    p.addLine(to: CGPoint(x: w*0.25, y: h*0.01))
                    p.addLine(to: CGPoint(x: w*0.39, y: h*0.10))
                    p.closeSubpath()
                }.fill(c.main)
                // Right pointed ear
                Path { p in
                    p.move(to: CGPoint(x: w*0.69, y: h*0.14))
                    p.addLine(to: CGPoint(x: w*0.75, y: h*0.01))
                    p.addLine(to: CGPoint(x: w*0.61, y: h*0.10))
                    p.closeSubpath()
                }.fill(c.main)
                // White eye slits on cowl
                ForEach([CGFloat(-0.09), 0.09], id: \.self) { offset in
                    Capsule()
                        .fill(Color.white.opacity(0.55))
                        .frame(width: w*0.11, height: h*0.028)
                        .position(x: w/2 + offset*w, y: h*0.238)
                }
                // Specular
                Ellipse()
                    .fill(Color.white.opacity(0.22))
                    .frame(width: w*0.10, height: w*0.07)
                    .position(x: w*0.39, y: h*0.17)
            }
        }
    }
}

// MARK: - Wonder Woman (Queen)
// Crimson-gold figure · gold tiara with red gem · eagle-W breastplate

struct WonderWomanPiece: View {
    let c: HeroColors
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack {
                pieceBase(w: w, h: h, c: c)
                // Body
                Path { p in
                    p.move(to: CGPoint(x: w*0.10, y: h*0.82))
                    p.addLine(to: CGPoint(x: w*0.90, y: h*0.82))
                    p.addCurve(to: CGPoint(x: w*0.70, y: h*0.38),
                               control1: CGPoint(x: w*0.90, y: h*0.60),
                               control2: CGPoint(x: w*0.80, y: h*0.46))
                    p.addLine(to: CGPoint(x: w*0.58, y: h*0.32))
                    p.addLine(to: CGPoint(x: w*0.42, y: h*0.32))
                    p.addLine(to: CGPoint(x: w*0.30, y: h*0.38))
                    p.addCurve(to: CGPoint(x: w*0.10, y: h*0.82),
                               control1: CGPoint(x: w*0.20, y: h*0.46),
                               control2: CGPoint(x: w*0.10, y: h*0.60))
                    p.closeSubpath()
                }.fill(c.bodyGrad)
                // Gold eagle-W breastplate
                Path { p in
                    p.move(to: CGPoint(x: w*0.35, y: h*0.52))
                    p.addLine(to: CGPoint(x: w*0.43, y: h*0.45))
                    p.addLine(to: CGPoint(x: w*0.50, y: h*0.51))
                    p.addLine(to: CGPoint(x: w*0.57, y: h*0.45))
                    p.addLine(to: CGPoint(x: w*0.65, y: h*0.52))
                    p.addLine(to: CGPoint(x: w*0.50, y: h*0.62))
                    p.closeSubpath()
                }.fill(c.accent)
                // Head
                Circle()
                    .fill(c.headGrad)
                    .frame(width: w*0.40, height: w*0.40)
                    .position(x: w/2, y: h*0.24)
                // Gold tiara
                Path { p in
                    p.move(to: CGPoint(x: w*0.28, y: h*0.15))
                    p.addLine(to: CGPoint(x: w*0.40, y: h*0.11))
                    p.addLine(to: CGPoint(x: w*0.50, y: h*0.06))
                    p.addLine(to: CGPoint(x: w*0.60, y: h*0.11))
                    p.addLine(to: CGPoint(x: w*0.72, y: h*0.15))
                    p.addLine(to: CGPoint(x: w*0.65, y: h*0.18))
                    p.addLine(to: CGPoint(x: w*0.35, y: h*0.18))
                    p.closeSubpath()
                }.fill(c.accent)
                // Red gem on tiara
                Circle()
                    .fill(Color(red: 0.85, green: 0.12, blue: 0.12))
                    .frame(width: w*0.06, height: w*0.06)
                    .position(x: w/2, y: h*0.09)
                // Specular
                Ellipse()
                    .fill(Color.white.opacity(0.38))
                    .frame(width: w*0.10, height: w*0.07)
                    .position(x: w*0.40, y: h*0.18)
            }
        }
    }
}

// MARK: - Superman (Rook)
// Wide cobalt figure · yellow S-shield on chest · strong build

struct SupermanPiece: View {
    let c: HeroColors
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack {
                pieceBase(w: w, h: h, c: c)
                // Wide powerful body
                Path { p in
                    p.move(to: CGPoint(x: w*0.00, y: h*0.82))
                    p.addLine(to: CGPoint(x: w*1.00, y: h*0.82))
                    p.addLine(to: CGPoint(x: w*0.84, y: h*0.42))
                    p.addLine(to: CGPoint(x: w*0.62, y: h*0.34))
                    p.addLine(to: CGPoint(x: w*0.38, y: h*0.34))
                    p.addLine(to: CGPoint(x: w*0.16, y: h*0.42))
                    p.closeSubpath()
                }.fill(c.bodyGrad)
                // Yellow pentagon S-shield
                Path { p in
                    p.move(to: CGPoint(x: w*0.38, y: h*0.46))
                    p.addLine(to: CGPoint(x: w*0.62, y: h*0.46))
                    p.addLine(to: CGPoint(x: w*0.56, y: h*0.70))
                    p.addLine(to: CGPoint(x: w*0.50, y: h*0.74))
                    p.addLine(to: CGPoint(x: w*0.44, y: h*0.70))
                    p.closeSubpath()
                }.fill(c.accent)
                // Red S on shield
                Text("S")
                    .font(.system(size: w*0.17, weight: .black, design: .rounded))
                    .foregroundColor(c.shade)
                    .position(x: w/2, y: h*0.585)
                // Head
                Circle()
                    .fill(c.headGrad)
                    .frame(width: w*0.44, height: w*0.44)
                    .position(x: w/2, y: h*0.23)
                // Specular
                Ellipse()
                    .fill(Color.white.opacity(0.30))
                    .frame(width: w*0.12, height: w*0.08)
                    .position(x: w*0.38, y: h*0.15)
            }
        }
    }
}

// MARK: - Green Lantern (Bishop)
// Dark slender figure · glowing power ring · green eye mask

struct GreenLanternPiece: View {
    let c: HeroColors
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack {
                pieceBase(w: w, h: h, c: c)
                // Slender dark body
                Path { p in
                    p.move(to: CGPoint(x: w*0.14, y: h*0.82))
                    p.addLine(to: CGPoint(x: w*0.86, y: h*0.82))
                    p.addCurve(to: CGPoint(x: w*0.66, y: h*0.38),
                               control1: CGPoint(x: w*0.84, y: h*0.60),
                               control2: CGPoint(x: w*0.74, y: h*0.46))
                    p.addLine(to: CGPoint(x: w*0.56, y: h*0.32))
                    p.addLine(to: CGPoint(x: w*0.44, y: h*0.32))
                    p.addLine(to: CGPoint(x: w*0.34, y: h*0.38))
                    p.addCurve(to: CGPoint(x: w*0.14, y: h*0.82),
                               control1: CGPoint(x: w*0.26, y: h*0.46),
                               control2: CGPoint(x: w*0.16, y: h*0.60))
                    p.closeSubpath()
                }.fill(c.bodyGrad)
                // Glowing power ring aura
                Circle()
                    .strokeBorder(c.accent, lineWidth: 2.5)
                    .shadow(color: c.accent, radius: 4)
                    .frame(width: w*0.26, height: w*0.26)
                    .position(x: w/2, y: h*0.57)
                // Lantern shape inside ring
                RoundedRectangle(cornerRadius: 2)
                    .fill(c.accent.opacity(0.80))
                    .frame(width: w*0.07, height: h*0.07)
                    .position(x: w/2, y: h*0.57)
                // Head
                Circle()
                    .fill(c.headGrad)
                    .frame(width: w*0.40, height: w*0.40)
                    .position(x: w/2, y: h*0.24)
                // Green eye mask
                RoundedRectangle(cornerRadius: 3)
                    .fill(c.accent.opacity(0.88))
                    .frame(width: w*0.36, height: h*0.046)
                    .position(x: w/2, y: h*0.240)
                // Specular
                Ellipse()
                    .fill(c.accent.opacity(0.28))
                    .frame(width: w*0.10, height: w*0.07)
                    .position(x: w*0.40, y: h*0.18)
            }
        }
    }
}

// MARK: - The Flash (Knight)
// Scarlet figure · red cowl · gold lightning bolt ear-wings · white eye slits

struct FlashPiece: View {
    let c: HeroColors
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack {
                pieceBase(w: w, h: h, c: c)
                // Body
                RoundedRectangle(cornerRadius: w*0.10)
                    .fill(c.bodyGrad)
                    .frame(width: w*0.62, height: h*0.46)
                    .position(x: w/2, y: h*0.62)
                // Lightning bolt on chest
                LightningBoltShape()
                    .fill(c.accent)
                    .frame(width: w*0.22, height: h*0.22)
                    .position(x: w/2, y: h*0.59)
                // Red cowl
                Circle()
                    .fill(c.headGrad)
                    .frame(width: w*0.42, height: w*0.42)
                    .position(x: w/2, y: h*0.26)
                // Left lightning bolt ear-wing
                Path { p in
                    p.move(to: CGPoint(x: w*0.27, y: h*0.20))
                    p.addLine(to: CGPoint(x: w*0.17, y: h*0.12))
                    p.addLine(to: CGPoint(x: w*0.22, y: h*0.20))
                    p.addLine(to: CGPoint(x: w*0.12, y: h*0.27))
                    p.addLine(to: CGPoint(x: w*0.22, y: h*0.27))
                    p.closeSubpath()
                }.fill(c.accent)
                // Right lightning bolt ear-wing
                Path { p in
                    p.move(to: CGPoint(x: w*0.73, y: h*0.20))
                    p.addLine(to: CGPoint(x: w*0.83, y: h*0.12))
                    p.addLine(to: CGPoint(x: w*0.78, y: h*0.20))
                    p.addLine(to: CGPoint(x: w*0.88, y: h*0.27))
                    p.addLine(to: CGPoint(x: w*0.78, y: h*0.27))
                    p.closeSubpath()
                }.fill(c.accent)
                // White eye slits
                ForEach([CGFloat(-0.09), 0.09], id: \.self) { offset in
                    Capsule()
                        .fill(Color.white.opacity(0.92))
                        .frame(width: w*0.11, height: h*0.028)
                        .position(x: w/2 + offset*w, y: h*0.248)
                }
                // Specular
                Ellipse()
                    .fill(Color.white.opacity(0.32))
                    .frame(width: w*0.10, height: w*0.07)
                    .position(x: w*0.39, y: h*0.19)
            }
        }
    }
}

// MARK: - Aquaman (Pawn)
// Compact teal figure · orange scale armour · gold hair arc · trident symbol

struct AquamanPiece: View {
    let c: HeroColors
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack {
                pieceBase(w: w, h: h, c: c)
                // Teal body
                RoundedRectangle(cornerRadius: w*0.08)
                    .fill(c.bodyGrad)
                    .frame(width: w*0.56, height: h*0.40)
                    .position(x: w/2, y: h*0.65)
                // Orange scale chest
                RoundedRectangle(cornerRadius: w*0.06)
                    .fill(LinearGradient(colors: [c.accent, c.accent.opacity(0.65)],
                                        startPoint: .top, endPoint: .bottom))
                    .frame(width: w*0.42, height: h*0.22)
                    .position(x: w/2, y: h*0.60)
                // Trident symbol
                Path { p in
                    p.move(to: CGPoint(x: w*0.50, y: h*0.53))
                    p.addLine(to: CGPoint(x: w*0.50, y: h*0.70))
                    p.move(to: CGPoint(x: w*0.40, y: h*0.57))
                    p.addLine(to: CGPoint(x: w*0.60, y: h*0.57))
                    p.move(to: CGPoint(x: w*0.42, y: h*0.57))
                    p.addLine(to: CGPoint(x: w*0.42, y: h*0.48))
                    p.move(to: CGPoint(x: w*0.50, y: h*0.53))
                    p.addLine(to: CGPoint(x: w*0.50, y: h*0.44))
                    p.move(to: CGPoint(x: w*0.58, y: h*0.57))
                    p.addLine(to: CGPoint(x: w*0.58, y: h*0.48))
                }.stroke(c.shade, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                // Head
                Circle()
                    .fill(c.headGrad)
                    .frame(width: w*0.40, height: w*0.40)
                    .position(x: w/2, y: h*0.30)
                // Gold hair arc
                Path { p in
                    p.move(to: CGPoint(x: w*0.34, y: h*0.15))
                    p.addCurve(to: CGPoint(x: w*0.66, y: h*0.15),
                               control1: CGPoint(x: w*0.40, y: h*0.08),
                               control2: CGPoint(x: w*0.60, y: h*0.08))
                }.stroke(c.accent, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                // Specular
                Ellipse()
                    .fill(Color.white.opacity(0.38))
                    .frame(width: w*0.10, height: w*0.07)
                    .position(x: w*0.40, y: h*0.23)
            }
        }
    }
}
