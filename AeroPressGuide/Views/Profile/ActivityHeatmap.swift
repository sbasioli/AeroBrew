import SwiftUI

struct ActivityHeatmap: View {
    let stats: StatisticsService
    let sessions: [BrewSession]

    @State private var selectedPairIndex: Int = 0
    @State private var selectedDay: Date?

    private var monthPairs: [[Date]] {
        let months = stats.monthsWithHistory(sessions)
        guard !months.isEmpty else { return [] }
        var pairs: [[Date]] = []
        var i = 0
        while i < months.count {
            let end = min(i + 2, months.count)
            pairs.append(Array(months[i..<end]))
            i += 2
        }
        return pairs
    }

    private var canGoOlder: Bool { selectedPairIndex < monthPairs.count - 1 }
    private var canGoNewer: Bool { selectedPairIndex > 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("ACTIVITY")
                    .font(.system(size: 11, weight: .medium))
                    .tracking(0.5)
                    .foregroundStyle(Color.brandTextSecondary)
                Spacer()
                if monthPairs.count > 1 {
                    HStack(spacing: 4) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                selectedPairIndex = min(selectedPairIndex + 1, monthPairs.count - 1)
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(canGoOlder ? .primary : Color.brandTextSecondary.opacity(0.4))
                                .frame(width: 28, height: 28)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .disabled(!canGoOlder)

                        Button {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                selectedPairIndex = max(selectedPairIndex - 1, 0)
                            }
                        } label: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(canGoNewer ? .primary : Color.brandTextSecondary.opacity(0.4))
                                .frame(width: 28, height: 28)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .disabled(!canGoNewer)
                    }
                }
            }
            .padding(.horizontal, 4)

            TabView(selection: $selectedPairIndex) {
                ForEach(Array(monthPairs.enumerated()), id: \.offset) { index, pair in
                    HStack(alignment: .top, spacing: 18) {
                        ForEach(pair, id: \.self) { month in
                            MonthHeatmapPage(
                                month: month,
                                monthSessions: stats.sessions(in: month, from: sessions),
                                stats: stats,
                                onSelectDay: { date in
                                    selectedDay = date
                                }
                            )
                            .frame(maxWidth: .infinity)
                        }
                        if pair.count == 1 {
                            Color.clear
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 18))
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 220)
        }
        .sheet(item: Binding(
            get: { selectedDay.map { DayDetailItem(date: $0) } },
            set: { selectedDay = $0?.date }
        )) { item in
            DayDetailSheet(
                date: item.date,
                sessions: sessionsOn(date: item.date)
            )
        }
    }

    private func sessionsOn(date: Date) -> [BrewSession] {
        let calendar = Calendar.current
        return sessions.filter { calendar.isDate($0.completedAt, inSameDayAs: date) }
    }
}

struct DayDetailItem: Identifiable {
    let date: Date
    var id: Date { date }
}
