import SwiftUI

struct BrewStepView: View {
    let step: Step
    let timerService: TimerService

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Hero image
                AsyncImage(url: URL(string: step.imageURL ?? "")) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color("BrandBorder")
                }
                .frame(maxWidth: .infinity)
                .frame(height: UIScreen.main.bounds.height * 0.42)
                .clipped()

                // Step content
                VStack(alignment: .leading, spacing: 16) {
                    Text(step.title)
                        .font(.title2.weight(.bold))

                    Text(step.stepDescription)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineSpacing(4)

                    if step.hasTimer, let duration = step.timerDuration {
                        TimerView(timerService: timerService, duration: duration)
                            .padding(.top, 8)
                    }
                }
                .padding(20)
                .padding(.bottom, 140)
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}
