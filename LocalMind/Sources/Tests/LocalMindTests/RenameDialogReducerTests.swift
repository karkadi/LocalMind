//
//  RenameDialogReducerTests.swift
//  LocalMind
//
//  Created by Arkadiy KAZAZYAN on 29/10/2025.
//

import Testing
import ComposableArchitecture
@testable import LocalMind
import Foundation

@MainActor @Suite("RenameDialogReducer Tests")
struct RenameDialogReducerTests {
    
    // MARK: - Test Data
    let testSession = ChatSession(
        id: UUID(),
        timestamp: Date(),
        title: "Original Title"
    )
    
    @Test("Initial state sets correct values from session")
    func initialState() {
        let state = RenameDialogReducer.State(session: testSession)
        
        #expect(state.session == testSession)
        #expect(state.newTitle == "Original Title")
    }
    
    @Test("Binding action updates newTitle")
    func bindingActionUpdatesNewTitle() async {
        let store = TestStore(
            initialState: RenameDialogReducer.State(session: testSession)
        ) {
            RenameDialogReducer()
        }
        
        let newTitle = "Updated Title"
        await store.send(.binding(.set(\.newTitle, newTitle))) {
            $0.newTitle = newTitle
        }
        
        // Test empty string
        await store.send(.binding(.set(\.newTitle, ""))) {
            $0.newTitle = ""
        }
        
        // Test with whitespace
        await store.send(.binding(.set(\.newTitle, "  Title With Spaces  "))) {
            $0.newTitle = "  Title With Spaces  "
        }
    }
    
    @Test("Binding action does not modify session")
    func bindingActionDoesNotModifySession() async {
        let store = TestStore(
            initialState: RenameDialogReducer.State(session: testSession)
        ) {
            RenameDialogReducer()
        }
        
        await store.send(.binding(.set(\.newTitle, "New Title"))) {
            $0.newTitle = "New Title"
            // Session should remain unchanged
            #expect($0.session == self.testSession)
        }
    }
    
    @Test("Confirm rename action with no side effects")
    func confirmRenameAction() async {
        // Create state with modified title
        var initialState = RenameDialogReducer.State(session: testSession)
        initialState.newTitle = "Confirmed Title"
        
        let store = TestStore(initialState: initialState) {
            RenameDialogReducer()
        }
        
        await store.send(.confirmRename("Confirmed Title"))
        // No state changes expected since the reducer returns .none
    }
    
    @Test("Confirm rename action with different titles")
    func confirmRenameWithDifferentTitles() async {
        let store = TestStore(
            initialState: RenameDialogReducer.State(session: testSession)
        ) {
            RenameDialogReducer()
        }
        
        // Test with same title as original
        await store.send(.confirmRename("Original Title"))
        
        // Test with different title
        await store.send(.confirmRename("Completely Different Title"))
        
        // Test with empty title
        await store.send(.confirmRename(""))
        
        // Test with special characters
        await store.send(.confirmRename("Title with émojis 🚀 and symbols!"))
    }
    
    @Test("Cancel action with no side effects")
    func cancelAction() async {
        // Create state with modified title
        var initialState = RenameDialogReducer.State(session: testSession)
        initialState.newTitle = "Modified Title"
        
        let store = TestStore(initialState: initialState) {
            RenameDialogReducer()
        }
        
        await store.send(.cancel)
        // No state changes expected since the reducer returns .none
    }
    
    @Test("Multiple binding updates")
    func multipleBindingUpdates() async {
        let store = TestStore(
            initialState: RenameDialogReducer.State(session: testSession)
        ) {
            RenameDialogReducer()
        }
        
        let titles = ["First", "Second", "Third", "Final"]
        
        for title in titles {
            await store.send(.binding(.set(\.newTitle, title))) {
                $0.newTitle = title
            }
        }
        
        #expect(store.state.newTitle == "Final")
    }
    
    @Test("State remains consistent after multiple actions")
    func stateConsistency() async {
        let store = TestStore(
            initialState: RenameDialogReducer.State(session: testSession)
        ) {
            RenameDialogReducer()
        }
        
        // Initial state verification
        #expect(store.state.session == testSession)
        #expect(store.state.newTitle == "Original Title")
        
        // Update title via binding
        await store.send(.binding(.set(\.newTitle, "Intermediate Title"))) {
            $0.newTitle = "Intermediate Title"
        }
        
        // Session should remain unchanged
        #expect(store.state.session == testSession)
        
        // Send cancel
        await store.send(.cancel)
        
        // State should remain the same after cancel
        #expect(store.state.newTitle == "Intermediate Title")
        #expect(store.state.session == testSession)
        
        // Send confirm
        await store.send(.confirmRename("Final Title"))
        
        // State should remain the same after confirm
        #expect(store.state.newTitle == "Intermediate Title") // Not changed by confirm
        #expect(store.state.session == testSession)
    }
    
    @Test("Reducer handles all action cases")
    func reducerActionCoverage() async {
        let store = TestStore(
            initialState: RenameDialogReducer.State(session: testSession)
        ) {
            RenameDialogReducer()
        }
        
        // Test binding action
        await store.send(.binding(.set(\.newTitle, "Test"))) {
            $0.newTitle = "Test"
        }
        
        // Test confirm action
        await store.send(.confirmRename("Confirmed"))
        
        // Test cancel action
        await store.send(.cancel)
    }
    
    @Test("State is equatable")
    func stateEquatable() {
        let session1 = ChatSession(id: UUID(), timestamp: Date(), title: "Session 1")
        let session2 = ChatSession(id: UUID(), timestamp: Date(), title: "Session 2")
        
        let state1 = RenameDialogReducer.State(session: session1)
        let state2 = RenameDialogReducer.State(session: session1)
        let state3 = RenameDialogReducer.State(session: session2)
        
        // Same session and default title should be equal
        #expect(state1 == state2)
        
        // Different sessions should not be equal
        #expect(state1 != state3)
        
        // Modified title should not be equal
        var state4 = RenameDialogReducer.State(session: session1)
        state4.newTitle = "Different Title"
        #expect(state1 != state4)
    }
    
    @Test("Initializer sets correct default values")
    func initializerSetsCorrectDefaults() {
        let sessions = [
            ChatSession(id: UUID(), timestamp: Date(), title: "Short"),
            ChatSession(id: UUID(), timestamp: Date(), title: "Very Long Title That Might Be Truncated"),
            ChatSession(id: UUID(), timestamp: Date(), title: ""),
            ChatSession(id: UUID(), timestamp: Date(), title: "Title with 😊 emoji")
        ]
        
        for session in sessions {
            let state = RenameDialogReducer.State(session: session)
            #expect(state.session == session)
            #expect(state.newTitle == session.title)
        }
    }
    
    @Test("Binding reducer integration")
    func bindingReducerIntegration() async {
        let store = TestStore(
            initialState: RenameDialogReducer.State(session: testSession)
        ) {
            RenameDialogReducer()
        }
        
        // Test that BindingReducer properly handles state updates
        await store.send(.binding(.set(\.newTitle, "Bound Title"))) {
            $0.newTitle = "Bound Title"
        }
        
        // Verify the state was actually updated
        #expect(store.state.newTitle == "Bound Title")
    }
    
    @Test("No effects returned from any actions")
    func noEffectsReturned() async {
        let store = TestStore(
            initialState: RenameDialogReducer.State(session: testSession)
        ) {
            RenameDialogReducer()
        }
        
        // All actions should return .none
        await store.send(.binding(.set(\.newTitle, "Test"))) {
            $0.newTitle = "Test"
        }
        
        await store.send(.confirmRename("Test"))
        await store.send(.cancel)
    }
    
    @Test("Confirm rename with mismatched title parameter")
    func confirmRenameWithMismatchedTitle() async {
        var initialState = RenameDialogReducer.State(session: testSession)
        initialState.newTitle = "Current State Title"
        
        let store = TestStore(initialState: initialState) {
            RenameDialogReducer()
        }
        
        // The action parameter can be different from state
        await store.send(.confirmRename("Different Parameter Title"))
        // No state change expected
    }
    
    @Test("Sequence of actions with modified initial state")
    func sequenceWithModifiedInitialState() async {
        var initialState = RenameDialogReducer.State(session: testSession)
        initialState.newTitle = "Custom Initial Title"
        
        let store = TestStore(initialState: initialState) {
            RenameDialogReducer()
        }
        
        #expect(store.state.newTitle == "Custom Initial Title")
        
        await store.send(.binding(.set(\.newTitle, "First Update"))) {
            $0.newTitle = "First Update"
        }
        
        await store.send(.confirmRename("First Update"))
        
        await store.send(.binding(.set(\.newTitle, "Second Update"))) {
            $0.newTitle = "Second Update"
        }
        
        await store.send(.cancel)
        
        // State should remain at last binding update
        #expect(store.state.newTitle == "Second Update")
    }
}
