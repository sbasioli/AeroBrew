import Foundation
import SwiftData

@Model
final class Step {
    var id: String
    var order: Int
    var title: String
    var stepDescription: String
    var imageURL: String?
    var hasTimer: Bool
    var timerDuration: Int?

    var recipe: Recipe?

    init(
        id: String = UUID().uuidString,
        order: Int,
        title: String,
        stepDescription: String,
        imageURL: String? = nil,
        hasTimer: Bool = false,
        timerDuration: Int? = nil
    ) {
        self.id = id
        self.order = order
        self.title = title
        self.stepDescription = stepDescription
        self.imageURL = imageURL
        self.hasTimer = hasTimer
        self.timerDuration = timerDuration
    }
}
