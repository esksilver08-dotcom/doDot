import Foundation

enum Difficulty: String, Codable, CaseIterable, Identifiable {
    case easy = "쉬움"
    case medium = "보통"
    case hard = "어려움"

    var id: String { rawValue }

    var xp: Int {
        switch self {
        case .easy: return 10
        case .medium: return 30
        case .hard: return 50
        }
    }
}

enum TimeOfDay: String, Codable, CaseIterable, Identifiable {
    case morning = "아침"
    case afternoon = "점심"
    case evening = "저녁"

    var id: String { rawValue }
}

/// A one-off todo for a specific day (as opposed to `Routine`, which repeats).
struct TodoItem: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var content: String
    var timeOfDay: TimeOfDay
    var difficulty: Difficulty
    var isCompleted: Bool = false
    var date: Date = Date()
}
