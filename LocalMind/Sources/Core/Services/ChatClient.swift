//
//  ChatClient.swift
//  LocalMind
//
//  Created by Arkadiy KAZAZYAN on 20/06/2025.
//
import Dependencies
import Foundation
import FoundationModels

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
struct ChatClient: Sendable {
    var createSession: @Sendable (_ systemInstructions: String) async throws -> LanguageModelSession
    var streamResponse: @Sendable (_ session: LanguageModelSession,
                                   _ prompt: String,
                                   _ options: GenerationOptions) -> LanguageModelSession.ResponseStream<String>
    var respond: @Sendable (_ session: LanguageModelSession,
                            _ prompt: String,
                            _ options: GenerationOptions) async throws -> String
    var isModelAvailable: @Sendable () -> Bool
    var availabilityDescription: @Sendable (_ availability: SystemLanguageModel.Availability) -> String
}

// MARK: - Live Implementation
extension ChatClient: DependencyKey {
    static let liveValue: ChatClient = {
        ChatClient(createSession: { systemInstructions in
            LanguageModelSession(instructions: systemInstructions)
        },
                   streamResponse: { session, prompt, options in
            session.streamResponse(to: prompt, options: options)
        },
                   respond: { session, prompt, options in
            try await session.respond(to: prompt, options: options).content
        },
                   isModelAvailable: {
            SystemLanguageModel.default.isAvailable
        },
                   availabilityDescription: { availability in
            switch availability {
            case .available:
                return "Available"
            case .unavailable(let reason):
                switch reason {
                case .deviceNotEligible:
                    return "Device not eligible"
                case .appleIntelligenceNotEnabled:
                    return "Apple Intelligence not enabled in Settings"
                case .modelNotReady:
                    return "Model assets not downloaded"
                @unknown default:
                    return "Unknown reason"
                }
            @unknown default:
                return "Unknown availability"
            }
        })
    }()
}

// MARK: - Dependency Registration
extension DependencyValues {
    var chatClient: ChatClient {
        get { self[ChatClient.self] }
        set { self[ChatClient.self] = newValue }
    }
}
