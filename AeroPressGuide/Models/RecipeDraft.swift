import Foundation

struct StepDraft: Identifiable, Equatable {
    var id: UUID = UUID()
    var title: String = ""
    var detail: String = ""
    var hasTimer: Bool = false
    var timerDuration: Int = 30
}

struct RecipeDraft: Equatable {
    var name: String = ""
    var author: String = "Custom"
    var method: BrewMethod = .standard
    var coffeeAmount: Double = 18
    var waterAmount: Double = 200
    var waterTemperature: Int = 92
    var difficulty: Difficulty = .beginner
    var steps: [StepDraft] = [StepDraft()]

    var ratio: String {
        guard coffeeAmount > 0 else { return "1:0" }
        return "1:\(Int(round(waterAmount / coffeeAmount)))"
    }

    var totalTime: Int {
        steps.reduce(0) { partial, step in
            if step.hasTimer {
                return partial + step.timerDuration
            } else {
                return partial + 10
            }
        }
    }

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && !steps.isEmpty
            && steps.allSatisfy { !$0.title.trimmingCharacters(in: .whitespaces).isEmpty }
    }
}

extension RecipeDraft {
    static func from(_ recipe: Recipe, copyForCustom: Bool = false) -> RecipeDraft {
        var draft = RecipeDraft()
        draft.name = copyForCustom ? "\(recipe.name) — My Take" : recipe.name
        draft.author = recipe.author
        draft.method = recipe.method
        draft.coffeeAmount = recipe.coffeeAmount
        draft.waterAmount = recipe.waterAmount
        draft.waterTemperature = recipe.waterTemperature
        draft.difficulty = recipe.difficulty
        draft.steps = recipe.sortedSteps.map { step in
            StepDraft(
                title: step.title,
                detail: step.stepDescription,
                hasTimer: step.hasTimer,
                timerDuration: step.timerDuration ?? 30
            )
        }
        if draft.steps.isEmpty {
            draft.steps = [StepDraft()]
        }
        return draft
    }

    func makeRecipe(isCustom: Bool, defaultImageURL: String?) -> Recipe {
        let resolvedAuthor: String
        if isCustom {
            resolvedAuthor = "Custom"
        } else {
            let trimmed = author.trimmingCharacters(in: .whitespaces)
            resolvedAuthor = trimmed.isEmpty ? "Me" : trimmed
        }

        let recipe = Recipe(
            name: name.trimmingCharacters(in: .whitespaces),
            author: resolvedAuthor,
            method: method,
            coffeeAmount: coffeeAmount,
            waterAmount: waterAmount,
            waterTemperature: waterTemperature,
            ratio: ratio,
            totalTime: totalTime,
            difficulty: difficulty,
            isCustom: isCustom
        )
        recipe.steps = steps.enumerated().map { index, draft in
            Step(
                order: index + 1,
                title: draft.title.trimmingCharacters(in: .whitespaces),
                stepDescription: draft.detail.trimmingCharacters(in: .whitespaces),
                imageURL: defaultImageURL,
                hasTimer: draft.hasTimer,
                timerDuration: draft.hasTimer ? draft.timerDuration : nil
            )
        }
        return recipe
    }
}
