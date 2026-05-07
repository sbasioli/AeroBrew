import SwiftUI

struct MonthHeatmapPage: View {
    let month: Date
    let monthSessions: [BrewSession]
    let stats: StatisticsService
    let onSelectDay: (Date) -> Void

    private var calendar: Calendar { Calendar.current }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: month)
    }

    private var monthSubtitle: String {
        let count = monthSessions.count
        let liters = monthSessions.reduce(0.0) { partial, session in
            partial + (session.waterAmount ?? 0)
        } / 1000.0
        let plural = count == 1 ? "brew" : "brews"
        return String(format: "%d %@ · %.1f L", count, plural, liters)
    }

    private var brewsByDay: [Date: Int] {
        stats.brewsByDay(monthSessions)
    }

    private var weekdaySymbols: [String] {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let firstWeekdayIndex = calendar.firstWeekday - 1
        return Array(symbols[firstWeekdayIndex...] + symbols[..<firstWeekdayIndex])
    }

    private var calendarDays: [Date?] {
        var days: [Date?] = []
        guard let monthInterval = calendar.dateInterval(of: .month, for: month) else {
            return []
        }
        let firstWeekday = calendar.component(.weekday, from: monthInterval.start)
        let leadingEmpty = (firstWeekday - calendar.firstWeekday + 7) % 7
        for _ in 0..<leadingEmpty { days.append(nil) }

        let range = calendar.range(of: .day, in: .month, for: month) ?? 1..<2
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthInterval.start) {
                days.append(date)
            }
        }
        return days
    }

    var body: some View {
        VStack(spacing: 12) {
            Text(monthTitle)
                .font(.system(size: 14, weight: .medium))
                .frame(maxWidth: .infinity)

            LazyVGrid(columns: Array(repeating: GridItem(.fixed(16), spacing: 3), count: 7), spacing: 3) {
                ForEach(Array(calendarDays.enumerated()), id: \.offset) { _, date in
                    if let date = date {
                        DayCell(
                            date: date,
                            count: brewsByDay[calendar.startOfDay(for: date)] ?? 0,
                            isToday: calendar.isDateInToday(date),
                            stats: stats,
                            onTap: { onSelectDay(date) }
                        )
                        .frame(width: 16, height: 16)
                    } else {
                        Color.clear.frame(width: 16, height: 16)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }
}
