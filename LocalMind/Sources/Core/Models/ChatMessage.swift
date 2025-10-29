//
//  ChatMessage.swift
//  LocalMind
//
//  Created by Arkadiy KAZAZYAN on 20/10/2025.
//
import SQLiteData
import Foundation

/// Represents a single message in a chat conversation.
///
/// The `ChatMessage` structure encapsulates the details of a message exchanged between participants
/// in a chat session. It typically includes information such as the message's unique identifier,
/// the sender, the content, the timestamp, and any additional metadata relevant to the chat context.
///
/// - Properties:
///   - id: A unique identifier for the message.
///   - sender: The participant who sent the message.
///   - content: The body or text of the message.
///   - timestamp: The date and time when the message was sent.
///   - isIncoming: A Boolean value indicating whether the message was received (`true`)
///     or sent (`false`) by the current user.
///   - metadata: Optional data providing additional context or attributes about the message,
///     such as attachments, reactions, or status indicators.
///
/// - Note:
///   Depending on the chat application's requirements, `ChatMessage` can be extended to include
///   support for multimedia content, message status (e.g., delivered, read), or threading.
///
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
