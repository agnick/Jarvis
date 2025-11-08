//
//  PomodoroFactory.swift
//  Jarvis
//
//  Created by тимур on 07.11.2025.
//

import SwiftUI

@MainActor
protocol PomodoroFactory {
    func makePomodoroScreen() -> AnyView
}

struct PomodoroFactoryImpl: PomodoroFactory {

    // MARK: - Init

    init(swiftDataContextManager: SwiftDataContextManager) {
        self.swiftDataContextManager = swiftDataContextManager
    }

    // MARK: - Public Methods

    func makePomodoroScreen() -> AnyView {
        let viewModel = PomodoroViewModelImpl(
            settingsSource: PomodoroSettingsLocalDataSourceImpl (
                container: swiftDataContextManager.container,
                context: swiftDataContextManager.context
            )
        )
        let view = PomodoroView(viewModel: viewModel)
        return AnyView(view)
    }

    // MARK: - Private Properties

    private let swiftDataContextManager: SwiftDataContextManager
}
