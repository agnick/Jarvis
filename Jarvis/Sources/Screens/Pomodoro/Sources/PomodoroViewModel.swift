//
//  PomodoroViewModel.swift
//  Jarvis
//
//  Created by тимур on 04.11.2025.
//
import SwiftUI
import Foundation

@MainActor
protocol PomodoroViewModel: ObservableObject {
    var progress: Double { get }
    var timeString: String { get }
    var currentTimerType: PomodoroTimerType { get set }
    var currentTimerLength: TimeInterval { get set }
    var connectedTask: TaskItem? { get }
    var isPaused: Bool { get }
    
    func start()
    func pause()
    func reset()
}

final class PomodoroViewModelImpl: PomodoroViewModel {

    // MARK: - Published Properties
    
    @Published var currentTimerType: PomodoroTimerType {
        didSet {
            currentTimerLength = settings.getDuration(for: currentTimerType)
            currentTime = currentTimerLength
            reset()
        }
    }
    @Published var currentTimerLength: TimeInterval = 0 {
        didSet {
            settings.updateDuration(for: currentTimerType, value: currentTimerLength)
            settingsSource.saveSettings(settings)
            currentTime = currentTimerLength
            reset()
        }
    }
    @Published var currentTime: TimeInterval = 0
    @Published var connectedTask: TaskItem?
    
    @Published private var settings: PomodoroTimerSettings
    @Published var isPaused: Bool = true
    
    // MARK: - Computed Properties
    
    var progress: Double {
        Double(currentTime) / Double(currentTimerLength)
    }
    
    var timeString: String {
        let minutesLeft = Int(currentTime / 60)
        let secondsLeft = Int(currentTime.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", minutesLeft, secondsLeft)
    }
    
    // MARK: - Private Properties
    
    private var timer: Timer?
    private let settingsSource: PomodoroSettingsLocalDataSource

    // MARK: - Init
    
    init(settingsSource: PomodoroSettingsLocalDataSource) {
        self.settingsSource = settingsSource
        let loadedSettings = settingsSource.fetchSettings() ?? PomodoroTimerSettings()
        self.settings = loadedSettings
        self.currentTimerType = .focus
    }
    
    // MARK: - Public Methods
    
    func start() {
        timer?.invalidate()
        isPaused = false
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                if self.currentTime > 0 {
                    self.currentTime -= 1
                } else {
                    self.timer?.invalidate()
                    self.isPaused = true
                    self.currentTime = self.currentTimerLength
                }
            }
        }
    }
    
    func pause() {
        timer?.invalidate()
        isPaused = true
    }
    
    func reset() {
        timer?.invalidate()
        currentTime = currentTimerLength
        isPaused = true
    }
    
    deinit {
        timer?.invalidate()
    }
}

enum PomodoroTimerType: String {
    case focus = "Focus"
    case rest = "Rest"
    case longRest = "Long Rest"
}
