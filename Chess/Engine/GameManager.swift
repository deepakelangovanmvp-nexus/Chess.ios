import Foundation
import SwiftUI

@MainActor
class GameManager: ObservableObject {
    @Published var board = Board()
    @Published var currentTurn: PieceColor = .white
    @Published var gameState: GameState = .playing
    @Published var selectedPosition: Position?
    @Published var validMoves: [Move] = []
    @Published var moveHistory: [MoveRecord] = []
    @Published var lastMove: Move?
    @Published var capturedByWhite: [Piece] = []
    @Published var capturedByBlack: [Piece] = []
    @Published var isThinking = false
    @Published var showingPromotion = false
    @Published var gameMode: GameMode = .humanVsAI
    @Published var aiDifficulty: AIDifficulty = .intermediate
    @Published var moveNotations: [String] = []
    
    @Published var isCoachModeEnabled = false {
        didSet { if isCoachModeEnabled { triggerCoachAIIfNeeded() } }
    }
    @Published var suggestedMove: Move?
    @Published var activeAnimation: ActiveAnimation?

    var pendingPromotionMove: Move?
    var castlingRights = CastlingRights()
    var enPassantTarget: Position?
    var halfMoveClock = 0
    var aiColor: PieceColor = .black
    private let ai = ChessAI()

    func handleTap(at position: Position) {
        guard !gameState.isGameOver && !isThinking && !showingPromotion else { return }
        if gameMode == .humanVsAI && currentTurn == aiColor { return }

        if selectedPosition != nil {
            if let move = validMoves.first(where: { $0.to == position }) {
                if move.moveType == .promotion {
                    pendingPromotionMove = move
                    showingPromotion = true
                    selectedPosition = nil
                    validMoves = []
                    return
                }
                executeMove(move)
            } else if let piece = board.piece(at: position), piece.color == currentTurn {
                selectPiece(at: position)
            } else {
                selectedPosition = nil
                validMoves = []
            }
        } else {
            if let piece = board.piece(at: position), piece.color == currentTurn {
                selectPiece(at: position)
            }
        }
    }

    func selectPiece(at position: Position) {
        selectedPosition = position
        validMoves = MoveValidator.legalMoves(for: position, board: board,
                                              enPassantTarget: enPassantTarget,
                                              castlingRights: castlingRights)
    }

    func completePromotion(with pieceType: PieceType) {
        guard var move = pendingPromotionMove else { return }
        move.promotionType = pieceType
        showingPromotion = false
        pendingPromotionMove = nil
        executeMove(move)
    }

    func executeMove(_ move: Move) {
        let record = MoveRecord(move: move, castlingRights: castlingRights,
                                enPassantTarget: enPassantTarget, halfMoveClock: halfMoveClock)
        moveHistory.append(record)

        if let captured = move.capturedPiece {
            if move.piece.color == .white { capturedByWhite.append(captured) }
            else { capturedByBlack.append(captured) }
        }

        activeAnimation = ActiveAnimation(position: move.to, piece: move.piece)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.activeAnimation = nil
        }
        suggestedMove = nil

        MoveValidator.applyMove(move, to: &board)
        updateCastlingRights(after: move)

        if move.moveType == .doublePawnPush {
            let epRow = move.piece.color == .white ? move.from.row + 1 : move.from.row - 1
            enPassantTarget = Position(row: epRow, col: move.from.col)
        } else {
            enPassantTarget = nil
        }

        if move.piece.type == .pawn || move.isCapture { halfMoveClock = 0 }
        else { halfMoveClock += 1 }

        var notation = move.algebraicNotation
        lastMove = move
        selectedPosition = nil
        validMoves = []
        currentTurn = currentTurn.opposite

        updateGameState()

        if case .check = gameState { notation += "+" }
        if case .checkmate = gameState { notation += "#" }
        moveNotations.append(notation)

        if !gameState.isGameOver {
            if gameMode == .humanVsAI && currentTurn == aiColor {
                triggerAI()
            } else {
                triggerCoachAIIfNeeded()
            }
        }
    }

    func updateCastlingRights(after move: Move) {
        if move.piece.type == .king {
            if move.piece.color == .white {
                castlingRights.whiteKingside = false
                castlingRights.whiteQueenside = false
            } else {
                castlingRights.blackKingside = false
                castlingRights.blackQueenside = false
            }
        }
        if move.piece.type == .rook {
            if move.from == Position(row: 0, col: 0) { castlingRights.whiteQueenside = false }
            if move.from == Position(row: 0, col: 7) { castlingRights.whiteKingside = false }
            if move.from == Position(row: 7, col: 0) { castlingRights.blackQueenside = false }
            if move.from == Position(row: 7, col: 7) { castlingRights.blackKingside = false }
        }
        if move.to == Position(row: 0, col: 0) { castlingRights.whiteQueenside = false }
        if move.to == Position(row: 0, col: 7) { castlingRights.whiteKingside = false }
        if move.to == Position(row: 7, col: 0) { castlingRights.blackQueenside = false }
        if move.to == Position(row: 7, col: 7) { castlingRights.blackKingside = false }
    }

    func updateGameState() {
        if MoveValidator.isCheckmate(color: currentTurn, board: board,
                                     enPassantTarget: enPassantTarget, castlingRights: castlingRights) {
            gameState = .checkmate(winner: currentTurn.opposite)
        } else if MoveValidator.isStalemate(color: currentTurn, board: board,
                                            enPassantTarget: enPassantTarget, castlingRights: castlingRights) {
            gameState = .stalemate
        } else if MoveValidator.isInsufficientMaterial(board: board) {
            gameState = .stalemate
        } else if halfMoveClock >= 100 {
            gameState = .stalemate
        } else if MoveValidator.isInCheck(color: currentTurn, board: board) {
            gameState = .check(currentTurn)
        } else {
            gameState = .playing
        }
    }

    func triggerAI() {
        isThinking = true
        let boardCopy = board.copy()
        let color = aiColor
        let depth = aiDifficulty.searchDepth
        let ep = enPassantTarget
        let cr = castlingRights

        Task { [weak self] in
            let result = await Task.detached(priority: .userInitiated) {
                let ai = ChessAI()
                return ai.bestMove(board: boardCopy, color: color, depth: depth,
                                   enPassantTarget: ep, castlingRights: cr)
            }.value
            guard let self = self else { return }
            self.isThinking = false
            if let move = result {
                self.executeMove(move)
            }
        }
    }

    func triggerCoachAIIfNeeded() {
        guard isCoachModeEnabled, !gameState.isGameOver, !isThinking else { return }
        if gameMode == .humanVsAI && currentTurn == aiColor { return }
        
        let boardCopy = board.copy()
        let color = currentTurn
        let ep = enPassantTarget
        let cr = castlingRights
        
        Task { [weak self] in
            let result = await Task.detached(priority: .background) {
                let ai = ChessAI()
                return ai.bestMove(board: boardCopy, color: color, depth: 3,
                                   enPassantTarget: ep, castlingRights: cr)
            }.value
            guard let self = self else { return }
            if self.currentTurn == color {
                self.suggestedMove = result
            }
        }
    }

    func undoLastMove() {
        guard let record = moveHistory.popLast() else { return }
        let move = record.move
        board.setPiece(move.piece, at: move.from)

        if move.moveType == .promotion {
            board.setPiece(nil, at: move.to)
        } else {
            board.setPiece(nil, at: move.to)
        }

        if let captured = move.capturedPiece {
            if move.moveType == .enPassant {
                let capturedRow = move.piece.color == .white ? move.to.row - 1 : move.to.row + 1
                board.setPiece(captured, at: Position(row: capturedRow, col: move.to.col))
            } else {
                board.setPiece(captured, at: move.to)
            }
            if move.piece.color == .white { capturedByWhite.removeLast() }
            else { capturedByBlack.removeLast() }
        }

        if move.moveType == .castleKingside {
            let row = move.from.row
            let rook = board.piece(at: Position(row: row, col: 5))
            board.setPiece(nil, at: Position(row: row, col: 5))
            board.setPiece(rook, at: Position(row: row, col: 7))
        }
        if move.moveType == .castleQueenside {
            let row = move.from.row
            let rook = board.piece(at: Position(row: row, col: 3))
            board.setPiece(nil, at: Position(row: row, col: 3))
            board.setPiece(rook, at: Position(row: row, col: 0))
        }

        castlingRights = record.castlingRights
        enPassantTarget = record.enPassantTarget
        halfMoveClock = record.halfMoveClock
        currentTurn = currentTurn.opposite
        moveNotations.removeLast()
        lastMove = moveHistory.last?.move
        selectedPosition = nil
        validMoves = []
        updateGameState()
    }

    func newGame() {
        board = Board()
        currentTurn = .white
        gameState = .playing
        selectedPosition = nil
        validMoves = []
        moveHistory = []
        lastMove = nil
        capturedByWhite = []
        capturedByBlack = []
        isThinking = false
        showingPromotion = false
        pendingPromotionMove = nil
        castlingRights = CastlingRights()
        enPassantTarget = nil
        halfMoveClock = 0
        moveNotations = []
        isCoachModeEnabled = false
        suggestedMove = nil
        activeAnimation = nil
    }

    func resign() {
        gameState = .resigned(currentTurn)
    }

    func isKingInCheck(at position: Position) -> Bool {
        guard let piece = board.piece(at: position), piece.type == .king else { return false }
        if case .check(let color) = gameState, color == piece.color { return true }
        return false
    }

    var statusText: String {
        switch gameState {
        case .playing:
            return "\(currentTurn.displayName)'s Turn"
        case .check(let color):
            return "\(color.displayName) is in Check!"
        case .checkmate(let winner):
            return "Checkmate! \(winner.displayName) Wins!"
        case .stalemate:
            return "Draw — Stalemate"
        case .resigned(let color):
            return "\(color.displayName) Resigned. \(color.opposite.displayName) Wins!"
        }
    }
}
