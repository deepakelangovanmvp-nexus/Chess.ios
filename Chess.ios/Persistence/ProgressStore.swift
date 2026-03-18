import Foundation

// MARK: - Progress Models (Codable, stored locally)

public struct LessonCompletion: Codable, Identifiable, Sendable {
    public let id: String         // lesson id
    public var completedAt: Date
    public var sectionsCompleted: Int
    public var totalSections: Int

    public var isComplete: Bool { sectionsCompleted >= totalSections }
}

public struct PuzzleAttempt: Codable, Identifiable, Sendable {
    public let id: String         // puzzle id
    public var attempts: Int
    public var solvedCorrectly: Bool
    public var lastAttemptAt: Date
}

public struct UserStats: Codable, Sendable {
    public var xp: Int
    public var streak: Int
    public var lastActiveDate: Date?
    public var totalPuzzlesSolved: Int
    public var totalPuzzlesAttempted: Int
    public var totalLessonsCompleted: Int

    public static let empty = UserStats(
        xp: 0, streak: 0, lastActiveDate: nil,
        totalPuzzlesSolved: 0, totalPuzzlesAttempted: 0, totalLessonsCompleted: 0
    )
}

// MARK: - Progress Store

@MainActor
public class ProgressStore: ObservableObject {
    public static let shared = ProgressStore()

    @Published public private(set) var lessonCompletions: [String: LessonCompletion] = [:]
    @Published public private(set) var puzzleAttempts: [String: PuzzleAttempt] = [:]
    @Published public private(set) var stats: UserStats = .empty

    private let lessonsKey = "lessonCompletions"
    private let puzzlesKey  = "puzzleAttempts"
    private let statsKey    = "userStats"

    private init() {
        load()
        updateStreak()
    }

    // MARK: Lesson progress

    public func markLesson(_ lessonId: String, sectionIndex: Int, totalSections: Int) {
        var completion = lessonCompletions[lessonId] ?? LessonCompletion(
            id: lessonId, completedAt: Date(),
            sectionsCompleted: 0, totalSections: totalSections
        )
        completion.sectionsCompleted = max(completion.sectionsCompleted, sectionIndex + 1)
        completion.totalSections = totalSections
        if completion.isComplete { completion.completedAt = Date() }
        lessonCompletions[lessonId] = completion

        if completion.isComplete {
            stats.totalLessonsCompleted = lessonCompletions.values.filter(\.isComplete).count
            stats.xp += 50
        }
        save()
    }

    public func lessonCompletion(for lessonId: String) -> LessonCompletion? {
        lessonCompletions[lessonId]
    }

    // MARK: Puzzle progress

    public func recordPuzzle(_ puzzleId: String, solved: Bool) {
        var attempt = puzzleAttempts[puzzleId] ?? PuzzleAttempt(
            id: puzzleId, attempts: 0, solvedCorrectly: false, lastAttemptAt: Date()
        )
        attempt.attempts += 1
        attempt.lastAttemptAt = Date()
        if solved { attempt.solvedCorrectly = true }
        puzzleAttempts[puzzleId] = attempt

        stats.totalPuzzlesAttempted = puzzleAttempts.count
        stats.totalPuzzlesSolved    = puzzleAttempts.values.filter(\.solvedCorrectly).count
        if solved { stats.xp += 20 }
        save()
    }

    public func puzzleAttempt(for puzzleId: String) -> PuzzleAttempt? {
        puzzleAttempts[puzzleId]
    }

    // MARK: Streak

    private func updateStreak() {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())

        if let last = stats.lastActiveDate {
            let lastDay = cal.startOfDay(for: last)
            if lastDay == today { return }
            if let yesterday = cal.date(byAdding: .day, value: -1, to: today), lastDay == yesterday {
                stats.streak += 1
            } else {
                stats.streak = 1
            }
        } else {
            stats.streak = 1
        }
        stats.lastActiveDate = Date()
        save()
    }

    public func recordActivity() {
        updateStreak()
    }

    // MARK: Persistence

    private func load() {
        if let data = UserDefaults.standard.data(forKey: lessonsKey),
           let decoded = try? JSONDecoder().decode([String: LessonCompletion].self, from: data) {
            lessonCompletions = decoded
        }
        if let data = UserDefaults.standard.data(forKey: puzzlesKey),
           let decoded = try? JSONDecoder().decode([String: PuzzleAttempt].self, from: data) {
            puzzleAttempts = decoded
        }
        if let data = UserDefaults.standard.data(forKey: statsKey),
           let decoded = try? JSONDecoder().decode(UserStats.self, from: data) {
            stats = decoded
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(lessonCompletions) {
            UserDefaults.standard.set(data, forKey: lessonsKey)
        }
        if let data = try? JSONEncoder().encode(puzzleAttempts) {
            UserDefaults.standard.set(data, forKey: puzzlesKey)
        }
        if let data = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(data, forKey: statsKey)
        }
    }
}
