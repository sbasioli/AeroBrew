import SwiftUI

struct FavoritesView: View {
    @Environment(RecipeStore.self) private var store
    @State private var selectedRecipe: Recipe?
    @State private var sortOption: RecipeSortOption? = nil

    private var sortedFavorites: [Recipe] {
        let favorites = store.favoriteRecipes
        guard let sortOption else { return favorites }

        return favorites.sorted { lhs, rhs in
            switch sortOption {
            case .author:
                return lhs.author.localizedCaseInsensitiveCompare(rhs.author) == .orderedAscending
            case .method:
                return lhs.method.displayName.localizedCaseInsensitiveCompare(rhs.method.displayName) == .orderedAscending
            case .difficulty:
                return difficultyRank(lhs.difficulty) < difficultyRank(rhs.difficulty)
            }
        }
    }

    private func difficultyRank(_ difficulty: Difficulty) -> Int {
        switch difficulty {
        case .beginner: return 0
        case .intermediate: return 1
        case .advanced: return 2
        }
    }

    var body: some View {
        Group {
            if sortedFavorites.isEmpty {
                ContentUnavailableView("No Favorites",
                    systemImage: "bookmark",
                    description: Text("Add recipes to favorites by tapping the bookmark"))
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(sortedFavorites) { recipe in
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
                    .padding(.bottom, 24)
                }
                .scrollEdgeEffectStyle(nil, for: .top)
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            FavoritesSortBar(sortOption: $sortOption)
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        .fullScreenCover(item: $selectedRecipe) { recipe in
            RecipeDetailView(recipe: recipe)
        }
    }
}

private struct FavoritesSortBar: View {
    @Binding var sortOption: RecipeSortOption?

    var body: some View {
        HStack(spacing: 8) {
            Spacer()
            RecipeSortMenu(sortOption: $sortOption)
                .padding(.trailing, 16)
        }
        .frame(height: 44)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(alignment: .bottom) {
            ProgressiveBlurHeaderBackground()
        }
    }
}
