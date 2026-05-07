import SwiftUI

struct TimerView: View {
    let timerService: TimerService
    let duration: Int
    @Environment(\.modelContext) private var modelContext
    @Namespace private var namespace

    var body: some View {
        VStack(spacing: 16) {
            Text(timerService.formattedRemaining)
                .font(.system(size: 56, weight: .bold, design: .monospaced))
                .foregroundStyle(.primary)
                .padding(.vertical, 12)

            // Controls
            GlassEffectContainer {
                HStack(spacing: 16) {
                    switch timerService.state {
                    case .idle:
                        Button {
                            timerService.configure(duration: duration)
                            timerService.start()
                        } label: {
                            Label("Start", systemImage: "play.fill")
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                        }
                        .glassEffect(.regular.tint(Color("BrandPrimary")).interactive())

                    case .running:
                        Button { timerService.pause() } label: {
                            Image(systemName: "pause.fill")
                                .frame(width: 44, height: 44)
                        }
                        .glassEffect(.regular.interactive())

                        Button { timerService.reset() } label: {
                            Image(systemName: "arrow.counterclockwise")
                                .frame(width: 44, height: 44)
                        }
                        .glassEffect(.regular.interactive())

                    case .paused:
                        Button { timerService.start() } label: {
                            Label("Resume", systemImage: "play.fill")
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                        }
                        .glassEffect(.regular.tint(Color("BrandPrimary")).interactive())

                        Button { timerService.reset() } label: {
                            Image(systemName: "arrow.counterclockwise")
                                .frame(width: 44, height: 44)
                        }
                        .glassEffect(.regular.interactive())

                    case .complete:
                        Label("Done!", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .padding()
                            .onAppear {
                                FeedbackService.shared.notification(.success, context: modelContext)
                                FeedbackService.shared.successSound(context: modelContext)
                            }
                    }
                }
            }
        }
    }
}
