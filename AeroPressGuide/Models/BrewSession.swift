import Foundation
import SwiftData

@Model
final class BrewSession {
    var id: String = UUID().uuidString
    var recipeID: String = ""
    var recipeName: String = ""
    var completedAt: Date = Date()
    var rating: Int?
    var notes: String?
    var coffeeAmount: Double?
    var waterAmount: Double?

    init(
        id: String = UUID().uuidString,
        recipeID: String,
        recipeName: String,
        completedAt: Date = .now,
        rating: Int? = nil,
        notes: String? = nil,
        coffeeAmount: Double? = nil,
        waterAmount: Double? = nil
    ) {
        self.id = id
        self.recipeID = recipeID
        self.recipeName = recipeName
        self.completedAt = completedAt
        self.rating = rating
        self.notes = notes
        self.coffeeAmount = coffeeAmount
        self.waterAmount = waterAmount
    }
}
