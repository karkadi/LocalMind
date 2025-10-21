//
//  RenameDialogReducer.swift
//  LocalMind
//
//  Created by Arkadiy KAZAZYAN on 22/10/2025.
//
import ComposableArchitecture
import Foundation
import SwiftUI

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
