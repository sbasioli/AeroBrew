import SwiftUI
import SwiftData

@main
struct AeroPressGuideApp: App {
    let container: ModelContainer

    @State private var recipeStore: RecipeStore
    @State private var sessionStore: BrewSessionStore

    init() {
        let schema = Schema([Recipe.self, Step.self, BrewSession.self, UserProfile.self])
        let configuration = ModelConfiguration(
            schema: schema,
            cloudKitDatabase: .private("iCloud.com.yourname.aeropressguide")
        )

        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            // CloudKit container may not be provisioned yet (e.g. in simulator without iCloud sign-in
            // or before the developer portal config is in place). Fall back to a local-only store
            // so the app stays usable.
            do {
                let localConfig = ModelConfiguration(schema: schema, cloudKitDatabase: .none)
                container = try ModelContainer(for: schema, configurations: [localConfig])
            } catch {
                fatalError("SwiftData container error: \(error)")
            }
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
        let context = container.mainContext
        let existingIDs = Set(recipeStore.allRecipes.map { $0.id })

        var didInsert = false
        for recipe in SeedData.allRecipes() where !existingIDs.contains(recipe.id) {
            context.insert(recipe)
            didInsert = true
        }

        if didInsert {
            try? context.save()
            recipeStore.fetchRecipes()
        }
    }
}
