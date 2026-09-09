import SwiftUI

struct AddTodoView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var content = ""
    @State private var timeOfDay: TimeOfDay = .morning
    @State private var difficulty: Difficulty = .easy

    var body: some View {
        NavigationStack {
            Form {
                TextField("할 일", text: $content)

                Picker("시간대", selection: $timeOfDay) {
                    ForEach(TimeOfDay.allCases) { time in
                        Text(time.rawValue).tag(time)
                    }
                }
                .pickerStyle(.segmented)

                Picker("난이도", selection: $difficulty) {
                    ForEach(Difficulty.allCases) { level in
                        Text("\(level.rawValue) (+\(level.xp))").tag(level)
                    }
                }
                .pickerStyle(.segmented)
            }
            .navigationTitle("할 일 추가")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("추가") {
                        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        viewModel.addTodo(content: trimmed, timeOfDay: timeOfDay, difficulty: difficulty)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddTodoView()
        .environmentObject(AppViewModel())
}
