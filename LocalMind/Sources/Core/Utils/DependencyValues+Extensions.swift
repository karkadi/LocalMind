//
//  DependencyValues+Extensions.swift
//  LocalMind
//
//  Created by Arkadiy KAZAZYAN on 20/10/2025.
//
import OSLog
import SQLiteData
import Foundation
/// Initializes and prepares the application's database for use.
///
/// This function is responsible for setting up all necessary database structures,
/// performing any required migrations, and seeding initial data if needed.
/// It should be called early in the application's lifecycle, typically during launch,
/// to ensure the database is ready before any operations are performed.
///
/// - Throws: An error if database creation, migration, or seeding fails.
/// - Important: This function may block while database operations are being performed.
///   Consider calling it from a background queue if synchronous calls are undesirable.
/// - SeeAlso: `migrateDatabase()`, `seedDatabaseIfNeeded()`
extension DependencyValues {
    mutating func bootstrapDatabase() throws {
        @Dependency(\.context) var context
        let database = try SQLiteData.defaultDatabase()
        kLogger.debug(
      """
      App database
      open "\(database.path)"
      """
        )
        
        var migrator = DatabaseMigrator()
#if DEBUG
        migrator.eraseDatabaseOnSchemaChange = true
#endif
        migrator.registerMigration("Create tables") { sqlDb in
            
            try #sql(
           """
           CREATE TABLE "chatSessions" (
               "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
               "timestamp" TEXT NOT NULL ON CONFLICT REPLACE,
               "title" TEXT NOT NULL ON CONFLICT REPLACE
           ) STRICT;
           """
            )
            .execute(sqlDb)
            
            try #sql(
          """
          CREATE TABLE "chatMessages" (
              "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
              "timestamp" TEXT NOT NULL ON CONFLICT REPLACE,
              "text" TEXT NOT NULL ON CONFLICT REPLACE,
              "role" INTEGER NOT NULL ON CONFLICT REPLACE,
              "chatSessionID" TEXT NOT NULL,
              FOREIGN KEY("chatSessionID") REFERENCES "chatSessions"("id") ON DELETE CASCADE
          ) STRICT;
          """
            )
            .execute(sqlDb)
        }
        try migrator.migrate(database)
        defaultDatabase = database
        defaultSyncEngine = try SyncEngine(
            for: database,
            tables: ChatMessage.self,
            ChatSession.self)
    }
}

private let kLogger = Logger(subsystem: "SQLStoryState", category: "Database")
