import SwiftUI

struct ControlsView: View {
    @ObservedObject var game: GameManager
    @State private var showNewGameSheet = false
    @State private var showResignAlert = false

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Button(action: { showNewGameSheet = true }) {
                    Label("New Game", systemImage: "plus.circle.fill")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(ChessTheme.accent)
                        .cornerRadius(10)
                }

                Button(action: { game.undoLastMove() }) {
                    Label("Undo", systemImage: "arrow.uturn.backward.circle.fill")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(ChessTheme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(ChessTheme.cardBackground)
                        .cornerRadius(10)
                }
                .disabled(game.moveHistory.isEmpty || game.isThinking)
                .opacity(game.moveHistory.isEmpty ? 0.5 : 1)
            }

            if !game.gameState.isGameOver {
                Button(action: { showResignAlert = true }) {
                    Label("Resign", systemImage: "flag.fill")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.red.opacity(0.9))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(ChessTheme.cardBackground)
                        .cornerRadius(10)
                }
                .disabled(game.isThinking)

                Toggle("Coach Mode", isOn: $game.isCoachModeEnabled)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(ChessTheme.textPrimary)
                    .tint(ChessTheme.accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(ChessTheme.cardBackground)
                    .cornerRadius(10)
            }
        }
        .sheet(isPresented: $showNewGameSheet) {
            NewGameSheet(game: game, isPresented: $showNewGameSheet)
        }
        .alert("Resign?", isPresented: $showResignAlert) {
            Button("Resign", role: .destructive) { game.resign() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to resign?")
        }
    }
}

struct NewGameSheet: View {
    @ObservedObject var game: GameManager
    @Binding var isPresented: Bool
    @State private var selectedMode: GameMode = .humanVsAI
    @State private var selectedDifficulty: AIDifficulty = .intermediate
    @State private var selectedColor: PieceColor = .white

    var body: some View {
        NavigationView {
            Form {
                Section("Game Mode") {
                    Picker("Mode", selection: $selectedMode) {
                        ForEach(GameMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                if selectedMode == .humanVsAI {
                    Section("Difficulty") {
                        Picker("Difficulty", selection: $selectedDifficulty) {
                            ForEach(AIDifficulty.allCases, id: \.self) { d in
                                Text(d.rawValue).tag(d)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    Section("Play As") {
                        Picker("Color", selection: $selectedColor) {
                            Text("♔ White").tag(PieceColor.white)
                            Text("♚ Black").tag(PieceColor.black)
                        }
                        .pickerStyle(.segmented)
                    }
                }
            }
            .navigationTitle("New Game")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Start") {
                        game.newGame()
                        game.gameMode = selectedMode
                        game.aiDifficulty = selectedDifficulty
                        game.aiColor = selectedColor.opposite
                        if selectedMode == .humanVsAI && selectedColor == .black {
                            game.triggerAI()
                        }
                        isPresented = false
                    }
                    .fontWeight(.bold)
                }
            }
        }
        .onAppear {
            selectedMode = game.gameMode
            selectedDifficulty = game.aiDifficulty
            selectedColor = game.aiColor.opposite
        }
        #if os(macOS)
        .frame(minWidth: 350, minHeight: 300)
        #endif
    }
}
