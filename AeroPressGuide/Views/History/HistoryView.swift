import SwiftUI

struct HistoryView: View {
    @Environment(BrewSessionStore.self) private var sessionStore

    var body: some View {
        Group {
            if sessionStore.sessions.isEmpty {
                ContentUnavailableView("No History Yet",
                    systemImage: "clock",
                    description: Text("Brew your first coffee and your history will appear here"))
            } else {
                List {
                    ForEach(sessionStore.sessions) { session in
                        HistoryRowView(session: session)
                    }
                    .onDelete { indexSet in
                        sessionStore.deleteSessions(at: indexSet)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("History")
    }
}

struct HistoryRowView: View {
    let session: BrewSession

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "cup.and.saucer.fill")
                    .foregroundStyle(Color("BrandAccent"))
                    .frame(width: 44, height: 44)
                    .background(Color("BrandPrimary").opacity(0.1))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(session.recipeName)
                        .font(.headline)
                    Text(session.completedAt.relativeFormatted)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if let rating = session.rating {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(Color("BrandWarning"))
                        Text("\(rating)")
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color("BrandWarning").opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }

            if let notes = session.notes {
                Text(notes)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}
