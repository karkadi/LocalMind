//
//  DatabaseClient.swift
//  LocalMind
//
//  Created by Arkadiy KAZAZYAN on 18/07/2025.
//
import ComposableArchitecture
import SQLiteData
import Foundation

/// `DatabaseClient` is a protocol or type that abstracts database interactions within the application.
///
/// This client provides a unified interface for performing CRUD (Create, Read, Update, Delete) operations,
/// executing queries, and managing database connections, transactions, and migrations. Its implementation
/// may encapsulate details such as connection pooling, error handling, and concurrency management,
/// ensuring thread-safe and efficient access to the underlying database.
///
/// Typically, `DatabaseClient` is injected into services or view models, allowing for testability and
/// decoupling from specific database technologies. Implementations can target various database engines,
/// such as SQLite, Core Data, or even remote databases, depending on the needs of the application.
///
/// - Note: Methods and properties in `DatabaseClient` should be designed to leverage Swift’s concurrency
///   features (e.g., async/await) to enable efficient and responsive data access.
///
/// Example responsibilities for `DatabaseClient` may include:
/// - Executing SQL or query-builder statements.
/// - Fetching, inserting, updating, or deleting records.
/// - Managing database schema migrations.
/// - Handling database errors and propagating meaningful error information.
///
/// Usage:
/// ```swift
/// let users = try await databaseClient.fetchUsers()
/// try await databaseClient.insertUser(newUser)
/// ```
///
/// By abstracting the database layer, `DatabaseClient` promotes code modularity, easier testing with
/// mock databases, and flexibility to swap or upgrade data storage technologies.
struct DatabaseClient: Sendable {
    var createSession: @Sendable (_ session: ChatSession) async throws -> Void
    var updateSession: @Sendable (_ session: ChatSession) async throws -> Void
    var createMessage: @Sendable (_ message: ChatMessage) async throws -> Void
    var updateMessage: @Sendable (_ message: ChatMessage) async throws -> Void
    var deleteSession: @Sendable (_ sessionId: UUID) async throws -> Void
    var fetchAllMessages: @Sendable (_ sessionId: UUID) async throws -> [ChatMessage]
    var fetchAllSessions: @Sendable () async throws -> [ChatSession]
    var searchMessages: @Sendable (_ query: String) async throws -> [UUID]
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
            },
            searchMessages: { query in
                let messages: [ChatMessage] = try await database.read { sqlDb in
                    try ChatMessage
                        .where { $0.text.contains(query) }
                        .order(by: \.timestamp)
                        .fetchAll(sqlDb)
                }
                return messages.map { $0.chatSessionID }
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
