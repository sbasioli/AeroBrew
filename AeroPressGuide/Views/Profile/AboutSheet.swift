import SwiftUI

struct AboutSheet: View {
    @Environment(\.dismiss) private var dismiss

    private var version: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 6) {
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(Color("BrandPrimary"))
                            .padding(.top, 20)
                        Text("AeroPress Brew Guide")
                            .font(.system(size: 22, weight: .medium))
                        Text("Version \(version)")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.brandTextSecondary)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        AboutRow(
                            title: "Privacy",
                            copy: "All your brewing data stays on this device. Nothing is sent to a server."
                        )
                        AboutRow(
                            title: "No Account",
                            copy: "No registration or login needed. Open the app and start brewing."
                        )
                        AboutRow(
                            title: "Recipe Attribution",
                            copy: "Recipes labelled \"WAC Champion\" are adapted versions of publicly available methods from World AeroPress Championship winners. This app is not affiliated with the World AeroPress Championship organization."
                        )
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 40)
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

private struct AboutRow: View {
    let title: String
    let copy: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
            Text(copy)
                .font(.system(size: 13))
                .foregroundStyle(Color.brandTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 14))
    }
}
