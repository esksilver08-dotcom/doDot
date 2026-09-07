import SwiftUI

struct AddRoutineView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var content = ""
    @State private var difficulty: Difficulty = .easy
    @State private var repeatDays: Set<Int> = [0, 1, 2, 3, 4, 5, 6]

    private let dayLabels = ["월", "화", "수", "목", "금", "토", "일"]

    var body: some View {
        NavigationStack {
            Form {
                TextField("루틴 이름", text: $content)

                Picker("난이도", selection: $difficulty) {
                    ForEach(Difficulty.allCases) { level in
                        Text("\(level.rawValue) (+\(level.xp))").tag(level)
                    }
                }
                .pickerStyle(.segmented)

                Section("반복 요일") {
                    HStack(spacing: 6) {
                        ForEach(0..<7, id: \.self) { day in
                            dayToggle(day)
                        }
                    }
                }
            }
            .navigationTitle("루틴 추가")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("추가") {
                        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty, !repeatDays.isEmpty else { return }
                        viewModel.addRoutine(content: trimmed, difficulty: difficulty, repeatDays: Array(repeatDays).sorted())
                        dismiss()
                    }
                }
            }
        }
    }

    private func dayToggle(_ day: Int) -> some View {
        let isSelected = repeatDays.contains(day)
        return Button {
            if isSelected {
                repeatDays.remove(day)
            } else {
                repeatDays.insert(day)
            }
        } label: {
            Text(dayLabels[day])
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AddRoutineView()
        .environmentObject(AppViewModel())
}
