//
//  DatabaseClientTests.swift
//  LocalMind
//
//  Created by Arkadiy KAZAZYAN on 29/10/2025.
//

import Testing
import ComposableArchitecture
import SQLiteData
@testable import LocalMind
import Foundation

@MainActor @Suite("DatabaseClient Tests")
struct DatabaseClientTests {
    
    // MARK: - Test Data
    let testSession = ChatSession(
        id: UUID(),
        timestamp: Date(),
        title: "Test Session"
    )
    
    let testMessage = ChatMessage(
        id: UUID(),
        timestamp: Date(),
        text: "Test message",
        role: .user,
        chatSessionID: UUID()
    )
    
    let testSessions = [
        ChatSession(id: UUID(), timestamp: Date(), title: "Session 1"),
        ChatSession(id: UUID(), timestamp: Date(), title: "Session 2")
    ]
    
    let testMessages = [
        ChatMessage(id: UUID(), timestamp: Date(), text: "Hello", role: .user, chatSessionID: UUID()),
        ChatMessage(id: UUID(), timestamp: Date(), text: "Hi there!", role: .assistant, chatSessionID: UUID())
    ]
    
    @Test("Create session successfully")
    func createSessionSuccess() async throws {
        let createdSession = LockIsolated<ChatSession?>(nil)
        
        let client = DatabaseClient(
            createSession: { session in
                createdSession.withValue { $0 = session }
            },
            updateSession: { _ in throw TestError.notImplemented },
            createMessage: { _ in throw TestError.notImplemented },
            updateMessage: { _ in throw TestError.notImplemented },
            deleteSession: { _ in throw TestError.notImplemented },
            fetchAllMessages: { _ in throw TestError.notImplemented },
            fetchAllSessions: { throw TestError.notImplemented }
        )
        
        try await client.createSession(testSession)
        #expect(createdSession.value == testSession)
    }
    
    @Test("Create session throws error")
    func createSessionThrowsError() async throws {
        let client = DatabaseClient(
            createSession: { _ in throw TestError.databaseError },
            updateSession: { _ in throw TestError.notImplemented },
            createMessage: { _ in throw TestError.notImplemented },
            updateMessage: { _ in throw TestError.notImplemented },
            deleteSession: { _ in throw TestError.notImplemented },
            fetchAllMessages: { _ in throw TestError.notImplemented },
            fetchAllSessions: { throw TestError.notImplemented }
        )
        
        await #expect(throws: TestError.self) {
            try await client.createSession(testSession)
        }
    }
    
    @Test("Update session successfully")
    func updateSessionSuccess() async throws {
        let updatedSession = LockIsolated<ChatSession?>(nil)
        
        let client = DatabaseClient(
            createSession: { _ in throw TestError.notImplemented },
            updateSession: { session in
                updatedSession.withValue { $0 = session }
            },
            createMessage: { _ in throw TestError.notImplemented },
            updateMessage: { _ in throw TestError.notImplemented },
            deleteSession: { _ in throw TestError.notImplemented },
            fetchAllMessages: { _ in throw TestError.notImplemented },
            fetchAllSessions: { throw TestError.notImplemented }
        )
        
        try await client.updateSession(testSession)
        #expect(updatedSession.value == testSession)
    }
    
    @Test("Create message successfully")
    func createMessageSuccess() async throws {
        let createdMessage = LockIsolated<ChatMessage?>(nil)
        
        let client = DatabaseClient(
            createSession: { _ in throw TestError.notImplemented },
            updateSession: { _ in throw TestError.notImplemented },
            createMessage: { message in
                createdMessage.withValue { $0 = message }
            },
            updateMessage: { _ in throw TestError.notImplemented },
            deleteSession: { _ in throw TestError.notImplemented },
            fetchAllMessages: { _ in throw TestError.notImplemented },
            fetchAllSessions: { throw TestError.notImplemented }
        )
        
        try await client.createMessage(testMessage)
        #expect(createdMessage.value == testMessage)
    }
    
    @Test("Update message successfully")
    func updateMessageSuccess() async throws {
        let updatedMessage = LockIsolated<ChatMessage?>(nil)
        
        let client = DatabaseClient(
            createSession: { _ in throw TestError.notImplemented },
            updateSession: { _ in throw TestError.notImplemented },
            createMessage: { _ in throw TestError.notImplemented },
            updateMessage: { message in
                updatedMessage.withValue { $0 = message }
            },
            deleteSession: { _ in throw TestError.notImplemented },
            fetchAllMessages: { _ in throw TestError.notImplemented },
            fetchAllSessions: { throw TestError.notImplemented }
        )
        
        try await client.updateMessage(testMessage)
        #expect(updatedMessage.value == testMessage)
    }
    
    @Test("Delete session successfully")
    func deleteSessionSuccess() async throws {
        let deletedSessionId = LockIsolated<UUID?>(nil)
        
        let client = DatabaseClient(
            createSession: { _ in throw TestError.notImplemented },
            updateSession: { _ in throw TestError.notImplemented },
            createMessage: { _ in throw TestError.notImplemented },
            updateMessage: { _ in throw TestError.notImplemented },
            deleteSession: { sessionId in
                deletedSessionId.withValue { $0 = sessionId }
            },
            fetchAllMessages: { _ in throw TestError.notImplemented },
            fetchAllSessions: { throw TestError.notImplemented }
        )
        
        let sessionId = UUID()
        try await client.deleteSession(sessionId)
        #expect(deletedSessionId.value == sessionId)
    }
    
    @Test("Fetch all messages for session")
    func fetchAllMessages() async throws {
        let sessionId = UUID()
        let fetchCallCount = LockIsolated(0)
        
        let client = DatabaseClient(
            createSession: { _ in throw TestError.notImplemented },
            updateSession: { _ in throw TestError.notImplemented },
            createMessage: { _ in throw TestError.notImplemented },
            updateMessage: { _ in throw TestError.notImplemented },
            deleteSession: { _ in throw TestError.notImplemented },
            fetchAllMessages: { id in
                fetchCallCount.withValue { $0 += 1 }
                #expect(id == sessionId)
                return await MainActor.run {
                    self.testMessages.filter { $0.chatSessionID != sessionId }
                }
            },
            fetchAllSessions: { throw TestError.notImplemented }
        )
        
        let messages = try await client.fetchAllMessages(sessionId)
        #expect(messages.count == 2)
        #expect(fetchCallCount.value == 1)
    }
    
    @Test("Fetch all messages returns empty array")
    func fetchAllMessagesEmpty() async throws {
        let client = DatabaseClient(
            createSession: { _ in throw TestError.notImplemented },
            updateSession: { _ in throw TestError.notImplemented },
            createMessage: { _ in throw TestError.notImplemented },
            updateMessage: { _ in throw TestError.notImplemented },
            deleteSession: { _ in throw TestError.notImplemented },
            fetchAllMessages: { _ in [] },
            fetchAllSessions: { throw TestError.notImplemented }
        )
        
        let messages = try await client.fetchAllMessages(UUID())
        #expect(messages.isEmpty)
    }
    
    @Test("Fetch all sessions")
    func fetchAllSessions() async throws {
        let fetchCallCount = LockIsolated(0)
        
        let client = DatabaseClient(
            createSession: { _ in throw TestError.notImplemented },
            updateSession: { _ in throw TestError.notImplemented },
            createMessage: { _ in throw TestError.notImplemented },
            updateMessage: { _ in throw TestError.notImplemented },
            deleteSession: { _ in throw TestError.notImplemented },
            fetchAllMessages: { _ in throw TestError.notImplemented },
            fetchAllSessions: {
                fetchCallCount.withValue { $0 += 1 }
                return self.testSessions
            }
        )
        
        let sessions = try await client.fetchAllSessions()
        #expect(sessions.count == 2)
        #expect(sessions == testSessions)
        #expect(fetchCallCount.value == 1)
    }
    
    @Test("Fetch all sessions returns empty array")
    func fetchAllSessionsEmpty() async throws {
        let client = DatabaseClient(
            createSession: { _ in throw TestError.notImplemented },
            updateSession: { _ in throw TestError.notImplemented },
            createMessage: { _ in throw TestError.notImplemented },
            updateMessage: { _ in throw TestError.notImplemented },
            deleteSession: { _ in throw TestError.notImplemented },
            fetchAllMessages: { _ in throw TestError.notImplemented },
            fetchAllSessions: { [] }
        )
        
        let sessions = try await client.fetchAllSessions()
        #expect(sessions.isEmpty)
    }
    
    @Test("Database operations are Sendable")
    func databaseOperationsAreSendable() async {
        let operationCount = LockIsolated(0)
        
        let client = DatabaseClient(
            createSession: { _ in
                operationCount.withValue { $0 += 1 }
            },
            updateSession: { _ in
                operationCount.withValue { $0 += 1 }
            },
            createMessage: { _ in
                operationCount.withValue { $0 += 1 }
            },
            updateMessage: { _ in
                operationCount.withValue { $0 += 1 }
            },
            deleteSession: { _ in
                operationCount.withValue { $0 += 1 }
            },
            fetchAllMessages: { _ in
                operationCount.withValue { $0 += 1 }
                return []
            },
            fetchAllSessions: {
                operationCount.withValue { $0 += 1 }
                return []
            }
        )
        
        // Test that operations can be called concurrently
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<10 {
                group.addTask {
                    // These should all execute safely concurrently
                    try? await client.createSession(self.testSession)
                    _ = try? await client.fetchAllSessions()
                    try? await client.createMessage(self.testMessage)
                }
            }
            
            for await _ in group {
                // All tasks should complete without crashes
            }
        }
        
        // Should have 30 operations (10 iterations × 3 operations each)
        #expect(operationCount.value == 30)
    }
    
    @Test("Multiple operations in sequence")
    func multipleOperationsInSequence() async throws {
        let operations = LockIsolated<[String]>([])
        
        let client = DatabaseClient(
            createSession: { _ in
                operations.withValue { $0.append("createSession") }
            },
            updateSession: { _ in
                operations.withValue { $0.append("updateSession") }
            },
            createMessage: { _ in
                operations.withValue { $0.append("createMessage") }
            },
            updateMessage: { _ in
                operations.withValue { $0.append("updateMessage") }
            },
            deleteSession: { _ in
                operations.withValue { $0.append("deleteSession") }
            },
            fetchAllMessages: { _ in
                operations.withValue { $0.append("fetchAllMessages") }
                return []
            },
            fetchAllSessions: {
                operations.withValue { $0.append("fetchAllSessions") }
                return []
            }
        )
        
        // Execute operations in sequence
        try await client.createSession(testSession)
        try await client.updateSession(testSession)
        try await client.createMessage(testMessage)
        try await client.updateMessage(testMessage)
        _ = try await client.fetchAllMessages(UUID())
        _ = try await client.fetchAllSessions()
        try await client.deleteSession(UUID())
        
        #expect(operations.value == [
            "createSession",
            "updateSession",
            "createMessage",
            "updateMessage",
            "fetchAllMessages",
            "fetchAllSessions",
            "deleteSession"
        ])
    }
    
    @Test("Error propagation through all methods")
    func errorPropagation() async {
        let client = DatabaseClient(
            createSession: { _ in throw TestError.databaseError },
            updateSession: { _ in throw TestError.databaseError },
            createMessage: { _ in throw TestError.databaseError },
            updateMessage: { _ in throw TestError.databaseError },
            deleteSession: { _ in throw TestError.databaseError },
            fetchAllMessages: { _ in throw TestError.databaseError },
            fetchAllSessions: { throw TestError.databaseError }
        )
        
        await #expect(throws: TestError.self) {
            try await client.createSession(testSession)
        }
        
        await #expect(throws: TestError.self) {
            try await client.updateSession(testSession)
        }
        
        await #expect(throws: TestError.self) {
            try await client.createMessage(testMessage)
        }
        
        await #expect(throws: TestError.self) {
            try await client.updateMessage(testMessage)
        }
        
        await #expect(throws: TestError.self) {
            try await client.deleteSession(UUID())
        }
        
        await #expect(throws: TestError.self) {
            _ = try await client.fetchAllMessages(UUID())
        }
        
        await #expect(throws: TestError.self) {
            _ = try await client.fetchAllSessions()
        }
    }
    
    @Test("Concurrent operations with LockIsolated")
    func concurrentOperations() async {
        let operationCount = LockIsolated(0)
        let completedOperations = LockIsolated<[String]>([])
        
        let client = DatabaseClient(
            createSession: { _ in
                try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
                operationCount.withValue { $0 += 1 }
                completedOperations.withValue { $0.append("createSession") }
            },
            updateSession: { _ in
                try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
                operationCount.withValue { $0 += 1 }
                completedOperations.withValue { $0.append("updateSession") }
            },
            createMessage: { _ in
                try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
                operationCount.withValue { $0 += 1 }
                completedOperations.withValue { $0.append("createMessage") }
            },
            updateMessage: { _ in
                try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
                operationCount.withValue { $0 += 1 }
                completedOperations.withValue { $0.append("updateMessage") }
            },
            deleteSession: { _ in
                try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
                operationCount.withValue { $0 += 1 }
                completedOperations.withValue { $0.append("deleteSession") }
            },
            fetchAllMessages: { _ in
                try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
                operationCount.withValue { $0 += 1 }
                completedOperations.withValue { $0.append("fetchAllMessages") }
                return []
            },
            fetchAllSessions: {
                try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
                operationCount.withValue { $0 += 1 }
                completedOperations.withValue { $0.append("fetchAllSessions") }
                return []
            }
        )
        
        await withTaskGroup(of: Void.self) { group in
            for index in 0..<7 {
                group.addTask {
                    switch index {
                    case 0: try? await client.createSession(self.testSession)
                    case 1: try? await client.updateSession(self.testSession)
                    case 2: try? await client.createMessage(self.testMessage)
                    case 3: try? await client.updateMessage(self.testMessage)
                    case 4: _ = try? await client.fetchAllMessages(UUID())
                    case 5: _ = try? await client.fetchAllSessions()
                    case 6: try? await client.deleteSession(UUID())
                    default: break
                    }
                }
            }
            
            for await _ in group {
                // Wait for all tasks to complete
            }
        }
        
        #expect(operationCount.value == 7)
        #expect(completedOperations.value.count == 7)
    }
}

// MARK: - Test Helpers

enum TestError: Error, Equatable {
    case databaseError
    case notImplemented
}
