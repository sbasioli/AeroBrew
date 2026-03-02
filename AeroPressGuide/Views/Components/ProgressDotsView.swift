import SwiftUI

struct ProgressDotsView: View {
    let total: Int
    let current: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .fill(dotColor(for: index))
                    .frame(width: dotSize(for: index), height: dotSize(for: index))
                    .animation(.spring(duration: 0.3), value: current)
            }
        }
    }

    private func dotColor(for index: Int) -> Color {
        if index == current { return Color("BrandPrimary") }
        if index < current { return Color("BrandAccent") }
        return Color("BrandBorder")
    }

    private func dotSize(for index: Int) -> CGFloat {
        index == current ? 10 : 8
    }
}
