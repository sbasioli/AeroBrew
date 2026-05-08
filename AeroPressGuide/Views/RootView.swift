import SwiftUI

enum Tab: Int, CaseIterable {
    case recipes, education, history, profile

    var icon: String {
        switch self {
        case .recipes: return "cup.and.saucer.fill"
        case .education: return "book.fill"
        case .history: return "clock.fill"
        case .profile: return "person.crop.circle.fill"
        }
    }
}

struct RootView: View {
    @State private var selectedTab: Tab = .recipes
    @Namespace private var tabNamespace
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        tabContent
            .safeAreaInset(edge: .bottom, spacing: 0) {
                tabBar
                    .padding(.horizontal, 60)
                    .padding(.bottom, 12)
            }
            .ignoresSafeArea(.keyboard)
    }

    @ViewBuilder
    private var tabContent: some View {
        TabView(selection: $selectedTab) {
            NavigationStack { RecipeListView() }
                .tag(Tab.recipes)

            NavigationStack { EducationView() }
                .tag(Tab.education)

            NavigationStack { HistoryView() }
                .tag(Tab.history)

            NavigationStack { ProfileView() }
                .tag(Tab.profile)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut(duration: 0.25), value: selectedTab)
    }

    private var tabBar: some View {
        HStack(spacing: 4) {
            ForEach(Tab.allCases, id: \.self) { tab in
                tabButton(tab)
            }
        }
        .padding(4)
        .glassEffect(.regular.interactive(), in: Capsule())
        .animation(.spring(response: 0.4, dampingFraction: 0.78), value: selectedTab)
    }

    private func tabButton(_ tab: Tab) -> some View {
        Button {
            FeedbackService.shared.impact(.light, context: modelContext)
            withAnimation(.spring(response: 0.4, dampingFraction: 0.78)) {
                selectedTab = tab
            }
        } label: {
            Image(systemName: tab.icon)
                .font(.system(size: 20, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .foregroundStyle(selectedTab == tab ? Color("BrandAccent") : .secondary)
                .background {
                    if selectedTab == tab {
                        Capsule()
                            .fill(Color("BrandAccent").opacity(0.15))
                            .matchedGeometryEffect(id: "selectedTabBackground", in: tabNamespace)
                    }
                }
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
