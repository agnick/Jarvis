import Foundation
import SwiftData

@Model
final class PomodoroTimerSettings {
    var focusDuration: TimeInterval
    var restDuration: TimeInterval
    var longRestDuration: TimeInterval
    var roundsBeforeLongRest: Int
    
    init(focusDuration: TimeInterval = 25 * 60,
         restDuration: TimeInterval = 5 * 60,
         longRestDuration: TimeInterval = 15 * 60,
         roundsBeforeLongRest: Int = 4) {
        self.focusDuration = focusDuration
        self.restDuration = restDuration
        self.longRestDuration = longRestDuration
        self.roundsBeforeLongRest = roundsBeforeLongRest
    }

    func getDuration(for timerType: PomodoroTimerType) -> TimeInterval {
        switch timerType {
        case .focus:
            focusDuration
        case .rest:
            restDuration
        case .longRest:
            longRestDuration
        }
    }

    func updateDuration(for timerType: PomodoroTimerType, value: TimeInterval) {
        switch timerType {
        case .focus:
            focusDuration = value
        case .rest:
            restDuration = value
        case .longRest:
            longRestDuration = value
        }
    }
}
