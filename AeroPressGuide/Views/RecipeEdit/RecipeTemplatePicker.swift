import SwiftUI

struct RecipeTemplatePicker: View {
    let recipes: [Recipe]
    let onPick: (Recipe) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(recipes) { recipe in
                    Button {
                        onPick(recipe)
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(recipe.name)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text(recipe.author)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.brandTextSecondary)
                            }
                            Spacer()
                            Text(recipe.method.displayName)
                                .font(.caption)
                                .foregroundStyle(Color.brandTextSecondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Choose Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
