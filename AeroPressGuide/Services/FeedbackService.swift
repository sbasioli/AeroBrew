import Foundation
import SwiftData
import UIKit
import AudioToolbox

@MainActor
final class FeedbackService {
    static let shared = FeedbackService()

    private init() {}

    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle, context: ModelContext) {
        guard UserProfile.current(in: context).hapticsEnabled else { return }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType, context: ModelContext) {
        guard UserProfile.current(in: context).hapticsEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }

    func successSound(context: ModelContext) {
        guard UserProfile.current(in: context).soundEnabled else { return }
        AudioServicesPlaySystemSound(1054)
    }
}
