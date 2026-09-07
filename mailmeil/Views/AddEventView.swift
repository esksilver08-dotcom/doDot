import SwiftUI

struct AddEventView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var date = Date()

    var body: some View {
        NavigationStack {
            Form {
                TextField("일정 이름", text: $title)
                DatePicker("날짜/시간", selection: $date)
            }
            .navigationTitle("일정 추가")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("추가") {
                        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        viewModel.addEvent(title: trimmed, date: date)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddEventView()
        .environmentObject(AppViewModel())
}
