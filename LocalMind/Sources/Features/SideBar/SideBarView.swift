//
//  SideBarView.swift
//  LocalMind
//
//  Created by Arkadiy KAZAZYAN on 21/10/2025.
//
import SwiftUI
import ComposableArchitecture

/// A SwiftUI view representing the application's sidebar.
///
/// `SideBarView` serves as the primary navigation or organizational panel, typically positioned
/// on the side of the app's main window. It is commonly used to display lists of navigation options,
/// content categories, or quick access items.
///
/// This view is designed to integrate seamlessly with macOS and other Apple platforms supporting sidebars.
/// It can be customized to display various sections, icons, or hierarchical navigation based on app requirements.
///
/// - Important: Ensure that `SideBarView` is embedded within a suitable container such as `NavigationSplitView` or
///   similar navigation scaffolding for best results.
///
/// ### Example Usage
/// ```swift
/// NavigationSplitView {
///     SideBarView()
///     // ...
/// }
/// ```
///
/// ### Platforms
/// - macOS: Fully supported with rich sidebar behaviors.
/// - iPadOS: Supported as a collapsible navigation panel.
///
/// - Author: [Your Name or Team]
/// - Version: 1.0
///
@ViewAction(for: SideBarReducer.self)
struct SideBarView: View {
    @Bindable var store: StoreOf<SideBarReducer>
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search in messages...", text: $store.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onChange(of: store.searchText) { _, newValue in
                        send(.searchTextChanged(newValue))
                    }
                
                if store.isSearching {
                    ProgressView()
                        .scaleEffect(0.8)
                        .padding(.trailing, 4)
                } else if !store.searchText.isEmpty {
                    Button(action: {
                        send(.searchTextChanged(""))
                    }, label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    })
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(8)
            // .background(Color(.controlBackgroundColor))
            .cornerRadius(8)
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            // Sessions List
            List(selection: $store.selectedSessionID) {
                ForEach(store.searchText.isEmpty ? store.sessions : store.filteredSessions) { session in
                    SessionRowView(
                        session: session,
                        isSearchResult: !store.searchText.isEmpty && store.filteredSessions.contains(where: { $0.id == session.id }),
                        searchText: store.searchText,
                        onSelect: { send(.selectSession(session.id)) },
                        onRename: { send(.renameButtonTapped(session)) },
                        onDelete: {
                            let sessions = store.searchText.isEmpty ? store.sessions : store.filteredSessions
                            if let index = sessions.firstIndex(where: { $0.id == session.id }) {
                                send(.deleteSession(IndexSet(integer: index)))
                            }
                        }
                    )
                }
                .onDelete { indexSet in
                    send(.deleteSession(indexSet))
                }
            }
        }
        .overlay {
            if store.isLoading {
                ProgressView("Loading sessions…")
            } else if !store.searchText.isEmpty && store.filteredSessions.isEmpty && !store.isSearching {
                ContentUnavailableView.search(text: store.searchText)
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
        })
    }
}

#Preview {
    SideBarView(store: Store(initialState: SideBarReducer.State(),
                             reducer: { SideBarReducer() }))
}
