import SwiftUI
import SwiftData

@main
struct AeroPressGuideApp: App {
    let container: ModelContainer

    @State private var recipeStore: RecipeStore
    @State private var sessionStore: BrewSessionStore

    init() {
        do {
            container = try ModelContainer(for: Recipe.self, Step.self, BrewSession.self)
        } catch {
            fatalError("SwiftData container error: \(error)")
        }

        let context = container.mainContext
        _recipeStore = State(initialValue: RecipeStore(modelContext: context))
        _sessionStore = State(initialValue: BrewSessionStore(modelContext: context))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(container)
                .environment(recipeStore)
                .environment(sessionStore)
                .onAppear { seedIfNeeded() }
                .preferredColorScheme(.light)
        }
    }

    private func seedIfNeeded() {
        guard recipeStore.allRecipes.isEmpty else { return }
        let context = container.mainContext
        for recipe in SeedData.allRecipes() {
            context.insert(recipe)
        }
        try? context.save()
        recipeStore.fetchRecipes()
    }
}
