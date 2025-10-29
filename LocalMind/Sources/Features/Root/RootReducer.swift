//
//  RootReducer.swift
//  LocalMind
//
//  Created by Arkadiy KAZAZYAN on 22/10/2025.
//

import ComposableArchitecture
import Foundation
import SwiftUI

/// A client responsible for providing information about the current device.
///
/// `DeviceInfoClient` offers properties and methods to retrieve relevant device
/// details, such as system version, model, unique identifiers, and other hardware
/// or software characteristics. This can be used for analytics, diagnostics,
/// feature gating, or tailoring behavior based on device capabilities.
///
/// Typical usage includes querying properties like:
/// - Device model name
/// - System name and version
/// - Device identifier (if available)
/// - Hardware capabilities (e.g., camera availability, biometric support)
///
/// All data access should respect user privacy and platform-specific guidelines.
///
/// - Note: The specific properties and methods available depend on the platform
///   (iOS, macOS, watchOS, visionOS, etc.) and the implementation details of this client.
///
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
