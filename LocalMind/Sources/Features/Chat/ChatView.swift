//
//  ChatView.swift
//  LocalMind
//
//  Created by Arkadiy KAZAZYAN on 20/06/2025.
//

import SwiftUI
import ComposableArchitecture

/// A SwiftUI view that serves as the main interface for the chat feature.
///
/// `ChatView` displays a scrollable list of messages and a floating input field for user interaction.
/// It is designed to work with the Composable Architecture, binding to a `StoreOf<ChatReducer>`.
/// The view handles message display, smooth auto-scrolling, and user input submission,
/// as well as responding to state changes such as loading or error states.
///
/// Features:
/// - Displays chat messages in a scrollable view, with smooth auto-scrolling to the latest message.
/// - Provides a floating text input field for entering and sending messages.
/// - Disables the input field and provides a stop button when a response is in progress.
/// - Includes toolbar buttons for resetting the conversation and opening settings.
/// - Presents a customizable settings view and errors as alerts.
/// - Adapts layout for various Apple platforms, using platform-appropriate navigation and toolbar elements.
///
/// The view expects the following from its store:
/// - A list of messages to display.
/// - Input text for the message field.
/// - State indicating if a response is in progress.
/// - Actions for sending/stopping input, resetting conversation, showing settings, and dismissing alerts/settings.
@ViewAction(for: ChatReducer.self)
struct ChatView: View {
    @Bindable var store: StoreOf<ChatReducer>
    
    var body: some View {
        ZStack {
            // Chat Messages ScrollView
            ScrollViewReader { proxy in
                ScrollView {
                    VStack {
                        ForEach(store.messages) { message in
                            MessageView(message: message, isResponding: store.isResponding)
                                .id(message.id)
                        }
                    }
                    .padding()
                    .padding(.bottom, 90) // Space for floating input field
                }
                .onChange(of: store.messages.last?.text) {
                    if let lastMessage = store.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onTapGesture {
                    #if os(iOS)
                    UIApplication.shared.endEditing()
                    #endif
                }
            }
            
            // Floating Input Field
            VStack {
                Spacer()
                inputField
                    .padding(20)
            }
        }
        .navigationTitle("Chat")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .toolbar { toolbarContent() }
        .sheet(
            item: $store.scope(state: \.settings, action: \.settings),
            onDismiss: { send(.settingsDismissed) },
            content: { settingsStore in
                SettingsView(store: settingsStore)
            }
        )
        .alert($store.scope(state: \.alert, action: \.alert))        
    }
    
    private var inputField: some View {
        ZStack {
            TextField("Ask anything",
                      text: $store.inputText,
                      axis: .vertical
            )
            .textFieldStyle(.plain)
            .lineLimit(1...5)
            .frame(minHeight: 22)
            .disabled(store.isResponding)
            .onSubmit {
                if !store.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    send(.sendOrStopButtonTapped)
                }
            }
            .padding(16)
            
            HStack {
                Spacer()
                Button(action: { send(.sendOrStopButtonTapped) }, label: {
                    Image(systemName: store.isResponding ? "stop.circle.fill" : "arrow.up.circle.fill")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(isSendButtonDisabled ? Color.gray.opacity(0.6) : .primary)
                })
                .disabled(isSendButtonDisabled)
                .animation(.easeInOut(duration: 0.2), value: store.isResponding)
                .animation(.easeInOut(duration: 0.2), value: isSendButtonDisabled)
                .glassEffect(.regular.interactive())
                .padding(.trailing, 8)
            }
        }
        .glassEffect(.regular.interactive())
    }
    
    private var isSendButtonDisabled: Bool {
        store.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !store.isResponding
    }
    
    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
#if os(iOS)
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: { send(.resetConversation) }, label: {
                Label("New Chat", systemImage: "square.and.pencil")
            })
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: { send(.showSettings) }, label: {
                Label("Settings", systemImage: "gearshape")
            })
        }
#else
        ToolbarItem {
            Button(action: { send(.resetConversation) }, label: {
                Label("New Chat", systemImage: "square.and.pencil")
            })
        }
        ToolbarItem {
            Button(action: { send(.showSettings) }, label: {
                Label("Settings", systemImage: "gearshape")
            })
        }
#endif
    }
}

#Preview {
    ChatView(store: Store(
        initialState: ChatReducer.State(),
        reducer: { ChatReducer() }
    ))
}
