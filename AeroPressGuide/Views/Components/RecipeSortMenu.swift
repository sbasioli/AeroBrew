import SwiftUI

struct RecipeSortMenu: View {
    @Binding var sortOption: RecipeSortOption?

    var body: some View {
        Menu {
            Button {
                sortOption = nil
            } label: {
                if sortOption == nil {
                    Label("Default", systemImage: "checkmark")
                } else {
                    Text("Default")
                }
            }
            Divider()
            ForEach(RecipeSortOption.allCases) { option in
                Button {
                    sortOption = option
                } label: {
                    if sortOption == option {
                        Label(option.label, systemImage: "checkmark")
                    } else {
                        Label(option.label, systemImage: option.systemImage)
                    }
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .font(.system(size: 15, weight: .semibold))
                .frame(width: 36, height: 36)
                .foregroundStyle(sortOption == nil ? .primary : Color("BrandPrimary"))
        }
        .glassEffect(
            sortOption == nil
                ? .regular.interactive()
                : .regular.tint(Color("BrandPrimary").opacity(0.15)).interactive(),
            in: Circle()
        )
    }
}

struct FavoritesFilterToggle: View {
    @Binding var isOn: Bool

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            isOn.toggle()
        } label: {
            Image(systemName: isOn ? "bookmark.fill" : "bookmark")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(isOn ? Color("BrandAccent") : .primary)
                .frame(width: 36, height: 36)
                .contentShape(Circle())
        }
        .glassEffect(
            isOn
                ? .regular.tint(Color("BrandAccent").opacity(0.15)).interactive()
                : .regular.interactive(),
            in: Circle()
        )
    }
}

struct ProgressiveBlurHeaderBackground: View {
    var maxBlurRadius: CGFloat = 10
    var height: CGFloat = 130

    var body: some View {
        VariableBlurView(
            maxBlurRadius: maxBlurRadius,
            direction: .blurredTopClearBottom
        )
        .frame(height: height)
        .mask(
            LinearGradient(
                stops: [
                    .init(color: .black, location: 0),
                    .init(color: .black, location: 0.55),
                    .init(color: .clear, location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .ignoresSafeArea(edges: .top)
        .allowsHitTesting(false)
    }
}
