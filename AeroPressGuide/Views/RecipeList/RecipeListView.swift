import SwiftUI

enum RecipeSortOption: String, CaseIterable, Identifiable {
    case author, method, difficulty

    var id: String { rawValue }

    var label: String {
        switch self {
        case .author: return "Author"
        case .method: return "Method"
        case .difficulty: return "Difficulty"
        }
    }

    var systemImage: String {
        switch self {
        case .author: return "person"
        case .method: return "cup.and.saucer"
        case .difficulty: return "chart.bar"
        }
    }
}

struct RecipeListView: View {
    @Environment(RecipeStore.self) private var store
    @State private var selectedRecipe: Recipe?
    @State private var methodFilter: BrewMethod? = nil
    @State private var difficultyFilter: Difficulty? = nil
    @State private var sortOption: RecipeSortOption? = nil
    @State private var favoritesOnly: Bool = false

    @State private var showAddEditor: Bool = false
    @State private var recipeToEdit: Recipe? = nil
    @State private var deleteCandidate: Recipe? = nil

    private var filteredRecipes: [Recipe] {
        let filtered = store.allRecipes.filter { recipe in
            (methodFilter == nil || recipe.method == methodFilter) &&
            (difficultyFilter == nil || recipe.difficulty == difficultyFilter) &&
            (!favoritesOnly || recipe.isFavorite)
        }

        guard let sortOption else { return filtered }

        return filtered.sorted { lhs, rhs in
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
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredRecipes) { recipe in
                    Button {
                        selectedRecipe = recipe
                    } label: {
                        RecipeCardView(recipe: recipe)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        if recipe.isCustom {
                            Button {
                                recipeToEdit = recipe
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                deleteCandidate = recipe
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }

                if filteredRecipes.isEmpty {
                    emptyState
                        .padding(.top, 80)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .scrollEdgeEffectStyle(nil, for: .top)
        .safeAreaInset(edge: .top, spacing: 0) {
            FilterBar(
                methodFilter: $methodFilter,
                difficultyFilter: $difficultyFilter,
                sortOption: $sortOption,
                favoritesOnly: $favoritesOnly,
                onAdd: { showAddEditor = true }
            )
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        .fullScreenCover(item: $selectedRecipe) { recipe in
            RecipeDetailView(recipe: recipe)
        }
        .sheet(isPresented: $showAddEditor) {
            RecipeEditView(
                mode: .createNew,
                initialDraft: RecipeDraft(),
                templates: store.allRecipes
            ) { recipe in
                store.addCustomRecipe(recipe)
            }
        }
        .sheet(item: $recipeToEdit) { recipe in
            RecipeEditView(
                mode: .editExisting(recipe),
                initialDraft: RecipeDraft.from(recipe)
            ) { _ in
                store.fetchRecipes()
            }
        }
        .alert(
            "Delete \(deleteCandidate?.name ?? "Recipe")?",
            isPresented: Binding(
                get: { deleteCandidate != nil },
                set: { if !$0 { deleteCandidate = nil } }
            )
        ) {
            Button("Cancel", role: .cancel) { deleteCandidate = nil }
            Button("Delete", role: .destructive) {
                if let recipe = deleteCandidate {
                    store.deleteRecipe(recipe)
                }
                deleteCandidate = nil
            }
        } message: {
            Text("This recipe will be permanently deleted.")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.system(size: 36))
                .foregroundStyle(Color.brandTextSecondary)
            Text("No recipes match the selected filters")
                .font(.subheadline)
                .foregroundStyle(Color.brandTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct FilterBar: View {
    @Binding var methodFilter: BrewMethod?
    @Binding var difficultyFilter: Difficulty?
    @Binding var sortOption: RecipeSortOption?
    @Binding var favoritesOnly: Bool
    var onAdd: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            RecipeSortMenu(sortOption: $sortOption)
                .padding(.leading, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(
                        title: "Method",
                        selection: methodFilter?.displayName,
                        options: BrewMethod.allCases.map { ($0.displayName, $0) },
                        onSelect: { methodFilter = $0 },
                        onClear: { methodFilter = nil }
                    )

                    FilterChip(
                        title: "Difficulty",
                        selection: difficultyFilter?.localizedName,
                        options: Difficulty.allCases.map { ($0.localizedName, $0) },
                        onSelect: { difficultyFilter = $0 },
                        onClear: { difficultyFilter = nil }
                    )

                    if methodFilter != nil || difficultyFilter != nil {
                        Button {
                            methodFilter = nil
                            difficultyFilter = nil
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "xmark")
                                    .font(.caption.weight(.semibold))
                                Text("Clear")
                                    .font(.subheadline.weight(.medium))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                        }
                        .glassEffect(.regular.interactive(), in: Capsule())
                        .foregroundStyle(Color.brandTextSecondary)
                    }
                }
                .padding(.trailing, 8)
                .padding(.vertical, 4)
            }
            .scrollClipDisabled()

            FavoritesFilterToggle(isOn: $favoritesOnly)

            AddRecipeButton(action: onAdd)
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

private struct FilterChip<Value: Hashable>: View {
    let title: String
    let selection: String?
    let options: [(String, Value)]
    let onSelect: (Value) -> Void
    let onClear: () -> Void

    var body: some View {
        Menu {
            Button("All") { onClear() }
            Divider()
            ForEach(options, id: \.1) { option in
                Button {
                    onSelect(option.1)
                } label: {
                    if selection == option.0 {
                        Label(option.0, systemImage: "checkmark")
                    } else {
                        Text(option.0)
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(selection ?? title)
                    .font(.subheadline.weight(.medium))
                Image(systemName: "chevron.down")
                    .font(.caption2.weight(.semibold))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .foregroundStyle(selection == nil ? .primary : Color("BrandPrimary"))
        }
        .glassEffect(
            selection == nil
                ? .regular.interactive()
                : .regular.tint(Color("BrandPrimary").opacity(0.15)).interactive(),
            in: Capsule()
        )
    }
}
