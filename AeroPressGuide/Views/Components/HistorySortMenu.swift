import SwiftUI

enum HistorySortOption: String, CaseIterable, Identifiable {
    case time, author, method, difficulty

    var id: String { rawValue }

    var label: String {
        switch self {
        case .time: return "Time"
        case .author: return "Author"
        case .method: return "Method"
        case .difficulty: return "Difficulty"
        }
    }

    var systemImage: String {
        switch self {
        case .time: return "clock"
        case .author: return "person"
        case .method: return "cup.and.saucer"
        case .difficulty: return "chart.bar"
        }
    }
}

struct HistorySortMenu: View {
    @Binding var sortOption: HistorySortOption?

    var body: some View {
        Menu {
            Button {
                sortOption = nil
            } label: {
                if sortOption == nil {
                    Label("Default", systemImage: "checkmark")
                } else {
                    Text("Default")
                }
            }
            Divider()
            ForEach(HistorySortOption.allCases) { option in
                Button {
                    sortOption = option
                } label: {
                    if sortOption == option {
                        Label(option.label, systemImage: "checkmark")
                    } else {
                        Label(option.label, systemImage: option.systemImage)
                    }
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .font(.system(size: 15, weight: .semibold))
                .frame(width: 36, height: 36)
                .foregroundStyle(sortOption == nil ? .primary : Color("BrandPrimary"))
        }
        .glassEffect(
            sortOption == nil
                ? .regular.interactive()
                : .regular.tint(Color("BrandPrimary").opacity(0.15)).interactive(),
            in: Circle()
        )
    }
}
