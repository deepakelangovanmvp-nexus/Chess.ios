import SwiftUI

struct PieceView: View {
    let piece: Piece
    var size: CGFloat = 40

    var body: some View {
        HeroIconView(piece: piece)
            .frame(width: size, height: size)
            .shadow(color: piece.color == .white ? .cyan.opacity(0.3) : .red.opacity(0.3), radius: 4, x: 0, y: 2)
            .shadow(color: .black.opacity(0.4), radius: 2, x: 1, y: 2)
    }
}

struct HeroIconView: View {
    let piece: Piece
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            
            ZStack {
                if piece.color == .white {
                    switch piece.type {
                    case .king: IronManTarget()
                    case .queen: CosmicStar(color: .yellow)
                    case .rook: GammaSymbol(color: .green)
                    case .bishop: EyeOfAgamotto()
                    case .knight: Mjolnir()
                    case .pawn: SpiderWeb()
                    }
                } else {
                    switch piece.type {
                    case .king: BatSymbol()
                    case .queen: WonderWomanLogo()
                    case .rook: SupermanShield()
                    case .bishop: LanternRing()
                    case .knight: FlashBolt()
                    case .pawn: Trident()
                    }
                }
            }
            .frame(width: w, height: w)
        }
    }
}

// MARK: - Marvel (White)
struct IronManTarget: View {
    var body: some View {
        ZStack {
            Circle().fill(Color.cyan)
            Circle().stroke(Color.white, lineWidth: 6)
            Circle().stroke(Color.cyan, lineWidth: 2).padding(4)
            Circle().stroke(Color.white.opacity(0.8), lineWidth: 4).padding(10)
        }
    }
}

struct CosmicStar: View {
    let color: Color
    var body: some View {
        ZStack {
            Circle().fill(Color.red)
            Image(systemName: "star.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(color)
                .padding(8)
            Circle().stroke(Color.blue, lineWidth: 4)
        }
    }
}

struct GammaSymbol: View {
    let color: Color
    var body: some View {
        ZStack {
            Circle().fill(color)
            Text("Γ")
                .font(.system(size: 80, weight: .heavy, design: .rounded))
                .foregroundColor(.black)
                .minimumScaleFactor(0.1)
                .padding(6)
            Circle().stroke(Color.black, lineWidth: 4)
        }
    }
}

struct EyeOfAgamotto: View {
    var body: some View {
        ZStack {
            Ellipse().fill(Color.orange)
            Ellipse().stroke(Color.yellow, lineWidth: 4)
            Circle().fill(Color.green).frame(width: 20)
                .shadow(color: .green, radius: 4)
        }
        .padding(4)
    }
}

struct Mjolnir: View {
    var body: some View {
        ZStack {
            Rectangle().fill(Color.brown).frame(width: 8, height: 30).offset(y: 10)
            RoundedRectangle(cornerRadius: 4).fill(Color.gray).frame(width: 30, height: 16).offset(y: -8)
            Path { p in
                p.move(to: CGPoint(x: 10, y: 10))
                p.addLine(to: CGPoint(x: 5, y: 0))
                p.addLine(to: CGPoint(x: 15, y: -5))
            }.stroke(Color.yellow, lineWidth: 2)
        }
        .padding(8)
    }
}

struct SpiderWeb: View {
    var body: some View {
        ZStack {
            Circle().fill(Color.red)
            Image(systemName: "network")
                .resizable()
                .foregroundColor(.black)
                .padding(4)
            Circle().stroke(Color.black, lineWidth: 3)
        }
    }
}

// MARK: - DC (Black)
struct BatSymbol: View {
    var body: some View {
        ZStack {
            Ellipse().fill(Color.yellow)
            Path { p in
                let w: CGFloat = 100
                let h: CGFloat = 60
                p.move(to: CGPoint(x: w*0.5, y: h*0.2))
                p.addLine(to: CGPoint(x: w*0.4, y: h*0.2))
                p.addLine(to: CGPoint(x: w*0.45, y: h*0.3)) 
                p.addLine(to: CGPoint(x: w*0.1, y: h*0.2))
                p.addLine(to: CGPoint(x: w*0.2, y: h*0.8))
                p.addLine(to: CGPoint(x: w*0.35, y: h*0.6)) 
                p.addLine(to: CGPoint(x: w*0.5, y: h*0.9))
                p.addLine(to: CGPoint(x: w*0.65, y: h*0.6)) 
                p.addLine(to: CGPoint(x: w*0.8, y: h*0.8))
                p.addLine(to: CGPoint(x: w*0.9, y: h*0.2))
                p.addLine(to: CGPoint(x: w*0.55, y: h*0.3)) 
                p.addLine(to: CGPoint(x: w*0.6, y: h*0.2))
                p.closeSubpath()
            }
            .fill(Color.black)
            .scaleEffect(0.6)
            Ellipse().stroke(Color.black, lineWidth: 3)
        }
        .padding(2)
    }
}

struct WonderWomanLogo: View {
    var body: some View {
        ZStack {
            Circle().fill(Color.black)
            VStack(spacing: -12) {
                Text("W")
                Text("W")
            }
            .font(.system(size: 26, weight: .heavy, design: .serif))
            .foregroundColor(.yellow)
            Circle().stroke(Color.yellow, lineWidth: 3)
        }
    }
}

struct SupermanShield: View {
    var body: some View {
        ZStack {
            Path { p in
                p.move(to: CGPoint(x: 50, y: 10))
                p.addLine(to: CGPoint(x: 90, y: 30))
                p.addLine(to: CGPoint(x: 50, y: 90))
                p.addLine(to: CGPoint(x: 10, y: 30))
                p.closeSubpath()
            }
            .fill(Color.yellow)
            .overlay(
                Path { p in
                    p.move(to: CGPoint(x: 50, y: 10))
                    p.addLine(to: CGPoint(x: 90, y: 30))
                    p.addLine(to: CGPoint(x: 50, y: 90))
                    p.addLine(to: CGPoint(x: 10, y: 30))
                    p.closeSubpath()
                }.stroke(Color.red, lineWidth: 6)
            )
            Text("S")
                .font(.system(size: 40, weight: .black, design: .rounded))
                .foregroundColor(.red)
        }
        .scaleEffect(0.4)
    }
}

struct LanternRing: View {
    var body: some View {
        ZStack {
            Circle().fill(Color.black)
            Circle().stroke(Color.green, lineWidth: 4).padding(8)
            Rectangle().fill(Color.green).frame(width: 30, height: 4).offset(y: -14)
            Rectangle().fill(Color.green).frame(width: 30, height: 4).offset(y: 14)
            Circle().stroke(Color.black, lineWidth: 3)
            Circle().stroke(Color.green, lineWidth: 2)
        }
    }
}

struct FlashBolt: View {
    var body: some View {
        ZStack {
            Circle().fill(Color.red)
            Circle().fill(Color.white).padding(6)
            Image(systemName: "bolt.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.yellow)
                .padding(10)
            Circle().stroke(Color.yellow, lineWidth: 3)
        }
    }
}

struct Trident: View {
    var body: some View {
        ZStack {
            Circle().fill(Color.black)
            Rectangle().fill(Color.yellow).frame(width: 4, height: 30).offset(y: 5)
            Rectangle().fill(Color.yellow).frame(width: 24, height: 4).offset(y: -8)
            Rectangle().fill(Color.yellow).frame(width: 4, height: 16).offset(x: -10, y: -16)
            Rectangle().fill(Color.yellow).frame(width: 4, height: 20).offset(y: -18)
            Rectangle().fill(Color.yellow).frame(width: 4, height: 16).offset(x: 10, y: -16)
            Circle().stroke(Color.yellow, lineWidth: 3)
        }
    }
}
