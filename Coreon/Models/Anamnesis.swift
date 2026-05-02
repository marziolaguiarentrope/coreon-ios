import Foundation

struct AnamnesisTemplate: Codable, Identifiable {
    let id: String
    var name: String?
    var description: String?
    var domain: String?
    var subtype: String?
    var sections: [AnamnesisSection]?
    var createdBy: String?
    var createdDate: Date?
}

struct AnamnesisSection: Codable, Identifiable {
    let id: String
    var title: String?
    var questions: [AnamnesisQuestion]?
    var order: Int?
}

struct AnamnesisQuestion: Codable, Identifiable {
    let id: String
    var questionText: String?
    var type: String? // text, textarea, number, select, multiselect, checkbox, radio, date
    var options: [String]?
    var required: Bool?
    var order: Int?
}

struct AnamnesisAssignment: Codable, Identifiable {
    let id: String
    var templateId: String?
    var clientEmail: String?
    var assignedBy: String?
    var assignedDate: Date?
    var dueDate: String?
    var domain: String?
    var status: String?
    var message: String?
}

struct ClientAnamnesisResponse: Codable, Identifiable {
    let id: String
    var templateId: String?
    var clientEmail: String?
    var domain: String?
    var answers: [String: AnyCodable]?
    var status: String?
    var submissionDate: Date?
    var professionalNotes: String?
    var reviewedBy: String?
    var reviewedDate: Date?
}

// Helper for Any-typed JSON values
struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) { self.value = value }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let v = try? container.decode(Bool.self) { value = v }
        else if let v = try? container.decode(Int.self) { value = v }
        else if let v = try? container.decode(Double.self) { value = v }
        else if let v = try? container.decode(String.self) { value = v }
        else if let v = try? container.decode([String].self) { value = v }
        else { value = "" }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let v as Bool: try container.encode(v)
        case let v as Int: try container.encode(v)
        case let v as Double: try container.encode(v)
        case let v as String: try container.encode(v)
        case let v as [String]: try container.encode(v)
        default: try container.encodeNil()
        }
    }

    var stringValue: String {
        switch value {
        case let v as String: return v
        case let v as [String]: return v.joined(separator: ", ")
        case let v as Bool: return v ? "Sim" : "Não"
        case let v as Int: return "\(v)"
        case let v as Double: return "\(v)"
        default: return ""
        }
    }
}
