//
//  RootReducer.swift
//  LocalMind
//
//  Created by Arkadiy KAZAZYAN on 22/10/2025.
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct RootReducer {
    @Dependency(\.deviceInfo) private var deviceInfo
    
    @ObservableState
    struct State {
        var sidebar = SideBarReducer.State()
        var chat = ChatReducer.State()
        var columnVisibility: NavigationSplitViewVisibility = .detailOnly
    }
    
    enum Action: Sendable, BindableAction {
        case binding(BindingAction<State>)
        case sidebar(SideBarReducer.Action)
        case chat(ChatReducer.Action)
        case toggleSidebar
        case setColumnVisibility(NavigationSplitViewVisibility)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Scope(state: \.sidebar, action: \.sidebar) { SideBarReducer() }
        Scope(state: \.chat, action: \.chat) { ChatReducer() }
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case let .setColumnVisibility(visibility):
                state.columnVisibility = visibility
                return .none
                
            case .toggleSidebar:
                state.columnVisibility = state.columnVisibility == .all ? .detailOnly : .all
                return .none
                
            case .chat(.didUpdateSession):
                return .send(.sidebar(.view(.fetchAllSessions)))
                
            case let .sidebar(.selectSession(session)):
                let shouldUseSplitView = deviceInfo.shouldUseSplitView()
                return .run { send in
                    await send(.chat(.selectSession(session)))
                    if !shouldUseSplitView {
                        await send(.setColumnVisibility(.detailOnly),
                                   animation: .spring(response: 0.4, dampingFraction: 0.8))
                    }
                }
            case .sidebar, .chat:
                return .none
            }
        }
    }
}
