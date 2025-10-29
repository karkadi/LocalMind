//
//  SideBarReducer.swift
//  LocalMind
//
//  Created by Arkadiy KAZAZYAN on 21/10/2025.
//

import SwiftUI
import ComposableArchitecture
import Foundation
import SQLiteData

/// `SideBarReducer` is responsible for managing the state and actions related to the application's sidebar UI component.
///
/// Typical responsibilities of a sidebar reducer include:
/// - Handling the selection and highlighting of sidebar items.
/// - Managing the expansion or collapse of sidebar sections or groups.
/// - Responding to user interactions, such as item selection or context menu actions.
/// - Synchronizing sidebar state with underlying data models or navigation flows.
///
/// In a composable architecture context, `SideBarReducer` typically defines:
/// - The state struct representing sidebar-specific data (selected item, expanded groups, etc.).
/// - The actions enum representing all possible sidebar events (user and system-driven).
/// - The reducer function that describes how actions transform state, possibly emitting effects (such as navigation).
///
/// `SideBarReducer` may also coordinate with child reducers or features for complex sidebar hierarchies.
///
/// Example use cases:
/// - Navigating between sections of an app from the sidebar.
/// - Displaying and updating badges or indicators on sidebar items.
/// - Persisting sidebar state across app launches or user sessions.
///
/// Usage:
/// Integrate `SideBarReducer` into your main app reducer, providing it with the necessary state and actions.
/// Connect it to your sidebar SwiftUI views or AppKit components to drive the UI reactively.
@Reducer
struct SideBarReducer {
    @Dependency(\.databaseClient) private var databaseClient
    
    @ObservableState
    struct State {
        var sessions: [ChatSession] = []
        var isLoading = false
        var selectedSessionID: UUID?
        @Presents var alert: AlertState<Action>?
        @Presents var renameDialog: RenameDialogReducer.State?
    }
    
    enum Action: Sendable, ViewAction, BindableAction {
        case binding(BindingAction<State>)
        case view(View)
        // swiftlint:disable nesting
        public enum View {
            case onAppear
            case deleteSession(IndexSet)
            case selectSession(UUID)
            case dismissRenameDialog
            case fetchAllSessions
            case renameButtonTapped(ChatSession)
        }
        // swiftlint:enable nesting
        case selectSession(ChatSession)
        case sessionsResponse(Result<[ChatSession], Error>)
        case alert(PresentationAction<Action>)
        case renameDialog(PresentationAction<RenameDialogReducer.Action>)
    }
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce(core)
        // 🔤 Attach rename dialog reducer
            .ifLet(\.$renameDialog, action: \.renameDialog) {
                RenameDialogReducer()
            }
    }
    
    // MARK: - Reducer
    private func core(
        _ state: inout State,
        _ action: Action
    ) -> Effect<Action> {
        switch action {
        case .binding:
            return .none
            
        case let .view(viewAction):
            return viewActions(&state, viewAction)
            
            // Handle fetch result
        case let .sessionsResponse(.success(sessions)):
            state.isLoading = false
            state.sessions = sessions.sorted(by: { $0.timestamp > $1.timestamp })
            return .none
            
        case let .sessionsResponse(.failure(error)):
            state.isLoading = false
            state.alert = AlertState(title: { TextState("Failed to load sessions: \(error.localizedDescription)") })
            return .none
            
            // Alert actions
        case .alert(.presented(let action)):
            return .send(action)
            
        case .alert(.dismiss):
            state.alert = nil
            return .none
            
            // Rename dialog actions
        case let .renameDialog(.presented(.confirmRename(newTitle))):
            guard let dialog = state.renameDialog else { return .none }
            state.renameDialog = nil
            return .run { [session = dialog.session] send in
                var updated = session
                updated.title = newTitle
                updated.timestamp = .now
                try await databaseClient.updateSession(updated)
                let sessions = try await databaseClient.fetchAllSessions()
                await send(.sessionsResponse(.success(sessions)), animation: .easeInOut)
            }
            
        case .renameDialog(.presented(.cancel)):
            state.renameDialog = nil
            return .none
            
        case .renameDialog, .selectSession:
            return .none
        }
    }
    
    // MARK: - View Actions
    private func viewActions(
        _ state: inout State,
        _ viewAction: Action.View
    ) -> Effect<Action> {
        
        switch viewAction {
        case .onAppear:
            // Load all sessions on appear
            state.isLoading = true
            return .run { send in
                do {
                    let sessions = try await databaseClient.fetchAllSessions()
                    await send(.sessionsResponse(.success(sessions)))
                } catch {
                    await send(.sessionsResponse(.failure(error)))
                }
            }
            // Create a new session
        case .fetchAllSessions:
            return .run { send in
                let sessions = try await databaseClient.fetchAllSessions()
                await send(.sessionsResponse(.success(sessions)), animation: .spring())
            }
            
            // Delete session
        case let .deleteSession(indexSet):
            let idsToDelete = indexSet.map { state.sessions[$0].id }
            return .run { send in
                for id in idsToDelete {
                    try await databaseClient.deleteSession(id)
                }
                let sessions = try await databaseClient.fetchAllSessions()
                await send(.sessionsResponse(.success(sessions)), animation: .easeInOut)
            }
            
            // Select session
        case let .selectSession(id):
            state.selectedSessionID = id
            if let section = state.sessions.first(where: { id == $0.id }) {
                return .send(.selectSession(section))
            }
            return .none
            
        case let .renameButtonTapped(session):
            state.renameDialog = RenameDialogReducer.State(session: session)
            return .none
            
        case .dismissRenameDialog:
            state.renameDialog = nil
            return .none
        }
    }
}
