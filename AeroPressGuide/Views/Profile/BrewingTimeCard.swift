import SwiftUI

struct BrewingTimeCard: View {
    let distribution: [Int]
    let peakRange: String?

    private var maxCount: Int {
        max(distribution.max() ?? 1, 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("WHEN YOU BREW")
                    .font(.system(size: 11, weight: .medium))
                    .tracking(0.5)
                    .foregroundStyle(Color(hex: 0x185FA5))
                Spacer()
                if let peak = peakRange {
                    Text("Most often \(peak)")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.brandTextSecondary)
                }
            }

            HStack(alignment: .bottom, spacing: 4) {
                ForEach(0..<24, id: \.self) { hour in
                    let ratio = Double(distribution[hour]) / Double(maxCount)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(barColor(for: ratio))
                        .frame(maxWidth: .infinity)
                        .frame(height: max(60 * ratio, 4))
                }
            }
            .frame(height: 60)

            HStack {
                Text("00")
                Spacer()
                Text("06")
                Spacer()
                Text("12")
                Spacer()
                Text("18")
                Spacer()
                Text("24")
            }
            .font(.system(size: 10))
            .foregroundStyle(Color.brandTextSecondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 18))
    }

    private func barColor(for ratio: Double) -> Color {
        switch ratio {
        case 0:           return Color(hex: 0xF1EFE8)
        case 0..<0.25:    return Color(hex: 0xFAEEDA)
        case 0.25..<0.5:  return Color(hex: 0xF5C4B3)
        case 0.5..<0.85:  return Color(hex: 0xE89274)
        default:          return Color(hex: 0xA32D2D)
        }
    }
}
