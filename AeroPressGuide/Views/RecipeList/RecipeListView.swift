import SwiftUI

struct RecipeListView: View {
    @Environment(RecipeStore.self) private var store
    @State private var selectedRecipe: Recipe?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(store.allRecipes) { recipe in
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
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(item: $selectedRecipe) { recipe in
            RecipeDetailView(recipe: recipe)
        }
    }
}
