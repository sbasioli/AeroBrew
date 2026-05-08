import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \BrewSession.completedAt, order: .reverse) private var sessions: [BrewSession]
    @Query private var allRecipes: [Recipe]

    private let stats = StatisticsService()

    private var profile: UserProfile {
        UserProfile.current(in: context)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                ConsumedCard(
                    liters: stats.totalLiters(sessions, recipes: allRecipes),
                    beans: stats.totalBeansGrams(sessions, recipes: allRecipes),
                    sinceLabel: brewsSinceLabel
                )

                BrewingTimeCard(
                    distribution: stats.hourlyDistribution(sessions),
                    peakRange: stats.peakHourRange(sessions)
                )

                ActivityHeatmap(stats: stats, sessions: sessions)

                SettingsSection(profile: profile)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 100)
        }
        .scrollEdgeEffectStyle(nil, for: .top)
        .overlay(alignment: .top) {
            ProgressiveBlurHeaderBackground(maxBlurRadius: 12, height: 100)
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private var brewsSinceLabel: String {
        let total = stats.totalBrews(sessions)
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "LLLL yyyy"
        let monthString = formatter.string(from: profile.createdAt)
        let plural = total == 1 ? "brew" : "brews"
        return "\(total) \(plural) since \(monthString)"
    }
}
