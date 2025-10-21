//
//  ChatSession.swift
//  LocalMind
//
//  Created by Arkadiy KAZAZYAN on 20/10/2025.
//
import SQLiteData
import Foundation

@Table
struct ChatSession: Equatable, Identifiable {
    let id: UUID
    var timestamp: Date
    var title: String
}
