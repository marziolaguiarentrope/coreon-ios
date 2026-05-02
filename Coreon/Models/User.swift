import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    var fullName: String?
    var role: String?
    var avatarUrl: String?
    var bio: String?
    var phone: String?
    var specialties: [String]?
    var createdDate: Date?
}

struct Client: Codable, Identifiable {
    let id: String
    var email: String
    var fullName: String?
    var phone: String?
    var birthDate: String?
    var gender: String?
    var goal: String?
    var healthNotes: String?
    var notes: String?
    var assignedTrainer: String?
    var assignedNutri: String?
    var status: String?
    var avatarUrl: String?
    var createdDate: Date?
}
