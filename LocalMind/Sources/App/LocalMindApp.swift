//
//  LocalMindApp.swift
//  LocalMind
//
//  Created by Arkadiy KAZAZYAN on 19/10/2025.
//
import SwiftUI
import ComposableArchitecture

/// `LocalMindApp` is the main entry point for the application.
///
/// This type typically conforms to the `App` protocol on Apple platforms and is responsible for configuring
/// the initial scene(s) and environment of the app. Within its body, it sets up core dependencies and the
/// root view hierarchy. The structure and configuration inside `LocalMindApp` define how the app launches,
/// what its main interface looks like, and may initialize global services used throughout the app.
///
/// # Responsibilities
/// - Defines the app's launch behavior and lifecycle.
/// - Sets up the root user interface using a scene (usually a `WindowGroup`).
/// - Initializes any shared dependencies, environment values, or state.
/// - May configure global services such as data controllers, notification handlers, or theming.
///
/// # Typical Usage
/// ```swift
/// @main
/// struct LocalMindApp: App {
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///         }
///     }
/// }
/// ```
///
/// # Notes
/// - Ensure that all global services initialized here are thread-safe and appropriate for the app's lifecycle.
/// - This is the best place to configure high-level app behaviors and global environment values.
/// - On macOS, consider using `Settings` or `Commands` for additional app-wide features.
@main
struct LocalMindApp: App {
    var body: some Scene {
        WindowGroup {
            RootView(
                store: Store(initialState: RootReducer.State()) {
                    RootReducer()
                }
            )
        }
    }
    
    init() {
        do {
            try prepareDependencies {
                try $0.bootstrapDatabase()
            }
        } catch {
            // You could log this to a logging framework, crashlytics, etc.
            print("Failed to prepare dependencies: \(error)")
            // Optionally handle the error more gracefully, e.g., by showing a UI alert
        }
    }
}
