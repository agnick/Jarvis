//
//  PomodoroView.swift
//  Jarvis
//
//  Created by тимур on 04.11.2025.
//

import SwiftUI

struct PomodoroView<ViewModel: PomodoroViewModel>: View {

    // MARK: - Init

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        VStack {
            CircleCounter
            TimerSelector
            TimePicker
        }
        .padding(40)
        .onAppear {
            viewModel.startTimer()
        }
    }

    // MARK: - Private Properties

    @StateObject private var viewModel: ViewModel

    // MARK: - Views

    private var CircleCounter: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: Constants.strokeWidth)
            Circle()
                .trim(from: 0, to: viewModel.timerProgress)
                .stroke(
                    style:
                        StrokeStyle(
                            lineWidth: Constants.strokeWidth,
                            lineCap: .round
                        )
                )
                .rotationEffect(.degrees(-90))
            VStack {
                Spacer(minLength: 80)
                Text(viewModel.timeString)
                    .font(.system(size: 64, weight: .medium, design: .rounded))
                Text("Do the dishes")
                    .font(.system(size: 24, weight: .regular))
                Spacer()
                Button(action: {}) {
                    Image(systemName: "pause.fill")
                        .font(.system(size: 36))
                }
                .buttonStyle(.plain)
                .frame(width: 72, height: 72)
                Spacer()
            }
        }
        .frame(width: 400, height: 300)
        .padding(20)
    }

    private var TimerSelector: some View {
        HStack {
            Button(action: {}) {
                Image(systemName: "target")
                    .font(.system(size: 36))
            }
            .buttonStyle(.plain)
            .frame(width: 72, height: 72)

            Button(action: {}) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 36))
            }
            .buttonStyle(.plain)
            .frame(width: 72, height: 72)

            Button(action: {}) {
                Image(systemName: "zzz")
                    .font(.system(size: 36))
            }
            .buttonStyle(.plain)
            .frame(width: 72, height: 72)
        }
    }

    private var TimePicker: some View {
        HStack {
            Button(action: {}) {
                Image(systemName: "minus")
                    .font(.system(size: 36))
            }
            .buttonStyle(.plain)
            .frame(width: 72, height: 72)

            VStack {
                Text("35")
                    .font(.system(size: 48, weight: .medium))
                Text("min")
                    .font(.system(size: 24))
            }
            Button(action: {}) {
                Image(systemName: "plus")
                    .font(.system(size: 36))
            }
            .buttonStyle(.plain)
            .frame(width: 72, height: 72)
        }
    }
}

fileprivate enum Constants {
    static let strokeWidth: CGFloat = 12
}

#Preview {
    PomodoroView(viewModel: PomodoroViewModelImpl())
}
