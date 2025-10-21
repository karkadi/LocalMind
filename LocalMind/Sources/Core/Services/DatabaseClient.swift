//
//  DatabaseClient.swift
//  LocalMind
//
//  Created by Arkadiy KAZAZYAN on 18/07/2025.
//
import ComposableArchitecture
import SQLiteData
import Foundation

// MARK: - Sendable Service
struct DatabaseClient: Sendable {
    var createSession: @Sendable (_ session: ChatSession) async throws -> Void
    var updateSession: @Sendable (_ session: ChatSession) async throws -> Void
    var createMessage: @Sendable (_ message: ChatMessage) async throws -> Void
    var updateMessage: @Sendable (_ message: ChatMessage) async throws -> Void
    var deleteSession: @Sendable (_ sessionId: UUID) async throws -> Void
    var fetchAllMessages: @Sendable (_ sessionId: UUID) async throws -> [ChatMessage]
    var fetchAllSessions: @Sendable () async throws -> [ChatSession]
}

// MARK: - Live Implementation
extension DatabaseClient: DependencyKey {
    static let liveValue: DatabaseClient = {
        @Dependency(\.defaultDatabase) var database
        
        return DatabaseClient(
            createSession: { session in
                try await database.write { sqlDb in
                    try ChatSession.upsert { session }
                        .execute(sqlDb)
                }
            },
            updateSession: { session in
                try await database.write { sqlDb in
                    try ChatSession.upsert { session }
                        .execute(sqlDb)
                }
            },
            createMessage: { message in
                do {
                    try await database.write { sqlDb in
                        try ChatMessage.upsert { message }
                            .execute(sqlDb)
                    }
                }
            },
            updateMessage: { message in
                do {
                    try await database.write { sqlDb in
                        try ChatMessage.upsert { message }
                            .execute(sqlDb)
                    }
                }
            },
            deleteSession: { sessionId in
                try await database.write { sqlDb in
                    try ChatSession
                        .where { $0.id.eq(sessionId) }
                        .delete()
                        .execute(sqlDb)
                }
            },
            fetchAllMessages: { sessionId in
                let messages: [ChatMessage] = try await database.read { sqlDb in
                    try ChatMessage
                        .where { $0.chatSessionID.eq(sessionId) }
                        .order(by: \.timestamp)
                        .fetchAll(sqlDb)
                }
                return messages
            },
            fetchAllSessions: {
                let sessions: [ChatSession] = try await database.read { sqlDb in
                    try ChatSession
                        .order(by: \.timestamp)
                        .fetchAll(sqlDb)
                }
                return sessions
            }
        )
    }()
}

// MARK: - Dependency Registration
extension DependencyValues {
    var databaseClient: DatabaseClient {
        get { self[DatabaseClient.self] }
        set { self[DatabaseClient.self] = newValue }
    }
}
