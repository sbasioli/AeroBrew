import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @State private var showBrew = false
    @Environment(RecipeStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                heroImage
                content
            }
            .padding(.bottom, 100)
        }
        .ignoresSafeArea(edges: [.top, .bottom])
        .overlay(alignment: .top) {
            Rectangle()
                .fill(.thickMaterial)
                .mask {
                    LinearGradient(
                        colors: [.black, .black.opacity(0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .frame(height: 170)
                .ignoresSafeArea(edges: .top)
                .allowsHitTesting(false)
        }
        .safeAreaInset(edge: .bottom) {
            bottomBar
                .background(alignment: .bottom) {
                    Rectangle()
                        .fill(.thickMaterial)
                        .mask {
                            LinearGradient(
                                colors: [.black, .black.opacity(0)],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        }
                        .frame(height: 160)
                        .offset(y: 40)
                        .ignoresSafeArea(edges: .bottom)
                }
        }
        .fullScreenCover(isPresented: $showBrew) {
            BrewView(recipe: recipe)
        }
    }

    // MARK: - Hero Image
    private var heroImage: some View {
        AsyncImage(url: URL(string: recipe.sortedSteps.first?.imageURL ?? "")) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            Color("BrandBorder")
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
        .clipped()
    }

    // MARK: - Content
    private var content: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.title2.weight(.bold))
                Text(recipe.author)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            ParameterGridView(recipe: recipe)

            HStack(spacing: 16) {
                Label(recipe.totalTime.formattedDuration, systemImage: "clock")
                DifficultyBadge(difficulty: recipe.difficulty)
                Text(recipe.method.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline)

            stepsPreview
        }
        .padding(20)
    }

    // MARK: - Steps Preview
    private var stepsPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Steps")
                .font(.headline)

            ForEach(recipe.sortedSteps, id: \.id) { step in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(step.order)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(Color("BrandAccent"))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text(step.title)
                            .font(.subheadline.weight(.medium))
                        Text(step.stepDescription)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    // MARK: - Bottom Bar
    private var bottomBar: some View {
        HStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .font(.subheadline.weight(.medium))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .frame(height: 48)
            .glassEffect(.regular.interactive(), in: Capsule())

            FavoriteButton(recipe: recipe)
                .font(.system(size: 18))
                .frame(width: 48, height: 48)
                .glassEffect(.regular.interactive(), in: Circle())

            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                showBrew = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                    Text("START")
                        .fontWeight(.bold)
                        .kerning(1)
                    Image(systemName: "chevron.right")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 28))
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}
