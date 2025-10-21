//
//  SideBarView.swift
//  LocalMind
//
//  Created by Arkadiy KAZAZYAN on 21/10/2025.
//
import SwiftUI
import ComposableArchitecture

@ViewAction(for: SideBarReducer.self)
struct SideBarView: View {
    @Bindable var store: StoreOf<SideBarReducer>
    
    var body: some View {
        List(selection: $store.selectedSessionID ) {
            ForEach(store.sessions) { session in
                HStack {
                    Text(session.title)
                        .font(.headline)
                        .lineLimit(1)
                    Spacer()
                    Text(session.timestamp, style: .time)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    send(.selectSession(session.id))
                }
                .contextMenu {
                    Button("Rename") {
                        send(.renameButtonTapped(session))
                    }
                    Button("Delete", role: .destructive) {
                        if let index = store.sessions.firstIndex(where: { $0.id == session.id }) {
                            send(.deleteSession(IndexSet(integer: index)))
                        }
                    }
                }
                
            }
            .onDelete { indexSet in
                send(.deleteSession(indexSet))
            }
        }
        .overlay {
            if store.isLoading {
                ProgressView("Loading sessions…")
            }
        }
        .onAppear {
            send(.onAppear)
        }
        .alert($store.scope(state: \.alert, action: \.alert))
        .sheet(item: $store.scope(state: \.renameDialog, action: \.renameDialog),
               onDismiss: { send(.dismissRenameDialog) },
               content: { renameStore in
            RenameDialogView(store: renameStore)
        }
        )
    }
}

#Preview {
    SideBarView(store: Store(initialState: SideBarReducer.State(),
                             reducer: { SideBarReducer() }))
}
