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
    var id: String = UUID().uuidString
    var name: String = ""
    var author: String = ""
    var method: BrewMethod = BrewMethod.standard
    var coffeeAmount: Double = 0
    var waterAmount: Double = 0
    var waterTemperature: Int = 0
    var ratio: String = ""
    var totalTime: Int = 0
    var difficulty: Difficulty = Difficulty.beginner
    var isCustom: Bool = false
    var isFavorite: Bool = false
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    var sourceYear: Int?
    var sourceCountry: String?
    var sourceBadge: String?

    @Relationship(deleteRule: .cascade, inverse: \Step.recipe)
    var steps: [Step]? = []

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
        updatedAt: Date = .now,
        sourceYear: Int? = nil,
        sourceCountry: String? = nil,
        sourceBadge: String? = nil
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
        self.sourceYear = sourceYear
        self.sourceCountry = sourceCountry
        self.sourceBadge = sourceBadge
    }

    var sortedSteps: [Step] {
        (steps ?? []).sorted { $0.order < $1.order }
    }
}
