//
//  PomodoroViewModel.swift
//  Jarvis
//
//  Created by тимур on 04.11.2025.
//
import SwiftUI

@MainActor
protocol PomodoroViewModel: ObservableObject {
    var timeString: String { get }
    var timerProgress: Double { get }
    var currentTimerType: PomodoroTimerType { get set }
    var currentTask: TaskItem? { get }
    func startTimer()
}

enum PomodoroTimerType {
    case focus
    case rest
    case longRest
}

final class PomodoroViewModelImpl: PomodoroViewModel {
    @Published var secondsRemaining: Int = 30
    @Published var timeString: String = "25:00"
    @Published var currentTimerType: PomodoroTimerType = .focus
    @Published var currentTask: TaskItem? = nil

    var timerProgress: Double {
        max(0, min(1, Double(secondsRemaining) / 30))
    }

    private var timer: Timer?
    
    func startTimer() {
        timer?.invalidate()
        updateTimeString()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                if self.secondsRemaining > 0 {
                    self.secondsRemaining -= 1
                    self.updateTimeString()
                } else {
                    self.timer?.invalidate()
                    self.timer = nil
                }
            }
        }
    }
    
    private func updateTimeString() {
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        timeString = String(format: "%02d:%02d", minutes, seconds)
    }
}

