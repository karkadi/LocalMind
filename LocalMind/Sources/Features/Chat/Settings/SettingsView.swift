//
//  SettingsView.swift
//  LocalMind
//
//  Created by Arkadiy KAZAZYAN on 20/06/2025.
//
import SwiftUI
import ComposableArchitecture

// MARK: - View

/// `SettingsView` is a SwiftUI view that presents a settings interface for configuring generation and system instruction options.
/// 
/// - Parameters:
///   - store: A `StoreOf<SettingsReducer>` that binds the UI to the application's settings state using the Composable Architecture.
///
/// The view displays two main sections:
/// 1. **Generation**:  
///     - A toggle to enable or disable streaming responses.
///     - A slider to adjust the "Temperature" parameter, which typically controls randomness in generative AI models.
///
/// 2. **System Instructions**:
///     - A text editor for entering or editing the instructions the system should use when generating responses.
///
/// The view includes a navigation bar with a "Done" button, which triggers an action to save or dismiss the settings.
/// It uses `NavigationStack` for navigation and adapts the navigation bar display style for iOS.
/// On appearance, an `.onAppear` action is sent to the store to trigger any necessary setup.
struct SettingsView: View {
    @Bindable var store: StoreOf<SettingsReducer>
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Generation") {
                    Toggle("Stream Responses",
                           isOn: $store.useStreaming.sending(\.useStreamingToggled)
                    )
                    VStack(alignment: .leading) {
                        Text("Temperature: \(store.temperature, specifier: "%.2f")")
                        Slider(value: $store.temperature.sending(\.temperatureChanged),
                               in: 0.0...2.0,
                               step: 0.1
                        )
                    }
                    .padding(.vertical, 4)
                }
                
                Section("System Instructions") {
                    TextEditor(text: $store.systemInstructions.sending(\.systemInstructionsChanged))
                        .frame(minHeight: 100)
                        .font(.body)
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
            .navigationTitle("Settings")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        store.send(.doneButtonTapped)
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView(
        store: Store(
            initialState: SettingsReducer.State(),
            reducer: { SettingsReducer() }
        )
    )
}
