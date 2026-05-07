import SwiftUI

struct DayDetailSheet: View {
    let date: Date
    let sessions: [BrewSession]
    @Environment(\.dismiss) private var dismiss

    private var dateLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    if sessions.isEmpty {
                        ContentUnavailableView(
                            "No Brews",
                            systemImage: "cup.and.saucer",
                            description: Text("You didn't brew any coffee on this day.")
                        )
                        .padding(.top, 40)
                    } else {
                        ForEach(sessions) { session in
                            SessionRow(session: session)
                        }
                    }
                }
                .padding(16)
            }
            .navigationTitle(dateLabel)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

private struct SessionRow: View {
    let session: BrewSession

    private var timeLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: session.completedAt)
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(session.recipeName)
                    .font(.system(size: 15, weight: .medium))
                Text(timeLabel)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.brandTextSecondary)
            }
            Spacer()
            if let rating = session.rating, rating > 0 {
                HStack(spacing: 2) {
                    ForEach(0..<5, id: \.self) { index in
                        Image(systemName: index < rating ? "star.fill" : "star")
                            .font(.system(size: 10))
                            .foregroundStyle(Color(hex: 0xC79115))
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 14))
    }
}
