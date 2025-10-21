//
//  ChatMessage.swift
//  LocalMind
//
//  Created by Arkadiy KAZAZYAN on 20/10/2025.
//
import SQLiteData
import Foundation

@Table
struct ChatMessage: Equatable, Identifiable {
    let id: UUID
    var timestamp: Date
    var text: String
    var role: ChatRole
    var chatSessionID: ChatSession.ID
    
    enum ChatRole: Int, QueryBindable {
        case user = 1
        case assistant
    }
}
