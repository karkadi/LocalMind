//
//  ChatClient.swift
//  LocalMind
//
//  Created by Arkadiy KAZAZYAN on 20/06/2025.
//
import Dependencies
import Foundation
import FoundationModels

// MARK: - Protocol
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

/// The default implementation of `ChatClientProtocol`, responsible for interacting with the system's language model.
///
/// `DefaultChatClient` manages the lifecycle and interaction with language model sessions,
/// including session creation, streaming responses, synchronous completions, and model availability checks.
///
/// - Important: This class assumes the presence of the Apple Intelligence language model APIs and is designed
///   to integrate with system-provided language models on supported Apple platforms.
///
/// ### Features
/// - Creates new language model sessions with custom system instructions.
/// - Provides both streaming and non-streaming response interfaces.
/// - Checks model availability and supplies user-friendly descriptions for availability status.
///
/// ### Usage
/// Typically accessed via the dependency system:
/// ```swift
/// let chatClient: ChatClientProtocol = DependencyValues().chatClient
/// let session = try await chatClient.createSession("You are a helpful assistant.")
/// let response = try await chatClient.respond(session, "Hello!", GenerationOptions())
/// ```
///
/// ### See Also
/// - `ChatClientProtocol`
/// - `SystemLanguageModel`
/// - `LanguageModelSession`

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
