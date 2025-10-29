//
//  SettingsReducer.swift
//  LocalMind
//
//  Created by Arkadiy KAZAZYAN on 20/06/2025.
//
import ComposableArchitecture
import SwiftUI

/// A reducer responsible for managing the state and actions in the Settings screen.
///
/// `SettingsReducer` uses the Composable Architecture to handle all side effects and
/// state updates related to user settings, which include:
/// - Whether streaming is enabled (`useStreaming`)
/// - The temperature value for responses (`temperature`)
/// - Custom system instructions (`systemInstructions`)
///
/// Actions supported:
/// - Toggling streaming
/// - Changing temperature
/// - Editing system instructions
/// - Tapping the "Done" button to dismiss the settings
/// - Loading settings on appear
///
/// This reducer interacts with a dependency-injected `settingsClient` for persisting
/// and retrieving values, and uses a `dismiss` dependency to close the settings view.
///
/// Intended for use in SwiftUI navigation flows with state passed using TCA patterns.
@Reducer
struct SettingsReducer {
    @ObservableState
    struct State: Equatable {
        @Shared(.appStorage("useStreaming")) var useStreaming: Bool = true
        @Shared(.appStorage("temperature")) var temperature: Double = 0.7
        @Shared(.appStorage("systemInstructions")) var systemInstructions: String = "You are a helpful assistant."
    }
    
    enum Action {
        case useStreamingToggled(Bool)
        case temperatureChanged(Double)
        case systemInstructionsChanged(String)
        case doneButtonTapped
        case onAppear
    }
  
    @Dependency(\.dismiss) var dismiss
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case let .useStreamingToggled(value):
                state.$useStreaming.withLock { $0 = value }
                return .none
                
            case let .temperatureChanged(value):
                state.$temperature.withLock { $0 = value }
                return .none
                
            case let .systemInstructionsChanged(value):
                state.$systemInstructions.withLock { $0 = value }
                return .none
                
            case .doneButtonTapped:
                return .run { _ in
                    await self.dismiss()
                }
            }
        }
    }
}
