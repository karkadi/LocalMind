//
//  RenameDialogReducer.swift
//  LocalMind
//
//  Created by Arkadiy KAZAZYAN on 22/10/2025.
//
import ComposableArchitecture
import Foundation
import SwiftUI

/// `RenameDialogReducer` is a reducer responsible for managing the state and actions
/// related to the rename dialog within the application.
///
/// This reducer coordinates the user interaction involved in renaming an item,
/// such as presenting the dialog, updating the text field, handling confirmation
/// or cancellation, and validating the input. It responds to actions dispatched
/// as the user interacts with the dialog and emits state changes or side effects
/// (such as dismissing the dialog or propagating the new name).
///
/// Typical responsibilities include:
/// - Showing or hiding the rename dialog.
/// - Tracking the current value of the rename text field.
/// - Validating the user's input (e.g., preventing empty names or duplicates).
/// - Handling confirm and cancel actions.
/// - Integrating with broader application state or effects as needed.
///
/// Use `RenameDialogReducer` in your application's reducer hierarchy
/// when you need to present and manage a modal interface for renaming items.
@Reducer
struct RenameDialogReducer {
    @ObservableState
    struct State: Equatable {
        var session: ChatSession
        var newTitle: String
        
        init(session: ChatSession) {
            self.session = session
            self.newTitle = session.title
        }
    }
    
    enum Action: Sendable, BindableAction {
        case binding(BindingAction<State>)
        case confirmRename(String)
        case cancel
    }
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce(core)
    }
    
    // MARK: - Reducer
    private func core(
        _ state: inout State,
        _ action: Action
    ) -> Effect<Action> {
        switch action {
        case .binding:
            return .none
            
        case .confirmRename:
            return .none
            
        case .cancel:
            return .none
        }
    }
}
