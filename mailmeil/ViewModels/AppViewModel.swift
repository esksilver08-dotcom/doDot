import Foundation
import SwiftUI

/// Fired transiently when `addXP` crosses a level boundary, so a view can
/// show a one-off celebration. Not persisted.
struct LevelUpEvent: Identifiable, Equatable {
    let id = UUID()
    let newLevel: Int
}

final class AppViewModel: ObservableObject {
    @Published var character = PlayerCharacter()
    @Published var todos: [TodoItem] = []
    @Published var events: [ImportantEvent] = []
    @Published var routines: [Routine] = []
    @Published var completionLog: [CompletionLogEntry] = []
    @Published var levelUpEvent: LevelUpEvent?

    private var saveURL: URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return directory.appendingPathComponent("appstate.json")
    }

    init() {
        NotificationManager.shared.requestAuthorizationIfNeeded()
        loadFromDisk()
    }

    // MARK: - Todos

    var todaysTodos: [TodoItem] {
        todos.filter { Calendar.current.isDateInToday($0.date) }
    }

    func todos(for time: TimeOfDay) -> [TodoItem] {
        todaysTodos.filter { $0.timeOfDay == time }
    }

    func addTodo(content: String, timeOfDay: TimeOfDay, difficulty: Difficulty) {
        todos.append(TodoItem(content: content, timeOfDay: timeOfDay, difficulty: difficulty))
        save()
    }

    func toggleTodo(_ id: UUID) {
        guard let index = todos.firstIndex(where: { $0.id == id }) else { return }
        todos[index].isCompleted.toggle()
        if todos[index].isCompleted {
            let levelsGained = character.addXP(todos[index].difficulty.xp)
            if levelsGained > 0 {
                levelUpEvent = LevelUpEvent(newLevel: character.level)
            }
            logCompletion()
        } else {
            character.removeXP(todos[index].difficulty.xp)
            undoTodaysCompletionLog()
        }
        save()
    }

    func deleteTodo(_ id: UUID) {
        todos.removeAll { $0.id == id }
        save()
    }

    // MARK: - Important events

    var upcomingEvents: [ImportantEvent] {
        events
            .filter { Calendar.current.isDateInToday($0.date) || $0.date > Date() }
            .sorted { $0.date < $1.date }
    }

    func addEvent(title: String, date: Date) {
        events.append(ImportantEvent(title: title, date: date))
        save()
    }

    func deleteEvent(_ id: UUID) {
        events.removeAll { $0.id == id }
        save()
    }

    // MARK: - Routines

    /// 0=Monday...6=Sunday.
    func todayWeekdayIndex() -> Int {
        (Calendar.current.component(.weekday, from: Date()) + 5) % 7
    }

    func todaysRoutines() -> [Routine] {
        let today = todayWeekdayIndex()
        return routines.filter { $0.repeatDays.contains(today) }
    }

    func isCompletedToday(_ routine: Routine) -> Bool {
        guard let last = routine.lastCompletedDate else { return false }
        return Calendar.current.isDateInToday(last)
    }

    func addRoutine(content: String, difficulty: Difficulty, repeatDays: [Int]) {
        routines.append(Routine(content: content, difficulty: difficulty, repeatDays: repeatDays))
        save()
    }

    func toggleRoutineToday(_ id: UUID) {
        guard let index = routines.firstIndex(where: { $0.id == id }) else { return }
        if isCompletedToday(routines[index]) {
            routines[index].lastCompletedDate = nil
            character.removeXP(routines[index].difficulty.xp)
            undoTodaysCompletionLog()
        } else {
            routines[index].lastCompletedDate = Date()
            let levelsGained = character.addXP(routines[index].difficulty.xp)
            if levelsGained > 0 {
                levelUpEvent = LevelUpEvent(newLevel: character.level)
            }
            logCompletion()
        }
        save()
    }

    func deleteRoutine(_ id: UUID) {
        routines.removeAll { $0.id == id }
        save()
    }

    // MARK: - Completion log & stats

    private func logCompletion() {
        completionLog.append(CompletionLogEntry())
    }

    /// Best-effort undo for an un-check: removes the most recent entry from
    /// today, since completions aren't individually tagged by source item.
    private func undoTodaysCompletionLog() {
        if let index = completionLog.lastIndex(where: { Calendar.current.isDateInToday($0.date) }) {
            completionLog.remove(at: index)
        }
    }

    var totalXPEarned: Int { character.totalXPEarned }

    var thisWeekCompletions: Int {
        let calendar = Calendar.current
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start else { return 0 }
        return completionLog.filter { $0.date >= weekStart }.count
    }

    /// Consecutive days up to and including today with at least one completion.
    var currentStreakDays: Int {
        let calendar = Calendar.current
        let completedDays = Set(completionLog.map { calendar.startOfDay(for: $0.date) })
        var streak = 0
        var cursor = calendar.startOfDay(for: Date())
        while completedDays.contains(cursor) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previousDay
        }
        return streak
    }

    // MARK: - Reminder

    func updateDailyReminder() {
        let incompleteTodos = todaysTodos.filter { !$0.isCompleted }.count
        let incompleteRoutines = todaysRoutines().filter { !isCompletedToday($0) }.count
        NotificationManager.shared.scheduleDailyReminder(incompleteCount: incompleteTodos + incompleteRoutines)
    }

    // MARK: - Persistence

    private struct AppData: Codable {
        var character: PlayerCharacter
        var todos: [TodoItem]
        var events: [ImportantEvent]
        var routines: [Routine]
        var completionLog: [CompletionLogEntry]

        init(character: PlayerCharacter, todos: [TodoItem], events: [ImportantEvent], routines: [Routine], completionLog: [CompletionLogEntry]) {
            self.character = character
            self.todos = todos
            self.events = events
            self.routines = routines
            self.completionLog = completionLog
        }

        // Explicit so old saved data (from before completionLog existed)
        // still decodes instead of failing on the missing key — a synthesized
        // Decodable would require the key even with a default property value.
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            character = try container.decode(PlayerCharacter.self, forKey: .character)
            todos = try container.decode([TodoItem].self, forKey: .todos)
            events = try container.decode([ImportantEvent].self, forKey: .events)
            routines = try container.decode([Routine].self, forKey: .routines)
            completionLog = try container.decodeIfPresent([CompletionLogEntry].self, forKey: .completionLog) ?? []
        }
    }

    private func save() {
        let data = AppData(character: character, todos: todos, events: events, routines: routines, completionLog: completionLog)
        do {
            let encoded = try JSONEncoder().encode(data)
            try encoded.write(to: saveURL)
        } catch {
            print("❌ Failed to save app data:", error)
        }
        updateDailyReminder()
    }

    private func loadFromDisk() {
        do {
            let raw = try Data(contentsOf: saveURL)
            let data = try JSONDecoder().decode(AppData.self, from: raw)
            character = data.character
            todos = data.todos
            events = data.events
            routines = data.routines
            completionLog = data.completionLog
        } catch {
            print("ℹ️ No saved app data yet:", error)
        }
    }
}
