import SwiftUI

// MARK: - Progress View

struct UserProgressView: View {
    @ObservedObject private var store = ProgressStore.shared
    private let lessons = ContentLoader.shared.lessons
    private let puzzles = ContentLoader.shared.puzzles

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Stats overview
                    statsGrid

                    // Streak & XP card
                    streakCard

                    // Lessons progress
                    lessonsCard

                    // Puzzles breakdown
                    puzzlesCard
                }
                .padding()
            }
            .navigationTitle("Progress")
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: Stats grid

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(value: "\(store.stats.xp)", label: "XP Earned", icon: "star.fill", color: .yellow)
            StatCard(value: "\(store.stats.streak)d", label: "Current Streak", icon: "flame.fill", color: .orange)
            StatCard(value: "\(store.stats.totalLessonsCompleted)", label: "Lessons Done", icon: "book.fill", color: .blue)
            StatCard(value: "\(store.stats.totalPuzzlesSolved)", label: "Puzzles Solved", icon: "checkmark.seal.fill", color: .green)
        }
    }

    // MARK: Streak card

    private var streakCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Activity", systemImage: "calendar")
                .font(.headline)
            HStack(spacing: 4) {
                ForEach(0..<7, id: \.self) { day in
                    let isActive = isActiveDay(offset: day - 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isActive ? Color.accentColor : Color.secondary.opacity(0.2))
                        .frame(height: 28)
                }
            }
            HStack {
                Spacer()
                Text("Last 7 days")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: Lessons card

    private var lessonsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Lessons", systemImage: "book.fill")
                .font(.headline)

            if lessons.isEmpty {
                Text("No lessons available.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(lessons) { lesson in
                    let completion = store.lessonCompletion(for: lesson.id)
                    let total = lesson.sections.count
                    let done = completion?.sectionsCompleted ?? 0
                    let fraction = total > 0 ? Double(done) / Double(total) : 0

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(lesson.title)
                                .font(.subheadline)
                            Spacer()
                            Text("\(done)/\(total)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        SwiftUI.ProgressView(value: fraction)
                            .tint(fraction >= 1 ? .green : .accentColor)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: Puzzles card

    private var puzzlesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Puzzles", systemImage: "puzzlepiece.fill")
                .font(.headline)

            let attempted = puzzles.filter { store.puzzleAttempt(for: $0.id) != nil }
            let solved = puzzles.filter { store.puzzleAttempt(for: $0.id)?.solvedCorrectly == true }

            if attempted.isEmpty {
                Text("No puzzles attempted yet.")
                    .foregroundStyle(.secondary)
            } else {
                HStack(spacing: 16) {
                    VStack {
                        Text("\(attempted.count)")
                            .font(.title2.bold())
                        Text("Attempted")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Divider()
                    VStack {
                        Text("\(solved.count)")
                            .font(.title2.bold())
                            .foregroundStyle(.green)
                        Text("Solved")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Divider()
                    VStack {
                        let pct = attempted.isEmpty ? 0 : Int(Double(solved.count) / Double(attempted.count) * 100)
                        Text("\(pct)%")
                            .font(.title2.bold())
                            .foregroundStyle(.blue)
                        Text("Accuracy")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
            }

            // Per-puzzle breakdown
            ForEach(puzzles) { puzzle in
                if let attempt = store.puzzleAttempt(for: puzzle.id) {
                    HStack {
                        Image(systemName: attempt.solvedCorrectly ? "checkmark.circle.fill" : "xmark.circle")
                            .foregroundStyle(attempt.solvedCorrectly ? .green : .orange)
                        Text(puzzle.title)
                            .font(.subheadline)
                        Spacer()
                        Text("\(attempt.attempts) \(attempt.attempts == 1 ? "try" : "tries")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: Helpers

    private func isActiveDay(offset: Int) -> Bool {
        guard let last = store.stats.lastActiveDate else { return false }
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let targetDay = cal.date(byAdding: .day, value: offset, to: today)!
        // For simplicity, just show today as active
        return offset == 0 && cal.startOfDay(for: last) == today
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    UserProgressView()
}
