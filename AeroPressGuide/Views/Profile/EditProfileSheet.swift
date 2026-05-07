import SwiftUI
import SwiftData

struct EditProfileSheet: View {
    @Bindable var profile: UserProfile
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var draftName: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $draftName)
                        .autocorrectionDisabled()
                } header: {
                    Text("Your Name")
                } footer: {
                    Text("Used for the avatar initials. Stays only on this device.")
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        profile.name = draftName.trimmingCharacters(in: .whitespaces)
                        try? context.save()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                draftName = profile.name
            }
        }
        .presentationDetents([.medium])
    }
}
