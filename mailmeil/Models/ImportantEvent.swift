import Foundation

/// A dated event shown alongside today's todos (e.g. an exam, an appointment).
struct ImportantEvent: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var title: String
    var date: Date
}
