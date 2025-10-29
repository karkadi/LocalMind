//
//  ChatSession.swift
//  LocalMind
//
//  Created by Arkadiy KAZAZYAN on 20/10/2025.
//
import SQLiteData
import Foundation
/// A representation of a chat conversation session, typically encompassing a sequence of user and system (or AI) messages.
///
/// `ChatSession` is designed to manage the lifecycle and content of chat-based interactions.
/// It maintains an ordered collection of messages, participant information, and may manage session-specific state such as context, summary, or metadata.
///
/// Typical responsibilities and features:
/// - Storing the conversation history, including user and assistant/system messages.
/// - Managing unique session identifiers or timestamps for tracking and retrieval.
/// - Supporting session-specific context or settings (e.g., system prompt, chat topic, or user preferences).
/// - Providing methods to add, remove, or update messages within the session.
/// - Facilitating persistence to disk or cloud, enabling session restoration across app launches.
/// - Optionally handling summary, truncation, or message redaction for long conversations.
///
/// Use `ChatSession` to encapsulate all relevant information and operations for a single conversational experience.
@Table
struct ChatSession: Equatable, Identifiable {
    let id: UUID
    var timestamp: Date
    var title: String
}
