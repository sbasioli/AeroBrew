import SwiftUI
import SwiftData

struct SettingsSection: View {
    @Bindable var profile: UserProfile
    @Environment(\.modelContext) private var context
    @Query private var allSessions: [BrewSession]

    @State private var showAbout = false
    @State private var showResetConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SETTINGS")
                .font(.system(size: 11, weight: .medium))
                .tracking(0.5)
                .foregroundStyle(Color.brandTextSecondary)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                Toggle(isOn: $profile.soundEnabled) {
                    Text("Timer Sound")
                        .font(.system(size: 16))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                Divider().padding(.leading, 16)

                Toggle(isOn: $profile.hapticsEnabled) {
                    Text("Haptics")
                        .font(.system(size: 16))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                Divider().padding(.leading, 16)

                Button {
                    showAbout = true
                } label: {
                    HStack {
                        Text("About")
                            .font(.system(size: 16))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.brandTextSecondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.plain)
            }
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))

            Button(role: .destructive) {
                showResetConfirmation = true
            } label: {
                HStack {
                    Text("Reset History")
                        .font(.system(size: 16))
                        .foregroundStyle(Color(hex: 0xA32D2D))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color(hex: 0xA32D2D).opacity(0.5))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))
            .padding(.top, 6)
        }
        .sheet(isPresented: $showAbout) {
            AboutSheet()
        }
        .alert("Reset history?", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete All", role: .destructive) {
                resetHistory()
            }
        } message: {
            Text("This will delete all \(allSessions.count) brews. This cannot be undone.")
        }
    }

    private func resetHistory() {
        for session in allSessions {
            context.delete(session)
        }
        try? context.save()
    }
}

