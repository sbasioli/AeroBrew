import SwiftUI

struct ConsumedCard: View {
    let liters: Double
    let beans: Int
    let sinceLabel: String

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            HStack(alignment: .firstTextBaseline) {
                Text("TOTAL BREWED")
                    .font(.system(size: 11, weight: .medium))
                    .tracking(0.5)
                    .foregroundStyle(Color(hex: 0x854F0B))
                Spacer()
                Text(sinceLabel)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.brandTextSecondary)
            }

            HStack(spacing: 12) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(String(format: "%.1f", liters))
                        .font(.system(size: 32, weight: .medium))
                        .foregroundStyle(Color(hex: 0x4A1B0C))
                    Text("L of coffee")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.brandTextSecondary)
                }
                .frame(maxWidth: .infinity)

                Divider()
                    .frame(height: 36)

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(beans)")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundStyle(Color(hex: 0x4A1B0C))
                    Text("g of beans")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.brandTextSecondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 18))
    }
}
