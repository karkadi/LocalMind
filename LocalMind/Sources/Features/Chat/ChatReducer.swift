//
//  ChatReducer.swift
//  LocalMind
//
//  Created by Arkadiy KAZAZYAN on 27/05/2025.
//
import SwiftUI
import Foundation
import ComposableArchitecture
import FoundationModels

// MARK: - Feature

/// `ChatReducer` is a reducer that manages the state and actions for a chat interface using a language model.
///
/// This feature manages the full chat experience, including sending and receiving messages, interacting with a language model session,
/// handling streaming and non-streaming responses, displaying alerts, and navigating to settings.
///
/// - State:
///   - `messages`: The list of chat messages (user and assistant).
///   - `inputText`: The current user input in the text field.
///   - `isResponding`: Indicates if the assistant is currently responding.
///   - `session`: The current language model session, if one exists.
///   - `settings`: The state for presenting the settings feature.
///   - `alert`: The state for showing an error alert.
///
/// - Actions:
///   - Handles input changes, sending and stopping messages, resetting the chat, showing errors, and managing settings and alerts.
///   - Manages asynchronous communication with the language model via `.sendMessage`, supporting both streaming and non-streaming responses.
///
/// - Dependencies:
///   - `settingsClient`: Provides access to chat-related settings.
///   - `chatClient`: Interfaces with the language model and manages sessions.
///   - `continuousClock`: Used for time-based operations (if any).
///
/// - Integration:
///   - Uses Composable Architecture's `.ifLet` to integrate with the `SettingsReducer`.
///   - Presents alerts for error handling and manages navigation to settings.
@Reducer
struct ChatReducer {
    @Dependency(\.chatClient) private var chatClient
    @Dependency(\.continuousClock) private var clock
    @Dependency(\.databaseClient) private var databaseClient
    
    @ObservableState
    struct State {
        @Shared(.appStorage("useStreaming")) var useStreaming: Bool = true
        @Shared(.appStorage("temperature")) var temperature: Double = 0.7
        @Shared(.appStorage("systemInstructions")) var systemInstructions: String = "You are a helpful assistant."
        
        var messages: [ChatMessage] = []
        var inputText: String = ""
        var isResponding: Bool = false
        var session: LanguageModelSession?
        var selectedSession: ChatSession?
        @Presents var settings: SettingsReducer.State?
        @Presents var alert: AlertState<Action>?
    }
    
    enum Action: Sendable, ViewAction, BindableAction {
        case binding(BindingAction<State>)
        case sendMessage
        case appendMessage(ChatMessage)
        case setMessages([ChatMessage])
        case streamResponse(TaskResult<String>)
        case nonStreamingResponse(TaskResult<String>)
        case updateLastMessage(String)
        case setInputPrompt(String)
        case checkModelAvailability
        case didUpdateSession
        case selectSession(ChatSession)
        case showError(String)
        case assignSession(LanguageModelSession)
        case settings(PresentationAction<SettingsReducer.Action>)
        case alert(PresentationAction<Action>)
        case view(View)
        // swiftlint:disable nesting
        public enum View {
            case showSettings
            case settingsDismissed
            case sendOrStopButtonTapped
            case resetConversation
            case stopStreaming
        }
        // swiftlint:enable nesting
    }
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce(core)
            .ifLet(\.$settings, action: \.settings) {
                SettingsReducer()
            }
        // ._printChanges()
    }
    
    // MARK: - Reducer
    // swiftlint:disable cyclomatic_complexity
    private func core(
        _ state: inout State,
        _ action: Action
    ) -> Effect<Action> {
        switch action {
        case .binding:
            return .none
            
        case let .selectSession(session):
            state.selectedSession = session
            state.messages.removeAll()
            state.session = nil
            state.isResponding = false
            return .run { [ systemInstructions = state.systemInstructions] send in
                do {
                    // load to Language model
                    let messages = try await databaseClient.fetchAllMessages(session.id)
                    await send(.setMessages(messages))
                    
                    let previousUserMessages = messages
                        .filter { $0.role == .user }
                        .flatMap { $0.text + "\n"}
                    
                    let currentSession = try await chatClient.createSession(systemInstructions +
                                                                            "\n This is the previous messages, we have talking about:\n" +
                                                                            previousUserMessages)
                    await send(.assignSession(currentSession), animation: .default)
                    
                } catch {
                    await send(.showError("Session could not be created: \(error.localizedDescription)"))
                    return
                }
            }
            
        case let .setMessages(messages):
            state.messages = messages
            return .none
            
        case let .view(viewAction):
            return viewActions(&state, viewAction)
            
        case .alert(.presented(let action)):
            return .send(action)
            
        case .alert(.dismiss):
            state.alert = nil
            return .none
            
        case .settings, .didUpdateSession:
            return .none
            
        case .checkModelAvailability:
            if !chatClient.isModelAvailable() {
                state.alert = AlertState.withErrorMessage("The language model is not available. Reason: " +
                                                          chatClient.availabilityDescription(SystemLanguageModel.default.availability))
                return .none
            }
            return .send(.sendMessage)
            
        case let .assignSession(session):
            state.session = session
            return .none
            
        case let .setInputPrompt(prompt):
            state.inputText = prompt
            return .none
            
        case let .appendMessage(message):
            state.messages.append(message)
            return .run { _ in
                try await databaseClient.createMessage(message)
            }
            
        case .sendMessage:
            return sendMessage(&state)
            
        case let .updateLastMessage(text):
            state.messages[state.messages.count - 1].text = text
            return .run { [message = state.messages[state.messages.count - 1]] _ in
                try await databaseClient.updateMessage(message)
            }
            
        case .streamResponse(.success(let text)):
            return .send(.updateLastMessage(text))
            
        case .streamResponse(.failure(let error)):
            return .send(.showError("An error occurred: \(error.localizedDescription)"))
            
        case .nonStreamingResponse(.success(let text)):
            return .send(.updateLastMessage(text))
            
        case .nonStreamingResponse(.failure(let error)):
            return .send(.showError("An error occurred: \(error.localizedDescription)"))
            
        case .showError(let errorMessage):
            state.isResponding = false
            state.alert = AlertState.withErrorMessage(errorMessage)
            return .none
        }
    }
    // swiftlint:enable cyclomatic_complexity
    
    private func sendMessage(
        _ state: inout State
    ) -> Effect<Action> {
        state.isResponding = true
        // swiftlint:disable closure_parameter_position
        return .run { [ prompt = state.inputText,
                        session = state.session,
                        selectedSession = state.selectedSession,
                        systemInstructions = state.systemInstructions,
                        useStreaming = state.useStreaming,
                        temperature = state.temperature] send in
            // swiftlint:enable closure_parameter_position
            var currentSession = session
            if currentSession == nil {
                do {
                    currentSession = try await chatClient.createSession(systemInstructions)
                    await send(.assignSession(currentSession!), animation: .default)
                } catch {
                    await send(.showError("Session could not be created: \(error.localizedDescription)"))
                    return
                }
            }
            let sqlSession: ChatSession = selectedSession ?? ChatSession(id: UUID(),
                                                                         timestamp: .now,
                                                                         title: prompt)
            
            try await databaseClient.updateSession(sqlSession)
            await send(.didUpdateSession)
            
            await send(.appendMessage(ChatMessage(id: UUID(),
                                                  timestamp: Date(),
                                                  text: prompt,
                                                  role: .user,
                                                  chatSessionID: sqlSession.id)))
            
            await send(.appendMessage(ChatMessage(id: UUID(),
                                                  timestamp: Date(),
                                                  text: "",
                                                  role: .assistant,
                                                  chatSessionID: sqlSession.id)))
            
            await send(.setInputPrompt(""))
            
            let options = GenerationOptions(temperature: temperature)
            if useStreaming {
                let stream = await chatClient.streamResponse(currentSession!, prompt, options)
                do {
                    for try await partialResponse in stream {
                        await send(.updateLastMessage(partialResponse.content), animation: .default)
#if os(iOS)
                        await UISelectionFeedbackGenerator().selectionChanged()
#endif
                    }
                    await send(.view(.stopStreaming))
                } catch {
                    if error is CancellationError {
                        await send(.view(.stopStreaming))
                    } else {
                        await send(.showError("An error occurred: \(error.localizedDescription)"))
                    }
                }
            } else {
                do {
                    let response = try await chatClient.respond(currentSession!, prompt, options)
                    await send(.updateLastMessage(response), animation: .default)
                    await send(.view(.stopStreaming))
                } catch {
                    if error is CancellationError {
                        await send(.view(.stopStreaming))
                    } else {
                        await send(.showError("An error occurred: \(error.localizedDescription)"))
                    }
                }
            }
        }
    }
    
    // MARK: - View Actions
    private func viewActions(
        _ state: inout State,
        _ viewAction: Action.View
    ) -> Effect<Action> {
        switch viewAction {
        case .sendOrStopButtonTapped:
            if state.isResponding {
                return .send(.view(.stopStreaming))
            } else {
                return .send(.checkModelAvailability)
            }
            
        case .resetConversation:
            state.messages.removeAll()
            state.session = nil
            state.isResponding = false
            return .none
            
        case .showSettings:
            state.settings = SettingsReducer.State()
            return .none
            
        case .settingsDismissed:
            state.session = nil // Reset session on settings change
            return .none
            
        case .stopStreaming:
            state.isResponding = false
            return .none
        }
    }
}

// MARK: Alerts

extension AlertState where Action == ChatReducer.Action {
    static func withErrorMessage(_ errorMessage: String) -> AlertState {
        AlertState {
            TextState("Error")
        } message: {
            TextState(errorMessage)
        }
    }
}
