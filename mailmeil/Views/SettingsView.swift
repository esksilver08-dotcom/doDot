import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: GoalsViewModel
    @State private var reminderTime: Date

    init() {
        var components = DateComponents()
        components.hour = NotificationManager.shared.reminderHour
        components.minute = NotificationManager.shared.reminderMinute
        _reminderTime = State(initialValue: Calendar.current.date(from: components) ?? Date())
    }

    var body: some View {
        Form {
            Section {
                DatePicker("알림 시간", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    .onChange(of: reminderTime) { _, newValue in
                        let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                        NotificationManager.shared.reminderHour = components.hour ?? 21
                        NotificationManager.shared.reminderMinute = components.minute ?? 0
                        viewModel.updateDailyReminder()
                    }
            } header: {
                Text("루틴 점검 알림")
            } footer: {
                Text("설정한 시간에 오늘 아직 안 한 루틴이 있으면 알림을 보내드려요. 다 끝냈다면 알림이 오지 않아요.")
            }
        }
        .navigationTitle("설정")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(GoalsViewModel())
    }
}
