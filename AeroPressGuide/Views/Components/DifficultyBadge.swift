import SwiftUI

struct DifficultyBadge: View {
    let difficulty: Difficulty

    var body: some View {
        Text(difficulty.localizedName)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .foregroundStyle(Color(difficulty.color))
            .background(Color(difficulty.color).opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}
