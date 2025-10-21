//
//  LocalMindApp.swift
//  LocalMind
//
//  Created by Arkadiy KAZAZYAN on 19/10/2025.
//

import SwiftUI
import ComposableArchitecture

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
