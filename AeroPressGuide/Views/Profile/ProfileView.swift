import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \BrewSession.completedAt, order: .reverse) private var sessions: [BrewSession]
    @Query private var allRecipes: [Recipe]

    @State private var showEditProfile = false

    private let stats = StatisticsService()

    private var profile: UserProfile {
        UserProfile.current(in: context)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                AvatarHeader(
                    profile: profile,
                    totalBrews: stats.totalBrews(sessions),
                    onEdit: { showEditProfile = true }
                )

                ConsumedCard(
                    liters: stats.totalLiters(sessions, recipes: allRecipes),
                    beans: stats.totalBeansGrams(sessions, recipes: allRecipes)
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
        .sheet(isPresented: $showEditProfile) {
            EditProfileSheet(profile: profile)
        }
    }
}
