import SwiftUI

struct BrewCompleteSheet: View {
    let recipe: Recipe
    var onFinish: () -> Void = {}
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(BrewSessionStore.self) private var sessionStore

    @State private var rating: Int = 0
    @State private var notes: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Coffee cup icon
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Color("BrandAccent"))
                    .padding(20)
                    .glassEffect(.regular, in: Circle())

                Text("Coffee is Ready!")
                    .font(.title2.weight(.bold))
                Text("How did you like it?")
                    .foregroundStyle(Color.brandTextSecondary)

                // Star rating
                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { star in
                        Button {
                            FeedbackService.shared.impact(.light, context: modelContext)
                            rating = star
                        } label: {
                            Image(systemName: star <= rating ? "star.fill" : "star")
                                .font(.system(size: 36))
                                .foregroundStyle(star <= rating ? Color("BrandWarning") : Color.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }

                // Notes input
                TextField("Add a note...", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
                    .padding(16)
                    .background(Color("BrandBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                // Buttons
                VStack(spacing: 12) {
                    Button("Save") {
                        save(withRating: rating > 0 ? rating : nil, notes: notes)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .glassEffect(.regular.tint(Color("BrandPrimary")).interactive(),
                                 in: RoundedRectangle(cornerRadius: 28))

                    Button("Skip") {
                        save(withRating: nil, notes: nil)
                    }
                    .foregroundStyle(Color.brandTextSecondary)
                }
            }
            .padding(24)
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    private func save(withRating r: Int?, notes n: String?) {
        sessionStore.addSession(BrewSession(
            recipeID: recipe.id,
            recipeName: recipe.name,
            rating: r,
            notes: n?.isEmpty == false ? n : nil,
            coffeeAmount: recipe.coffeeAmount,
            waterAmount: recipe.waterAmount
        ))
        dismiss()
        onFinish()
    }
}
