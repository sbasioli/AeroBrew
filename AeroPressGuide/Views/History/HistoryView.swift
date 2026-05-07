import SwiftUI

struct HistoryView: View {
    @Environment(BrewSessionStore.self) private var sessionStore
    @Environment(RecipeStore.self) private var recipeStore
    @State private var selectedRecipe: Recipe?
    @State private var sortOption: HistorySortOption? = nil

    private func recipe(for session: BrewSession) -> Recipe? {
        recipeStore.allRecipes.first { $0.id == session.recipeID }
    }

    private var sortedSessions: [BrewSession] {
        let sessions = sessionStore.sessions
        guard let sortOption else { return sessions }

        return sessions.sorted { lhs, rhs in
            switch sortOption {
            case .time:
                return lhs.completedAt > rhs.completedAt
            case .author:
                let lhsAuthor = recipe(for: lhs)?.author ?? ""
                let rhsAuthor = recipe(for: rhs)?.author ?? ""
                return lhsAuthor.localizedCaseInsensitiveCompare(rhsAuthor) == .orderedAscending
            case .method:
                let lhsMethod = recipe(for: lhs)?.method.displayName ?? ""
                let rhsMethod = recipe(for: rhs)?.method.displayName ?? ""
                return lhsMethod.localizedCaseInsensitiveCompare(rhsMethod) == .orderedAscending
            case .difficulty:
                return difficultyRank(recipe(for: lhs)?.difficulty)
                    < difficultyRank(recipe(for: rhs)?.difficulty)
            }
        }
    }

    private func difficultyRank(_ difficulty: Difficulty?) -> Int {
        switch difficulty {
        case .beginner: return 0
        case .intermediate: return 1
        case .advanced: return 2
        case .none: return 3
        }
    }

    var body: some View {
        Group {
            if sortedSessions.isEmpty {
                ContentUnavailableView("No History Yet",
                    systemImage: "clock",
                    description: Text("Brew your first coffee and your history will appear here"))
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(sortedSessions) { session in
                            Button {
                                if let recipe = recipe(for: session) {
                                    selectedRecipe = recipe
                                }
                            } label: {
                                HistoryRowView(
                                    session: session,
                                    recipe: recipe(for: session)
                                )
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
            HistoryHeaderBar(sortOption: $sortOption)
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        .fullScreenCover(item: $selectedRecipe) { recipe in
            RecipeDetailView(recipe: recipe)
        }
    }
}

private struct HistoryHeaderBar: View {
    @Binding var sortOption: HistorySortOption?

    var body: some View {
        HStack(spacing: 8) {
            Spacer()
            HistorySortMenu(sortOption: $sortOption)
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

struct HistoryRowView: View {
    let session: BrewSession
    let recipe: Recipe?

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            AsyncImage(url: URL(string: recipe?.sortedSteps.first?.imageURL ?? "")) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color("BrandBorder")
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(session.recipeName)
                    .font(.headline)
                    .lineLimit(1)
                Text(session.completedAt.relativeFormatted)
                    .font(.subheadline)
                    .foregroundStyle(Color.brandTextSecondary)

                if let notes = session.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(Color.brandTextSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            if let rating = session.rating {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(Color("BrandWarning"))
                    Text("\(rating)")
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color("BrandWarning").opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(12)
        .background(Color("BrandSurface"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color("BrandPrimary").opacity(0.08), radius: 8, y: 2)
    }
}
