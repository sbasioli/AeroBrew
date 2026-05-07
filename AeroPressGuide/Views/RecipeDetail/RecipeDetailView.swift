import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @State private var showBrew = false
    @Environment(RecipeStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    heroImage(width: proxy.size.width)
                    content
                }
                .frame(width: proxy.size.width, alignment: .leading)
                .padding(.bottom, 100)
            }
            .frame(width: proxy.size.width)
        }
        .ignoresSafeArea(edges: [.top, .bottom])
        .overlay(alignment: .top) {
            VariableBlurView(maxBlurRadius: 12, direction: .blurredTopClearBottom)
                .frame(height: 130)
                .ignoresSafeArea(edges: .top)
                .allowsHitTesting(false)
        }
        .safeAreaInset(edge: .bottom) {
            bottomBar
                .background(alignment: .bottom) {
                    VariableBlurView(maxBlurRadius: 6, direction: .blurredBottomClearTop)
                        .frame(height: 100)
                        .offset(y: 30)
                        .ignoresSafeArea(edges: .bottom)
                }
        }
        .fullScreenCover(isPresented: $showBrew) {
            BrewView(recipe: recipe, onFinish: {
                dismiss()
            })
        }
    }

    // MARK: - Hero Image
    private func heroImage(width: CGFloat) -> some View {
        AsyncImage(url: URL(string: recipe.sortedSteps.first?.imageURL ?? "")) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            Color("BrandBorder")
        }
        .frame(width: width, height: 300)
        .clipped()
    }

    // MARK: - Content
    private var content: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.title2.weight(.bold))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(recipe.author)
                    .font(.subheadline)
                    .foregroundStyle(Color.brandTextSecondary)
            }

            ParameterGridView(recipe: recipe)

            HStack(spacing: 16) {
                Label(recipe.totalTime.formattedDuration, systemImage: "clock")
                DifficultyBadge(difficulty: recipe.difficulty)
                Spacer(minLength: 0)
                Text(recipe.method.displayName)
                    .font(.subheadline)
                    .foregroundStyle(Color.brandTextSecondary)
            }
            .font(.subheadline)

            stepsPreview
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
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
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(step.stepDescription)
                            .font(.caption)
                            .foregroundStyle(Color.brandTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
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

