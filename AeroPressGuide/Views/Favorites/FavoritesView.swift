import SwiftUI

struct FavoritesView: View {
    @Environment(RecipeStore.self) private var store
    @State private var selectedRecipe: Recipe?

    var body: some View {
        Group {
            if store.favoriteRecipes.isEmpty {
                ContentUnavailableView("No Favorites",
                    systemImage: "bookmark",
                    description: Text("Add recipes to favorites by tapping the bookmark"))
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(store.favoriteRecipes) { recipe in
                            Button {
                                selectedRecipe = recipe
                            } label: {
                                RecipeCardView(recipe: recipe)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
        }
        .navigationTitle("Favorites")
        .fullScreenCover(item: $selectedRecipe) { recipe in
            RecipeDetailView(recipe: recipe)
        }
    }
}
