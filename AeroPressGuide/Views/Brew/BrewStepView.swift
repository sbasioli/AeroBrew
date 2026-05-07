import SwiftUI

struct BrewStepView: View {
    let step: Step
    let timerService: TimerService
    let stepNumber: Int
    let totalSteps: Int

    @State private var fadeOutAfterComplete: Bool = false

    private var fillColor: Color {
        switch timerService.state {
        case .complete: return .green
        default: return Color(red: 0.99, green: 0.97, blue: 0.93)
        }
    }

    private var fillOpacity: Double {
        switch timerService.state {
        case .idle: return 0
        case .complete: return fadeOutAfterComplete ? 0 : 1
        default: return 1
        }
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    AsyncImage(url: URL(string: step.imageURL ?? "")) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color("BrandBorder")
                    }
                    .frame(width: proxy.size.width, height: proxy.size.height * 0.42)
                    .clipped()

                    Spacer(minLength: 0)
                }
                .frame(width: proxy.size.width, height: proxy.size.height)

                Rectangle()
                    .fill(fillColor)
                    .frame(width: proxy.size.width, height: proxy.size.height * timerService.progress)
                    .opacity(fillOpacity)
                    .animation(.linear(duration: 1.0), value: timerService.progress)
                    .animation(.easeInOut(duration: 0.25), value: fillOpacity)
                    .allowsHitTesting(false)

                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(step.title)
                            .font(.title2.weight(.bold))
                        Spacer()
                        Text("\(stepNumber)/\(totalSteps)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.brandTextSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Text(step.stepDescription)
                        .font(.body)
                        .foregroundStyle(Color.brandTextSecondary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if step.hasTimer, let duration = step.timerDuration {
                        TimerView(timerService: timerService, duration: duration)
                            .padding(.top, 8)
                    }
                }
                .padding(20)
                .padding(.bottom, 140)
                .frame(width: proxy.size.width, alignment: .leading)
                .frame(maxHeight: proxy.size.height * 0.58, alignment: .top)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .ignoresSafeArea()
        .onChange(of: timerService.state) { _, newState in
            if newState == .complete {
                Task {
                    try? await Task.sleep(for: .seconds(3))
                    withAnimation(.easeOut(duration: 0.8)) {
                        fadeOutAfterComplete = true
                    }
                }
            } else {
                fadeOutAfterComplete = false
            }
        }
    }
}
