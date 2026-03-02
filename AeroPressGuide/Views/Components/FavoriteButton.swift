import SwiftUI

struct FavoriteButton: View {
    let recipe: Recipe
    @Environment(RecipeStore.self) private var store

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            store.toggleFavorite(recipe)
        } label: {
            Image(systemName: recipe.isFavorite ? "bookmark.fill" : "bookmark")
                .foregroundStyle(recipe.isFavorite ? Color("BrandAccent") : .secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
