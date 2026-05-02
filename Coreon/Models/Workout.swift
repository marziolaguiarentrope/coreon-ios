import Foundation

struct Workout: Codable, Identifiable {
    let id: String
    var workoutName: String?
    var clientEmail: String?
    var programId: String?
    var modality: String?
    var status: String?
    var workoutDate: Date?
    var notes: String?
    var exercises: [WorkoutExerciseEntry]?
    var swimBlocks: [SwimBlock]?
    var createdDate: Date?
    var createdBy: String?
}

struct WorkoutProgram: Codable, Identifiable {
    let id: String
    var programName: String?
    var clientEmail: String?
    var programType: String?
    var status: String?
    var startDate: String?
    var endDate: String?
    var notes: String?
    var createdBy: String?
    var createdDate: Date?
}

struct Exercise: Codable, Identifiable {
    let id: String
    var name: String
    var category: String?
    var muscleGroup: String?
    var equipment: String?
    var description: String?
    var videoUrl: String?
    var imageUrl: String?
    var difficulty: String?
    var instructions: [String]?
    var createdBy: String?
}

struct WorkoutExerciseEntry: Codable, Identifiable {
    let id: String
    var exerciseId: String?
    var exerciseName: String?
    var sets: Int?
    var reps: String?
    var weight: String?
    var restSeconds: Int?
    var rpe: Int?
    var notes: String?
    var order: Int?
    var setDetails: [SetDetail]?
}

struct SetDetail: Codable, Identifiable {
    let id: String
    var setNumber: Int?
    var reps: Int?
    var weight: Double?
    var restSeconds: Int?
    var completed: Bool?
}

struct SwimBlock: Codable, Identifiable {
    let id: String
    var blockType: String?
    var sets: [SwimSet]?
    var notes: String?
    var order: Int?
}

struct SwimSet: Codable, Identifiable {
    let id: String
    var distance: Int?
    var style: String?
    var intensity: String?
    var restSeconds: Int?
    var repetitions: Int?
    var notes: String?
}

struct WorkoutSession: Codable, Identifiable {
    let id: String
    var workoutId: String?
    var clientEmail: String?
    var completedAt: Date?
    var durationMinutes: Int?
    var notes: String?
    var exerciseLog: [[String: String]]?
    var rating: Int?
    var mood: String?
}
