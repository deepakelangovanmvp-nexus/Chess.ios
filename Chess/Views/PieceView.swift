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

    private var imageName: String {
        if piece.color == .white {
            switch piece.type {
            case .king:   return "IronManKing"
            case .queen:  return "CaptainMarvelQueen"
            case .rook:   return "HulkRook"
            case .bishop: return "DoctorStrangeBishop"
            case .knight: return "ThorKnight"
            case .pawn:   return "SpiderManPawn"
            }
        } else {
            switch piece.type {
            case .king:   return "BatmanKing"
            case .queen:  return "WonderWomanQueen"
            case .rook:   return "SupermanRook"
            case .bishop: return "GreenLanternBishop"
            case .knight: return "FlashKnight"
            case .pawn:   return "AquamanPawn"
            }
        }
    }

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
    }
}
