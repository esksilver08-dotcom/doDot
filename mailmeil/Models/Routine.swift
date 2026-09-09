import Foundation

/// A recurring task. `repeatDays` uses 0=Monday...6=Sunday (matching
/// `AppViewModel.todayWeekdayIndex()`). Completion for "today" is derived
/// from `lastCompletedDate` rather than stored as a separate flag, so there's
/// no daily-reset step to get wrong — it just naturally reads as
/// not-completed once the date rolls over.
struct Routine: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var content: String
    var difficulty: Difficulty
    var repeatDays: [Int]
    var lastCompletedDate: Date?
}
