//
//  RenameDialogView.swift
//  LocalMind
//
//  Created by Arkadiy KAZAZYAN on 22/10/2025.
//
import SwiftUI
import ComposableArchitecture

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
