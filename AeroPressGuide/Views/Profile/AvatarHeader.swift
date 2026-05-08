import SwiftUI

struct AvatarHeader: View {
    let profile: UserProfile
    let totalBrews: Int

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
                Image(systemName: "person.fill")
                    .foregroundStyle(.white)
                    .font(.system(size: 24))
            }

            Text("Profile")
                .font(.system(size: 20, weight: .medium))

            Spacer()
        }
        .padding(.vertical, 8)
    }
}
