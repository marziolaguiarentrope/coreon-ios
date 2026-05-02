import Foundation

struct GroupClass: Codable, Identifiable {
    let id: String
    var title: String?
    var description: String?
    var instructorEmail: String?
    var scheduledDate: Date?
    var durationMinutes: Int?
    var maxStudents: Int?
    var enrolledCount: Int?
    var location: String?
    var modality: String?
    var status: String?
    var groupId: String?
    var recurrence: String?
    var notes: String?
    var createdDate: Date?
}

struct TrainingGroup: Codable, Identifiable {
    let id: String
    var name: String?
    var description: String?
    var instructorEmail: String?
    var memberEmails: [String]?
    var modality: String?
    var createdDate: Date?
}

struct ClassCheckin: Codable, Identifiable {
    let id: String
    var classId: String?
    var clientEmail: String?
    var checkedInAt: Date?
    var status: String?
    var notes: String?
}
