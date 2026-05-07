import SwiftUI

struct GlossaryDetailView: View {
    let term: GlossaryTerm
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(term.term)
                    .font(.largeTitle.weight(.bold))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(term.shortDescription)
                    .font(.title3)
                    .foregroundStyle(Color.brandTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Divider()
                    .padding(.vertical, 4)

                Text(term.detailedDescription)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(20)
            .padding(.top, 60)
            .padding(.bottom, 40)
        }
        .scrollEdgeEffectStyle(nil, for: .top)
        .safeAreaInset(edge: .bottom) {
            CloseBottomBar { dismiss() }
        }
        .overlay(alignment: .top) {
            VariableBlurView(maxBlurRadius: 12, direction: .blurredTopClearBottom)
                .frame(height: 100)
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
}

struct CloseBottomBar: View {
    let action: () -> Void

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "xmark")
                    .font(.subheadline.weight(.semibold))
                Text("Close")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: Capsule())
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .background(alignment: .top) {
            VariableBlurView(maxBlurRadius: 8, direction: .blurredBottomClearTop)
                .frame(height: 130)
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .black, location: 0.45),
                            .init(color: .black, location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .offset(y: -30)
                .ignoresSafeArea(edges: .bottom)
                .allowsHitTesting(false)
        }
    }
}
