import Foundation

struct Message: Codable, Identifiable {
    let id: String
    var fromEmail: String?
    var toEmail: String?
    var content: String?
    var read: Bool?
    var createdDate: Date?
    var attachmentUrl: String?
}

struct Conversation: Identifiable {
    let id: String
    var otherUserEmail: String
    var otherUserName: String?
    var otherUserAvatar: String?
    var lastMessage: String?
    var lastMessageDate: Date?
    var unreadCount: Int
    var messages: [Message]
}

struct DailyCheckin: Codable, Identifiable {
    let id: String
    var clientEmail: String?
    var checkinDate: Date?
    var energyLevel: Int?
    var muscleSoreness: Int?
    var sleepQuality: Int?
    var stressLevel: Int?
    var mood: Int?
    var notes: String?
    var weight: Double?
    var createdDate: Date?
}

struct Appointment: Codable, Identifiable {
    let id: String
    var clientEmail: String?
    var professionalEmail: String?
    var title: String?
    var scheduledDate: Date?
    var durationMinutes: Int?
    var type: String?
    var status: String?
    var notes: String?
    var location: String?
}
