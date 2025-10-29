//
//  SettingsReducerTests.swift
//  LocalMindTests
//
//  Created by Arkadiy KAZAZYAN on 29/10/2025.
//
import Testing
import ComposableArchitecture
@testable import LocalMind

@MainActor @Suite("SettingsReducer Tests")
struct SettingsReducerTests {
    
    @Test("Initial state has default values")
    func initialState() {
        let store = TestStore(initialState: SettingsReducer.State()) {
            SettingsReducer()
        }
        
        #expect(store.state.useStreaming == true)
        #expect(store.state.temperature == 0.7)
        #expect(store.state.systemInstructions == "You are a helpful assistant.")
    }
    
    @Test("Toggling useStreaming updates state")
    func toggleUseStreaming() async {
        let store = TestStore(initialState: SettingsReducer.State()) {
            SettingsReducer()
        }
        
        await store.send(.useStreamingToggled(false)) {
            $0.$useStreaming.withLock { $0 = false }
        }
        
        await store.send(.useStreamingToggled(true)) {
            $0.$useStreaming.withLock { $0 = true }
        }
    }
    @Test("Changing temperature updates state")
    func changeTemperature() async {
        let store = TestStore(initialState: SettingsReducer.State()) {
            SettingsReducer()
        }
        
        let testTemperature = 0.9
        await store.send(.temperatureChanged(testTemperature)) {
            $0.$temperature.withLock { $0 = testTemperature }
        }
        
        let anotherTemperature = 0.5
        await store.send(.temperatureChanged(anotherTemperature)) {
            $0.$temperature.withLock { $0 = anotherTemperature }
        }
    }
    
    @Test("Changing system instructions updates state")
    func changeSystemInstructions() async {
        let store = TestStore(initialState: SettingsReducer.State()) {
            SettingsReducer()
        }
        
        let customInstructions = "You are a technical assistant specializing in Swift programming."
        await store.send(.systemInstructionsChanged(customInstructions)) {
            $0.$systemInstructions.withLock { $0 = customInstructions }
        }
        
        let emptyInstructions = ""
        await store.send(.systemInstructionsChanged(emptyInstructions)) {
            $0.$systemInstructions.withLock { $0 = emptyInstructions }
        }
        
        let longInstructions = String(repeating: "Test ", count: 100)
        await store.send(.systemInstructionsChanged(longInstructions)) {
            $0.$systemInstructions.withLock { $0 = longInstructions }
        }
    }
    
    @Test("Done button tapped triggers dismiss")
    func doneButtonTapped() async {
        var dismissCalled = false
        
        let store = TestStore(initialState: SettingsReducer.State()) {
            SettingsReducer()
        } withDependencies: {
            $0.dismiss = DismissEffect {
                dismissCalled = true
            }
        }
        
        await store.send(.doneButtonTapped)
        
        #expect(dismissCalled == true)
    }
    
    @Test("On appear does nothing")
    func onAppear() async {
        let store = TestStore(initialState: SettingsReducer.State()) {
            SettingsReducer()
        }
        
        await store.send(.onAppear)
    }
    
    @Test("Multiple state changes work independently")
    func multipleStateChanges() async {
        let store = TestStore(initialState: SettingsReducer.State()) {
            SettingsReducer()
        }
        
        // Test multiple sequential changes
        await store.send(.useStreamingToggled(false)) {
            $0.$useStreaming.withLock { $0 = false }
        }
        
        await store.send(.temperatureChanged(1.0)) {
            $0.$temperature.withLock { $0 = 1.0 }
        }
        
        await store.send(.systemInstructionsChanged("Custom instructions")) {
            $0.$systemInstructions.withLock { $0 = "Custom instructions" }
        }
        
        // Verify final state by reading the values (not modifying)
        #expect(store.state.useStreaming == false)
        #expect(store.state.temperature == 1.0)
        #expect(store.state.systemInstructions == "Custom instructions")
    }
    
    @Test("Bound values update through shared storage")
    func sharedStorageUpdates() async {
        let store = TestStore(initialState: SettingsReducer.State()) {
            SettingsReducer()
        }
        
        // Test that the @Shared properties are properly bound
        await store.send(.useStreamingToggled(false)) {
            $0.$useStreaming.withLock { $0 = false }
        }
        
        // The @Shared property should reflect the change when reading
        #expect(store.state.useStreaming == false)
        
        await store.send(.temperatureChanged(0.3)) {
            $0.$temperature.withLock { $0 = 0.3 }
        }
        
        #expect(store.state.temperature == 0.3)
    }
    
    @Test("Edge cases for temperature values")
    func temperatureEdgeCases() async {
        let store = TestStore(initialState: SettingsReducer.State()) {
            SettingsReducer()
        }
        
        // Test minimum temperature
        await store.send(.temperatureChanged(0.0)) {
            $0.$temperature.withLock { $0 = 0.0 }
        }
        
        // Test maximum temperature
        await store.send(.temperatureChanged(2.0)) {
            $0.$temperature.withLock { $0 = 2.0 }
        }
        
        // Test fractional values
        await store.send(.temperatureChanged(0.123)) {
            $0.$temperature.withLock { $0 = 0.123 }
        }
    }
    
    @Test("System instructions with special characters")
    func systemInstructionsSpecialCharacters() async {
        let store = TestStore(initialState: SettingsReducer.State()) {
            SettingsReducer()
        }
        
        let instructionsWithNewlines = "Line 1\nLine 2\nLine 3"
        await store.send(.systemInstructionsChanged(instructionsWithNewlines)) {
            $0.$systemInstructions.withLock { $0 = instructionsWithNewlines }
        }
        
        let instructionsWithUnicode = "Hello 🌍! 你好! ¡Hola!"
        await store.send(.systemInstructionsChanged(instructionsWithUnicode)) {
            $0.$systemInstructions.withLock { $0 = instructionsWithUnicode }
        }
        
        let instructionsWithEmojis = "Be friendly 😊 and helpful 🤝"
        await store.send(.systemInstructionsChanged(instructionsWithEmojis)) {
            $0.$systemInstructions.withLock { $0 = instructionsWithEmojis }
        }
    }
    
    @Test("Reducer handles all actions without effects except done button")
    func reducerActionCoverage() async {
        let store = TestStore(initialState: SettingsReducer.State()) {
            SettingsReducer()
        } withDependencies: {
            $0.dismiss = DismissEffect { }
        }
        
        // Test that all actions except doneButtonTapped return .none
        await store.send(.onAppear)
        await store.send(.useStreamingToggled(true)) {
            $0.$useStreaming.withLock { $0 = true }
        }
        await store.send(.temperatureChanged(0.8)) {
            $0.$temperature.withLock { $0 = 0.8 }
        }
        await store.send(.systemInstructionsChanged("Test")) {
            $0.$systemInstructions.withLock { $0 = "Test" }
        }
        
        // doneButtonTapped should trigger dismiss effect
        await store.send(.doneButtonTapped)
    }
}
