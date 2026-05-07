import SwiftUI

struct DayCell: View {
    let date: Date
    let count: Int
    let isToday: Bool
    let stats: StatisticsService
    let onTap: () -> Void

    private var day: Int {
        Calendar.current.component(.day, from: date)
    }

    private var background: Color {
        switch stats.intensity(forCount: count) {
        case 0: return Color(hex: 0xF1EFE8)
        case 1: return Color(hex: 0xFAEEDA)
        case 2: return Color(hex: 0xF5C4B3)
        case 3: return Color(hex: 0xE89274)
        default: return Color(hex: 0xA32D2D)
        }
    }

    private var foreground: Color {
        switch stats.intensity(forCount: count) {
        case 0: return Color.brandTextSecondary
        case 1, 2: return Color(hex: 0x4A1B0C)
        default: return .white
        }
    }

    var body: some View {
        Button(action: onTap) {
            RoundedRectangle(cornerRadius: 4)
                .fill(background)
                .aspectRatio(1, contentMode: .fit)
        }
        .buttonStyle(.plain)
    }
}
