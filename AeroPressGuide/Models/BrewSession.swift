import Foundation
import SwiftData

@Model
final class BrewSession {
    var id: String
    var recipeID: String
    var recipeName: String
    var completedAt: Date
    var rating: Int?
    var notes: String?

    init(
        id: String = UUID().uuidString,
        recipeID: String,
        recipeName: String,
        completedAt: Date = .now,
        rating: Int? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.recipeID = recipeID
        self.recipeName = recipeName
        self.completedAt = completedAt
        self.rating = rating
        self.notes = notes
    }
}
