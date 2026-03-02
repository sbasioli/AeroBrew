import Foundation
import Observation

enum TimerState: Equatable {
    case idle
    case running
    case paused
    case complete
}

@Observable
final class TimerService {
    private(set) var remaining: Int = 0
    private(set) var state: TimerState = .idle
    private var duration: Int = 0

    private var timer: DispatchSourceTimer?

    var progress: Double {
        guard duration > 0 else { return 0 }
        return Double(duration - remaining) / Double(duration)
    }

    var formattedRemaining: String {
        remaining.formattedTime
    }

    func configure(duration: Int) {
        cancel()
        self.duration = duration
        self.remaining = duration
        self.state = .idle
    }

    func start() {
        guard state != .complete, duration > 0 else { return }
        state = .running

        timer = DispatchSource.makeTimerSource(queue: .main)
        timer?.schedule(deadline: .now() + 1, repeating: 1.0)
        timer?.setEventHandler { [weak self] in
            guard let self else { return }
            if self.remaining <= 1 {
                self.remaining = 0
                self.state = .complete
                self.timer?.cancel()
                self.timer = nil
            } else {
                self.remaining -= 1
            }
        }
        timer?.resume()
    }

    func pause() {
        guard state == .running else { return }
        timer?.cancel()
        timer = nil
        state = .paused
    }

    func reset() {
        cancel()
        remaining = duration
        state = .idle
    }

    private func cancel() {
        timer?.cancel()
        timer = nil
    }

    deinit {
        cancel()
    }
}
