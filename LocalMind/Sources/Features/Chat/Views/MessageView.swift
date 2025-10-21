//
//  MessageView.swift
//  LocalMind
//
//  Created by Arkadiy KAZAZYAN on 20/06/2025.
//

import SwiftUI
import LaTeXSwiftUI

/// `MessageView` is a SwiftUI view responsible for rendering an individual chat message within a conversation interface.
///
/// The view supports different layouts and styling based on the message's role (user or system/assistant), displaying user messages right-aligned
/// with a blue background and assistant messages left-aligned with selectable text. If the assistant is currently "responding" and the message
/// text is empty, a pulsing dot indicator is shown to signal an incoming response.
///
/// - Parameters:
///   - message: The `ChatMessage` object containing the message text and role metadata.
///   - isResponding: A Boolean value indicating whether the assistant is currently generating a response, affecting the display of typing indicators.
///
/// The view uses `glassEffect` and rounded rectangles for modern styling, and makes use of SwiftUI's layout containers
/// (`HStack`, `VStack`, and `Spacer`) to position messages appropriately within the chat interface.
struct MessageView: View {
    let message: ChatMessage
    let isResponding: Bool
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
                Text(message.text)
                    .padding(12)
                    .background(userRoleColor)
                    .clipShape(.rect(cornerRadius: 18))
                    .glassEffect(in: .rect(cornerRadius: 18))
                
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    if message.text.isEmpty && isResponding {
                        PulsingDotView()
                            .frame(width: 60, height: 25)
                    } else {
                        if isResponding {
                            Text(message.text)
                                .textSelection(.enabled)
                        } else {
                            LaTeX( message.text )
                                .textSelection(.enabled)
                                .renderingStyle(.wait)
                             // .blockMode(.blockText)
                                .errorMode(.rendered)
                        }
                    }
                }
                .padding(.vertical, 8)
                Spacer()
            }
        }
        .padding(.vertical, 6)
    }
}

#Preview("Latext in a Message") {
    let latex = #"""
            The theorem states:
            
            \[
            (a + b)^n = \sum_{k=0}^{n} \binom{n}{k} a^{n-k} b^k
            \]
            
            Here, \(\binom{n}{k}\) is a binomial coefficient, calculated as:
            
            \[
            \binom{n}{k} = \frac{n!}{k!(n-k)!}
            \]
            
            where \(n!\) denotes the factorial of \(n\), which is the product of all positive integers up to \(n\).
            
            If you meant something else by "binome newtons," please provide more context or check the spelling.
        """#
    MessageView( message: .init(id: UUID(), timestamp: Date(), text: latex, role: .assistant, chatSessionID: UUID()),
                 isResponding: false
    )
}
