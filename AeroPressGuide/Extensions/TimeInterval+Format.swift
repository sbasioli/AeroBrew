import Foundation

extension Int {
    /// Formats seconds as "M:SS" or "Xs"
    var formattedTime: String {
        let mins = self / 60
        let secs = self % 60
        if mins == 0 { return "\(secs)s" }
        return "\(mins):\(String(format: "%02d", secs))"
    }

    /// Formats seconds as "X min" or "M:SS min"
    var formattedDuration: String {
        if self < 60 { return "\(self)s" }
        let mins = self / 60
        let secs = self % 60
        if secs == 0 { return "\(mins) min" }
        return "\(mins):\(String(format: "%02d", secs)) min"
    }
}

extension Date {
    var relativeFormatted: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "hr-HR")
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: .now)
    }
}
