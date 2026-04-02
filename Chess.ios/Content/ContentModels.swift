import Foundation

// MARK: - Lesson Models

public struct LessonSection: Codable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let body: String          // Markdown-like plain text
    public let boardFEN: String?     // Optional board to display
    public let checkpoint: Checkpoint?

    public struct Checkpoint: Codable, Sendable {
        public let fen: String
        public let sideToMove: String       // "w" or "b"
        public let correctMoves: [String]   // UCI strings
        public let explanation: String
    }
}

public struct Lesson: Codable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let description: String
    public let category: String
    public let difficulty: String    // "Beginner", "Intermediate", "Advanced"
    public let estimatedMinutes: Int
    public let sections: [LessonSection]
}

// MARK: - Puzzle Models

public struct Puzzle: Codable, Identifiable, Sendable {
    public let id: String
    public let fen: String
    public let sideToMove: String    // "w" or "b"
    public let solution: [String]    // UCI move list
    public let theme: String
    public let difficulty: String    // "Easy", "Medium", "Hard"
    public let title: String
    public let explanation: String
}

// MARK: - Content Loader

public class ContentLoader {
    public static let shared = ContentLoader()
    private init() {}

    private var _lessons: [Lesson]?
    private var _puzzles: [Puzzle]?

    public var lessons: [Lesson] {
        if let cached = _lessons { return cached }
        let loaded = load([Lesson].self, from: "Lessons") ?? []
        _lessons = loaded
        return loaded
    }

    public var puzzles: [Puzzle] {
        if let cached = _puzzles { return cached }
        let loaded = load([Puzzle].self, from: "Puzzles") ?? []
        _puzzles = loaded
        return loaded
    }

    private func load<T: Decodable>(_ type: T.Type, from resource: String) -> T? {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "json") else {
            return nil
        }
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
