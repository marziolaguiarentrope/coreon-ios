import Foundation

struct Payment: Codable, Identifiable {
    let id: String
    var clientEmail: String?
    var professionalEmail: String?
    var amount: Double?
    var currency: String?
    var status: String? // pending, paid, overdue, cancelled
    var method: String? // pix, card, cash, transfer
    var category: String? // monthly, weekly, per_session, package
    var dueDate: String?
    var paidDate: Date?
    var notes: String?
    var createdDate: Date?
}

struct ClientPricing: Codable, Identifiable {
    let id: String
    var clientEmail: String?
    var professionalEmail: String?
    var amount: Double?
    var currency: String?
    var billingType: String?
    var startDate: String?
    var endDate: String?
    var active: Bool?
    var notes: String?
}
