import SwiftUI

struct AvatarHeader: View {
    let profile: UserProfile
    let totalBrews: Int
    let onEdit: () -> Void

    private var subtitle: String {
        let monthFormatter = DateFormatter()
        monthFormatter.locale = Locale.current
        monthFormatter.dateFormat = "LLLL yyyy"
        let monthString = monthFormatter.string(from: profile.createdAt)
        let plural = totalBrews == 1 ? "brew" : "brews"
        return "\(totalBrews) \(plural) since \(monthString)"
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color(hex: 0x4A1B0C), Color(hex: 0x8B3A1C)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 56, height: 56)
                if profile.initials.isEmpty {
                    Image(systemName: "person.fill")
                        .foregroundStyle(.white)
                        .font(.system(size: 24))
                } else {
                    Text(profile.initials)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.white)
                        .tracking(0.5)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(profile.name.isEmpty ? "Profile" : profile.name)
                    .font(.system(size: 20, weight: .medium))
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.brandTextSecondary)
            }

            Spacer()

            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.primary)
                    .frame(width: 36, height: 36)
                    .contentShape(Circle())
            }
            .glassEffect(.regular.interactive(), in: Circle())
        }
        .padding(.vertical, 8)
    }
}
