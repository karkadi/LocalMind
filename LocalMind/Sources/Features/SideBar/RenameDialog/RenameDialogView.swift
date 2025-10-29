//
//  RenameDialogView.swift
//  LocalMind
//
//  Created by Arkadiy KAZAZYAN on 22/10/2025.
//
import SwiftUI
import ComposableArchitecture

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
struct RenameDialogView: View {
    @Bindable var store: StoreOf<RenameDialogReducer>
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Rename Chat")
                .font(.headline)
            TextField("Title", text: $store.newTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .focused($isTextFieldFocused)
                .onAppear {
                    // Automatically focus when the sheet appears
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isTextFieldFocused = true
                    }
                }
            
            HStack {
                Button("Cancel") {
                    store.send(.cancel)
                }
                Spacer()
                Button("Save") {
                    store.send(.confirmRename(store.newTitle))
                }
                .disabled(store.newTitle.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal)
        }
        .padding()
        .presentationDetents([.fraction(0.25)])
    }
}
