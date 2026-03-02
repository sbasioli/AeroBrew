import SwiftUI

enum Tab: CaseIterable {
    case recipes, favorites, history
}

struct RootView: View {
    @State private var selectedTab: Tab = .recipes

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                RecipeListView()
            }
            .tabItem { Label("Recipes", systemImage: "cup.and.saucer.fill") }
            .tag(Tab.recipes)

            NavigationStack {
                FavoritesView()
            }
            .tabItem { Label("Favorites", systemImage: "bookmark.fill") }
            .tag(Tab.favorites)

            NavigationStack {
                HistoryView()
            }
            .tabItem { Label("History", systemImage: "clock.fill") }
            .tag(Tab.history)
        }
    }
}
