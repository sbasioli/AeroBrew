import Foundation
import SwiftData
import Observation

@Observable
final class RecipeStore {
    private var modelContext: ModelContext

    private(set) var allRecipes: [Recipe] = []

    var favoriteRecipes: [Recipe] {
        allRecipes.filter { $0.isFavorite }
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchRecipes()
    }

    func fetchRecipes() {
        let descriptor = FetchDescriptor<Recipe>(
            sortBy: [SortDescriptor(\.createdAt)]
        )
        allRecipes = (try? modelContext.fetch(descriptor)) ?? []
    }

    func toggleFavorite(_ recipe: Recipe) {
        recipe.isFavorite.toggle()
        try? modelContext.save()
    }

    func isFavorite(_ recipe: Recipe) -> Bool {
        recipe.isFavorite
    }

    func addCustomRecipe(_ recipe: Recipe) {
        modelContext.insert(recipe)
        try? modelContext.save()
        fetchRecipes()
    }

    func deleteRecipe(_ recipe: Recipe) {
        modelContext.delete(recipe)
        try? modelContext.save()
        fetchRecipes()
    }
}
