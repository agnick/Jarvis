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
            ZStack {
                Text(viewModel.currentTimerType.rawValue)
                    .font(.system(size: 36, weight: .medium))

//                HStack {
//                    Spacer()
//                    
//                    Button(action: {
//                    }) {
//                        Image(systemName: "gearshape.fill")
//                            .font(.system(size: 24))
//                    }
//                    .padding(10)
//                    .buttonStyle(.plain)
//                    .frame(width: 24, height: 24)
//                }
            }

            CircleCounter

            TimerSelector

            TimePicker

            ControlButtons
        }
        .padding(20)
        .frame(minWidth: 592, maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    // MARK: - Private Properties

    @StateObject private var viewModel: ViewModel

    // MARK: - Views

    private var CircleCounter: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: Constants.strokeWidth)
            Circle()
                .trim(from: 0, to: viewModel.progress)
                .stroke(
                    style:
                        StrokeStyle(
                            lineWidth: Constants.strokeWidth,
                            lineCap: .round
                        )
                )
                .foregroundStyle(.blue)
                .rotationEffect(.degrees(-90))
            VStack {
                Spacer(minLength: 80)
                Text(viewModel.timeString)
                    .font(.system(size: 64, weight: .medium, design: .rounded))
                Text(viewModel.connectedTask?.title ?? "")
                    .font(.system(size: 24, weight: .regular))
                Spacer()
                Button(action: {
                    if viewModel.isPaused {
                        viewModel.start()
                    } else {
                        viewModel.pause()
                    }
                }) {
                    Image(systemName: viewModel.isPaused ? "play.fill" : "pause.fill")
                        .font(.system(size: 36))
                }
                .buttonStyle(.plain)
                .frame(width: 72, height: 72)
                Spacer()
            }
        }
        .frame(width: 400, height: 300)
    }

    private var TimerSelector: some View {
        HStack {
            Button(action: {
                viewModel.currentTimerType = .focus
            }) {
                Image(systemName: "target")
                    .font(.system(size: 36))
            }
            .foregroundStyle(viewModel.currentTimerType == .focus ? .purple : .gray)
            .buttonStyle(.plain)
            .frame(width: 72, height: 72)

            Button(action: {
                viewModel.currentTimerType = .rest
            }) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 36))
            }
            .foregroundStyle(viewModel.currentTimerType == .rest ? .green : .gray)
            .buttonStyle(.plain)
            .frame(width: 72, height: 72)

            Button(action: {
                viewModel.currentTimerType = .longRest
            }) {
                Image(systemName: "zzz")
                    .font(.system(size: 36))
            }
            .foregroundStyle(viewModel.currentTimerType == .longRest ? .blue : .gray)
            .buttonStyle(.plain)
            .frame(width: 72, height: 72)
        }
    }

    private var TimePicker: some View {
        HStack {
            Button(action: {
                viewModel.currentTimerLength = max(viewModel.currentTimerLength - 5 * 60, 5 * 60)
                print(viewModel.currentTimerLength)
            }) {
                Image(systemName: "minus")
                    .font(.system(size: 36))
            }
            .buttonStyle(.plain)
            .frame(width: 72, height: 72)

            VStack {
                Text("\(Int(viewModel.currentTimerLength / 60))")
                    .font(.system(size: 48, weight: .medium))
                Text("min")
                    .font(.system(size: 24))
            }
            Button(action: {
                viewModel.currentTimerLength = min(viewModel.currentTimerLength + 5 * 60, 100 * 60)
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 36))
            }
            .buttonStyle(.plain)
            .frame(width: 72, height: 72)
        }
    }

    private var ControlButtons: some View {
        HStack {
            Button(action: {
                viewModel.reset()
            }) {
                Image(systemName: "arrow.trianglehead.counterclockwise")
                    .font(.system(size: 36))
            }
            .buttonStyle(.plain)
            .frame(width: 72, height: 72)

            Button(action: {
                viewModel.next()
            }) {
                Image(systemName: "forward.fill")
                    .font(.system(size: 36))
            }
            .buttonStyle(.plain)
            .frame(width: 72, height: 72)

            Button(action: {
                viewModel.finish()
            }) {
                Image(systemName: "flag.pattern.checkered")
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
