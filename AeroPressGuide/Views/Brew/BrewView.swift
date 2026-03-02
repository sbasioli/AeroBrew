import SwiftUI

struct BrewView: View {
    let recipe: Recipe
    @Environment(\.dismiss) private var dismiss
    @State private var currentStepIndex: Int = 0
    @State private var showComplete: Bool = false
    @State private var timerService = TimerService()

    private var steps: [Step] { recipe.sortedSteps }
    private var isLastStep: Bool { currentStepIndex == steps.count - 1 }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Content: swipeable steps
            TabView(selection: $currentStepIndex) {
                ForEach(steps.indices, id: \.self) { index in
                    BrewStepView(step: steps[index], timerService: timerService)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
            .onChange(of: currentStepIndex) { _, newIndex in
                timerService.reset()
                if let duration = steps[newIndex].timerDuration, steps[newIndex].hasTimer {
                    timerService.configure(duration: duration)
                } else {
                    timerService.configure(duration: 0)
                }
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }

            // Floating bottom controls (glass)
            bottomControls
        }
        .overlay(alignment: .topLeading) {
            closeButton
        }
        .overlay(alignment: .topTrailing) {
            stepIndicator
        }
        .sheet(isPresented: $showComplete) {
            BrewCompleteSheet(recipe: recipe)
        }
        .onAppear {
            if let duration = steps.first?.timerDuration, steps.first?.hasTimer == true {
                timerService.configure(duration: duration)
            }
        }
    }

    // MARK: - Bottom Controls
    private var bottomControls: some View {
        VStack(spacing: 0) {
            ProgressDotsView(total: steps.count, current: currentStepIndex)
                .padding(.bottom, 8)

            GlassEffectContainer {
                HStack(spacing: 12) {
                    Button {
                        withAnimation(.spring(duration: 0.3)) {
                            currentStepIndex = max(0, currentStepIndex - 1)
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .frame(width: 48, height: 48)
                    }
                    .glassEffect(.regular.interactive())
                    .disabled(currentStepIndex == 0)
                    .opacity(currentStepIndex == 0 ? 0.4 : 1.0)

                    Button {
                        if isLastStep {
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            showComplete = true
                        } else {
                            withAnimation(.spring(duration: 0.3)) {
                                currentStepIndex += 1
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(isLastStep ? "Finish" : "Next")
                                .fontWeight(.semibold)
                            Image(systemName: isLastStep ? "checkmark" : "chevron.right")
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                    }
                    .glassEffect(.regular.tint(Color("BrandPrimary")).interactive())
                }
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Close Button
    private var closeButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 40, height: 40)
        }
        .glassEffect(.regular.interactive())
        .padding(.top, 60)
        .padding(.leading, 16)
    }

    // MARK: - Step Indicator
    private var stepIndicator: some View {
        Text("\(currentStepIndex + 1)/\(steps.count)")
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.top, 60)
            .padding(.trailing, 16)
    }
}
