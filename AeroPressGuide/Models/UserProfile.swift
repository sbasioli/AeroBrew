import Foundation
import SwiftData

@Model
final class UserProfile {
    var name: String = ""
    var createdAt: Date = Date()
    var soundEnabled: Bool = true
    var hapticsEnabled: Bool = true

    init(
        name: String = "",
        createdAt: Date = Date(),
        soundEnabled: Bool = true,
        hapticsEnabled: Bool = true
    ) {
        self.name = name
        self.createdAt = createdAt
        self.soundEnabled = soundEnabled
        self.hapticsEnabled = hapticsEnabled
    }

    var initials: String {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return "" }
        let parts = trimmed.split(separator: " ")
        if parts.count >= 2 {
            let first = parts[0].first.map(String.init) ?? ""
            let second = parts[1].first.map(String.init) ?? ""
            return (first + second).uppercased()
        }
        return String(trimmed.prefix(2)).uppercased()
    }
}

extension UserProfile {
    @MainActor
    static func current(in context: ModelContext) -> UserProfile {
        let descriptor = FetchDescriptor<UserProfile>()
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        let new = UserProfile()
        context.insert(new)
        try? context.save()
        return new
    }
}
