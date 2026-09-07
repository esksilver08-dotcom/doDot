import Foundation

/// One timestamp per todo/routine completion, kept only for stats
/// (total/weekly counts, streaks) — not involved in the XP math itself.
struct CompletionLogEntry: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var date: Date = Date()
}
