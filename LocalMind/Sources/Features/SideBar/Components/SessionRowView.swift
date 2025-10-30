//
//  SessionRowView.swift
//  LocalMind
//
//  Created by Arkadiy KAZAZYAN on 29/10/2025.
//
import SwiftUI

// Separate view for session row to handle search highlighting
struct SessionRowView: View {
    let session: ChatSession
    let isSearchResult: Bool
    let searchText: String
    let onSelect: () -> Void
    let onRename: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.title)
                    .font(.headline)
                    .lineLimit(1)
                
                if isSearchResult && !searchText.isEmpty {
                    Text("Contains: \"\(searchText)\"")
                        .foregroundColor(.blue)
                        .font(.caption2)
                        .italic()
                }
                
                Text(session.timestamp, style: .date)
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            
            Spacer()
            
            Text(session.timestamp, style: .time)
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onSelect)
        .contextMenu {
            Button("Rename", action: onRename)
            Button("Delete", role: .destructive, action: onDelete)
        }
    }
}

#Preview {
    SessionRowView(session: .init(id: UUID(),
                                  timestamp: Date(),
                                  title: "Test Message"),
                   isSearchResult: true,
                   searchText: "Hello",
                   onSelect: { },
                   onRename: { },
                   onDelete: { }
    )
}
