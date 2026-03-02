import Foundation
import SwiftData

enum BrewMethod: String, Codable, CaseIterable {
    case standard = "standard"
    case inverted = "inverted"

    var displayName: String {
        switch self {
        case .standard: return "Standard"
        case .inverted: return "Inverted"
        }
    }
}

enum Difficulty: String, Codable, CaseIterable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"

    var localizedName: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        }
    }

    var color: String {
        switch self {
        case .beginner: return "DifficultyGreen"
        case .intermediate: return "DifficultyOrange"
        case .advanced: return "DifficultyRed"
        }
    }
}

@Model
final class Recipe {
    var id: String
    var name: String
    var author: String
    var method: BrewMethod
    var coffeeAmount: Double
    var waterAmount: Double
    var waterTemperature: Int
    var ratio: String
    var totalTime: Int
    var difficulty: Difficulty
    var isCustom: Bool
    var isFavorite: Bool = false
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Step.recipe)
    var steps: [Step] = []

    init(
        id: String = UUID().uuidString,
        name: String,
        author: String,
        method: BrewMethod = .standard,
        coffeeAmount: Double,
        waterAmount: Double,
        waterTemperature: Int,
        ratio: String,
        totalTime: Int,
        difficulty: Difficulty = .beginner,
        isCustom: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.author = author
        self.method = method
        self.coffeeAmount = coffeeAmount
        self.waterAmount = waterAmount
        self.waterTemperature = waterTemperature
        self.ratio = ratio
        self.totalTime = totalTime
        self.difficulty = difficulty
        self.isCustom = isCustom
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var sortedSteps: [Step] {
        steps.sorted { $0.order < $1.order }
    }
}
