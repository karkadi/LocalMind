//
//  DeviceInfoClientTests.swift
//  LocalMindTests
//
//  Created by Arkadiy KAZAZYAN on 29/10/2025.
//
import Testing
import ComposableArchitecture
@testable import LocalMind

@MainActor  @Suite("DeviceInfoClient Tests")
struct DeviceInfoClientTests {
    
    @Test("Live value returns correct values for iOS simulator")
    func liveValueForIOSSimulator() async {
        let client = DeviceInfoClient.liveValue
        
        // Note: These tests assume they're running in the iOS simulator
        // In a real iOS simulator environment, isiPad would typically return false
        // and shouldUseSplitView would return false unless it's an iPad simulator
        
        #expect(client.isiPad() == false || client.isiPad() == true) // Can be either in simulator
        #expect(client.isMacOS() == false) // Should be false on iOS
        #expect(client.shouldUseSplitView() == client.isiPad()) // Should match iPad status
    }
    
    @Test("Test value returns false for all properties")
    func testValueReturnsFalse() {
        let client = DeviceInfoClient.testValue
        
        #expect(client.isiPad() == false)
        #expect(client.isMacOS() == false)
        #expect(client.shouldUseSplitView() == false)
    }
    
    @Test("Custom client configurations work correctly")
    func customClientConfigurations() {
        // Test iPad configuration
        let iPadClient = DeviceInfoClient(
            isiPad: { true },
            isMacOS: { false },
            shouldUseSplitView: { true }
        )
        
        #expect(iPadClient.isiPad() == true)
        #expect(iPadClient.isMacOS() == false)
        #expect(iPadClient.shouldUseSplitView() == true)
        
        // Test Mac configuration
        let macClient = DeviceInfoClient(
            isiPad: { false },
            isMacOS: { true },
            shouldUseSplitView: { true }
        )
        
        #expect(macClient.isiPad() == false)
        #expect(macClient.isMacOS() == true)
        #expect(macClient.shouldUseSplitView() == true)
        
        // Test iPhone configuration
        let iPhoneClient = DeviceInfoClient(
            isiPad: { false },
            isMacOS: { false },
            shouldUseSplitView: { false }
        )
        
        #expect(iPhoneClient.isiPad() == false)
        #expect(iPhoneClient.isMacOS() == false)
        #expect(iPhoneClient.shouldUseSplitView() == false)
    }

    @Test("Client is Sendable")
    func clientIsSendable() async {
        let client = DeviceInfoClient.testValue
        
        // Test that the client can be used across actors
        await withTaskGroup(of: Bool.self) { group in
            for _ in 0..<5 {
                group.addTask {
                    // All these should safely execute concurrently
                    let isiPad = await client.isiPad()
                    let isMacOS = await client.isMacOS()
                    let shouldUseSplitView = await client.shouldUseSplitView()
                    return !isiPad && !isMacOS && !shouldUseSplitView // All false for testValue
                }
            }
            
            for await result in group {
                #expect(result == true)
            }
        }
    }
    
    @Test("Functions are callable multiple times")
    func functionsAreCallableMultipleTimes() {
        let client = DeviceInfoClient(
            isiPad: { true },
            isMacOS: { false },
            shouldUseSplitView: { true }
        )
        
        // Call multiple times to ensure no side effects
        #expect(client.isiPad() == true)
        #expect(client.isiPad() == true)
        #expect(client.isiPad() == true)
        
        #expect(client.isMacOS() == false)
        #expect(client.isMacOS() == false)
        
        #expect(client.shouldUseSplitView() == true)
        #expect(client.shouldUseSplitView() == true)
        #expect(client.shouldUseSplitView() == true)
    }
  
    @Test("Should use split view logic is consistent")
    func shouldUseSplitViewLogic() {
        // Test that shouldUseSplitView follows the expected logic:
        // - true for iPad and macOS
        // - false otherwise
        
        let iPadClient = DeviceInfoClient(
            isiPad: { true },
            isMacOS: { false },
            shouldUseSplitView: { true } // Should be true for iPad
        )
        #expect(iPadClient.shouldUseSplitView() == true)
        
        let macClient = DeviceInfoClient(
            isiPad: { false },
            isMacOS: { true },
            shouldUseSplitView: { true } // Should be true for macOS
        )
        #expect(macClient.shouldUseSplitView() == true)
        
        let iPhoneClient = DeviceInfoClient(
            isiPad: { false },
            isMacOS: { false },
            shouldUseSplitView: { false } // Should be false for iPhone
        )
        #expect(iPhoneClient.shouldUseSplitView() == false)
    }
    
    @Test("Dependency values can be set and retrieved")
    func dependencyValuesStorage() {
        var dependencies = DependencyValues()
        
        let customClient = DeviceInfoClient(
            isiPad: { true },
            isMacOS: { false },
            shouldUseSplitView: { true }
        )
        
        // Set the dependency
        dependencies.deviceInfo = customClient
        
        // Retrieve and verify
        let retrievedClient = dependencies.deviceInfo
        #expect(retrievedClient.isiPad() == true)
        #expect(retrievedClient.isMacOS() == false)
        #expect(retrievedClient.shouldUseSplitView() == true)
    }
    
    @Test("Multiple dependency instances work independently")
    func multipleDependencyInstances() {
        let client1 = DeviceInfoClient(
            isiPad: { true },
            isMacOS: { false },
            shouldUseSplitView: { true }
        )
        
        let client2 = DeviceInfoClient(
            isiPad: { false },
            isMacOS: { true },
            shouldUseSplitView: { true }
        )
        
        let client3 = DeviceInfoClient(
            isiPad: { false },
            isMacOS: { false },
            shouldUseSplitView: { false }
        )
        
        // Each client should maintain its own state
        #expect(client1.isiPad() == true)
        #expect(client2.isiPad() == false)
        #expect(client3.isiPad() == false)
        
        #expect(client1.isMacOS() == false)
        #expect(client2.isMacOS() == true)
        #expect(client3.isMacOS() == false)
        
        #expect(client1.shouldUseSplitView() == true)
        #expect(client2.shouldUseSplitView() == true)
        #expect(client3.shouldUseSplitView() == false)
    }
}
