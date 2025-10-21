//
//  DependencyValues+Extensions.swift
//  LocalMind
//
//  Created by Arkadiy KAZAZYAN on 20/10/2025.
//
import OSLog
import SQLiteData
import Foundation

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
    }
}

private let kLogger = Logger(subsystem: "SQLStoryState", category: "Database")
