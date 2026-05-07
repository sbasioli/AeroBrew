import SwiftUI
import UIKit
import CoreImage.CIFilterBuiltins
import QuartzCore

// Vendored from https://github.com/nikstar/VariableBlur (MIT).
// Uses obfuscated private CAFilter API. App Store risk noted.

enum VariableBlurDirection {
    case blurredTopClearBottom
    case blurredBottomClearTop
}

struct VariableBlurView: UIViewRepresentable {
    var maxBlurRadius: CGFloat = 20
    var direction: VariableBlurDirection = .blurredTopClearBottom
    var startOffset: CGFloat = 0

    func makeUIView(context: Context) -> VariableBlurUIView {
        VariableBlurUIView(maxBlurRadius: maxBlurRadius, direction: direction, startOffset: startOffset)
    }

    func updateUIView(_ uiView: VariableBlurUIView, context: Context) {}
}

final class VariableBlurUIView: UIVisualEffectView {
    init(maxBlurRadius: CGFloat, direction: VariableBlurDirection, startOffset: CGFloat) {
        super.init(effect: UIBlurEffect(style: .regular))

        let clsName = String("retliFAC".reversed())
        guard let Cls = NSClassFromString(clsName) as? NSObject.Type else { return }
        let selName = String(":epyThtiWretlif".reversed())
        guard let variableBlur = Cls.perform(NSSelectorFromString(selName), with: "variableBlur").takeUnretainedValue() as? NSObject else { return }

        let gradientImage = Self.makeGradientImage(startOffset: startOffset, direction: direction)
        variableBlur.setValue(maxBlurRadius, forKey: "inputRadius")
        variableBlur.setValue(gradientImage, forKey: "inputMaskImage")
        variableBlur.setValue(true, forKey: "inputNormalizeEdges")

        let backdropLayer = subviews.first?.layer
        backdropLayer?.filters = [variableBlur]

        for subview in subviews.dropFirst() {
            subview.alpha = 0
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    override func didMoveToWindow() {
        guard let window, let backdropLayer = subviews.first?.layer else { return }
        backdropLayer.setValue(window.traitCollection.displayScale, forKey: "scale")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // intentionally no super call (crashes the app)
    }

    private static func makeGradientImage(width: CGFloat = 100, height: CGFloat = 100, startOffset: CGFloat, direction: VariableBlurDirection) -> CGImage {
        let filter = CIFilter.linearGradient()
        filter.color0 = CIColor.black
        filter.color1 = CIColor.clear
        filter.point0 = CGPoint(x: 0, y: height)
        filter.point1 = CGPoint(x: 0, y: startOffset * height)
        if case .blurredBottomClearTop = direction {
            filter.point0.y = 0
            filter.point1.y = height - filter.point1.y
        }
        return CIContext().createCGImage(filter.outputImage!, from: CGRect(x: 0, y: 0, width: width, height: height))!
    }
}
