import SwiftUI

struct RecipeCardView: View {
    let recipe: Recipe
    @Environment(RecipeStore.self) private var store

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: recipe.sortedSteps.first?.imageURL ?? "")) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color("BrandBorder")
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(recipe.name)
                        .font(.headline)
                        .lineLimit(1)
                    Spacer()
                    FavoriteButton(recipe: recipe)
                }
                Text(recipe.author)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Label(recipe.totalTime.formattedDuration, systemImage: "clock")
                    Label("\(Int(recipe.coffeeAmount))g", systemImage: "cup.and.saucer")
                    Label("\(Int(recipe.waterAmount))ml", systemImage: "drop")
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                HStack {
                    DifficultyBadge(difficulty: recipe.difficulty)
                    Spacer()
                    Text(recipe.method.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color("BrandSurface"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color("BrandPrimary").opacity(0.08), radius: 8, y: 2)
    }
}
