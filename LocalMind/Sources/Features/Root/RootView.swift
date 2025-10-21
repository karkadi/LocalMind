//
//  RootView.swift
//  LocalMind
//
//  Created by Arkadiy KAZAZYAN on 19/10/2025.
//
import SwiftUI
import ComposableArchitecture

struct RootView: View {
    @Dependency(\.deviceInfo) private var deviceInfo
    @Bindable var store: StoreOf<RootReducer>
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    var sidebarWidth: CGFloat {
        getSidebarWidth(isLandscape: isLandscape(horizontalSizeClass: horizontalSizeClass,
                                                 verticalSizeClass: verticalSizeClass))
    }
    var contentOffset: CGFloat {
        store.columnVisibility == .all ? sidebarWidth : 0
    }
    
    var body: some View {
        Group {
            if deviceInfo.shouldUseSplitView() {
                splitView
            } else {
                iPhoneView
            }
        }
    }
    
    // MARK: - Split View
    private var splitView: some View {
        NavigationSplitView(columnVisibility: $store.columnVisibility) {
            SideBarView(store: store.scope(state: \.sidebar, action: \.sidebar))
        } detail: {
            ChatView(store: store.scope(state: \.chat, action: \.chat))
        }
#if os(macOS)
        .navigationSplitViewStyle(.prominentDetail)
#else
        .navigationSplitViewStyle(.balanced)
#endif
    }
    
    // MARK: - iPhone View
    private var iPhoneView: some View {
        NavigationStack {
            ZStack(alignment: .leading) {
                SideBarView(store: store.scope(state: \.sidebar, action: \.sidebar))
                    .frame(width: sidebarWidth)
                    .offset(x: -sidebarWidth + contentOffset)
                
                ChatView(store: store.scope(state: \.chat, action: \.chat))
                    .compositingGroup()
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 2, y: 0)
                    .offset(x: contentOffset)
                    .navigationTitle("Chat")
                    .toolbar {
#if os(iOS)
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                store.send(.toggleSidebar, animation: .spring(response: 0.4, dampingFraction: 0.8))
                            } label: {
                                Image(systemName: "line.horizontal.3")
                                    .font(.title3)
                                    .foregroundColor(.primary)
                            }
                        }
#endif
                    }
                
                if store.columnVisibility == .all {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            store.send(.setColumnVisibility(.detailOnly))
                        }
                        .offset(x: contentOffset)
                }
            }
        }
    }
}

#Preview {
    RootView(
        store: Store(initialState: RootReducer.State()) {
            RootReducer()
        }
    )
}
