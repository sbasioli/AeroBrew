import Foundation

struct StatisticsService {

    func totalBrews(_ sessions: [BrewSession]) -> Int {
        sessions.count
    }

    func totalLiters(_ sessions: [BrewSession], recipes: [Recipe]) -> Double {
        let totalMl = sessions.reduce(0.0) { partial, session in
            partial + waterAmount(for: session, recipes: recipes)
        }
        return totalMl / 1000.0
    }

    func totalBeansGrams(_ sessions: [BrewSession], recipes: [Recipe]) -> Int {
        let total = sessions.reduce(0.0) { partial, session in
            partial + coffeeAmount(for: session, recipes: recipes)
        }
        return Int(total.rounded())
    }

    func hourlyDistribution(_ sessions: [BrewSession]) -> [Int] {
        var hours = Array(repeating: 0, count: 24)
        let calendar = Calendar.current
        for session in sessions {
            let hour = calendar.component(.hour, from: session.completedAt)
            hours[hour] += 1
        }
        return hours
    }

    func peakHourRange(_ sessions: [BrewSession]) -> String? {
        let hours = hourlyDistribution(sessions)
        guard hours.contains(where: { $0 > 0 }) else { return nil }

        var bestStart = 0
        var bestCount = 0
        for i in 0..<23 {
            let count = hours[i] + hours[i + 1]
            if count > bestCount {
                bestCount = count
                bestStart = i
            }
        }
        return String(format: "%02d–%02dh", bestStart, bestStart + 2)
    }

    func brewsByDay(_ sessions: [BrewSession]) -> [Date: Int] {
        let calendar = Calendar.current
        var result: [Date: Int] = [:]
        for session in sessions {
            let day = calendar.startOfDay(for: session.completedAt)
            result[day, default: 0] += 1
        }
        return result
    }

    func sessions(in month: Date, from sessions: [BrewSession]) -> [BrewSession] {
        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .month, for: month) else { return [] }
        return sessions.filter { interval.contains($0.completedAt) }
    }

    func monthsWithHistory(_ sessions: [BrewSession]) -> [Date] {
        let calendar = Calendar.current
        let now = Date()
        let currentMonth = calendar.startOfMonth(for: now)

        let earliestSession = sessions.map(\.completedAt).min().map { calendar.startOfMonth(for: $0) }
        let minimumSpanMonths = 5
        let defaultEarliest = calendar.date(byAdding: .month, value: -minimumSpanMonths, to: currentMonth) ?? currentMonth
        let earliestMonth = min(earliestSession ?? defaultEarliest, defaultEarliest)

        var months: [Date] = []
        var cursor = currentMonth
        while cursor >= earliestMonth {
            months.append(cursor)
            guard let prev = calendar.date(byAdding: .month, value: -1, to: cursor) else { break }
            cursor = prev
        }
        return months
    }

    func intensity(forCount count: Int) -> Int {
        switch count {
        case 0: return 0
        case 1: return 1
        case 2: return 2
        case 3: return 3
        default: return 4
        }
    }

    private func waterAmount(for session: BrewSession, recipes: [Recipe]) -> Double {
        if let value = session.waterAmount { return value }
        return recipes.first(where: { $0.id == session.recipeID })?.waterAmount ?? 0
    }

    private func coffeeAmount(for session: BrewSession, recipes: [Recipe]) -> Double {
        if let value = session.coffeeAmount { return value }
        return recipes.first(where: { $0.id == session.recipeID })?.coffeeAmount ?? 0
    }
}

private extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}
