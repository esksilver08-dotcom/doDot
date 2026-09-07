import Foundation
import SwiftUI

final class AppViewModel: ObservableObject {
    @Published var character = PlayerCharacter()
    @Published var todos: [TodoItem] = []
    @Published var events: [ImportantEvent] = []
    @Published var routines: [Routine] = []

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
            character.addXP(todos[index].difficulty.xp)
        } else {
            character.removeXP(todos[index].difficulty.xp)
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
        } else {
            routines[index].lastCompletedDate = Date()
            character.addXP(routines[index].difficulty.xp)
        }
        save()
    }

    func deleteRoutine(_ id: UUID) {
        routines.removeAll { $0.id == id }
        save()
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
    }

    private func save() {
        let data = AppData(character: character, todos: todos, events: events, routines: routines)
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
        } catch {
            print("ℹ️ No saved app data yet:", error)
        }
    }
}
