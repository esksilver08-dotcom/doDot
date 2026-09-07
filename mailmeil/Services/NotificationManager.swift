import Foundation
import UserNotifications

/// Schedules the evening "you still have routines left today" reminder.
/// Local-only (no push server) — rescheduled from scratch whenever the
/// goals/todos change, so it always reflects the current incomplete count.
final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    private let reminderIdentifier = "daily-routine-check"
    private let reminderHour = 21
    private let reminderMinute = 0

    func requestAuthorizationIfNeeded() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .notDetermined else { return }
            center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        }
    }

    /// Replaces any pending reminder with one reflecting `incompleteCount`.
    /// Fires at `reminderHour`:`reminderMinute` — today if that time hasn't
    /// passed yet, otherwise tomorrow (UNCalendarNotificationTrigger's
    /// next-matching-time behavior).
    func scheduleDailyReminder(incompleteCount: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])

        guard incompleteCount > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = "오늘의 루틴 점검"
        content.body = "아직 안 한 루틴이 \(incompleteCount)개 있어요. 지금 확인해보세요!"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = reminderHour
        dateComponents.minute = reminderMinute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: reminderIdentifier, content: content, trigger: trigger)
        center.add(request)
    }
}
