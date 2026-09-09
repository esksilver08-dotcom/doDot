import SwiftUI

struct TodayView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var showAddTodoSheet = false
    @State private var showAddEventSheet = false

    var body: some View {
        NavigationStack {
            List {
                if !viewModel.upcomingEvents.isEmpty {
                    Section("중요 일정") {
                        ForEach(viewModel.upcomingEvents) { event in
                            HStack {
                                Text(event.title)
                                Spacer()
                                Text(event.date, format: .dateTime.month().day().hour().minute())
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .onDelete { offsets in
                            let events = viewModel.upcomingEvents
                            for index in offsets {
                                viewModel.deleteEvent(events[index].id)
                            }
                        }
                    }
                }

                ForEach(TimeOfDay.allCases) { time in
                    Section(time.rawValue) {
                        let items = viewModel.todos(for: time)
                        if items.isEmpty {
                            Text("할 일이 없어요")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        ForEach(items) { todo in
                            todoRow(todo)
                        }
                        .onDelete { offsets in
                            for index in offsets {
                                viewModel.deleteTodo(items[index].id)
                            }
                        }
                    }
                }
            }
            .navigationTitle("오늘")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showAddTodoSheet = true
                        } label: {
                            Label("할 일 추가", systemImage: "checklist")
                        }
                        Button {
                            showAddEventSheet = true
                        } label: {
                            Label("일정 추가", systemImage: "calendar")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddTodoSheet) {
                AddTodoView()
                    .presentationDetents([.medium])
            }
            .sheet(isPresented: $showAddEventSheet) {
                AddEventView()
                    .presentationDetents([.medium])
            }
        }
    }

    private func todoRow(_ todo: TodoItem) -> some View {
        Button {
            withAnimation {
                viewModel.toggleTodo(todo.id)
            }
        } label: {
            HStack {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(todo.isCompleted ? .green : .secondary)
                Text(todo.content)
                    .strikethrough(todo.isCompleted)
                    .foregroundColor(todo.isCompleted ? .secondary : .primary)
                Spacer()
                Text("+\(todo.difficulty.xp) XP")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TodayView()
        .environmentObject(AppViewModel())
}
