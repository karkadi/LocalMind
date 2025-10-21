//
//  PulsingDotView.swift
//  LocalMind
//
//  Created by Arkadiy KAZAZYAN on 20/06/2025.
//
import SwiftUI

/// `PulsingDotView` is a SwiftUI view that displays a horizontal row of three animated dots.
/// 
/// Each dot pulses (scales and fades in/out) in a repeating, staggered sequence, creating a
/// dynamic loading or activity indicator effect. The animation runs continuously while the view is visible.
///
/// Designed as a subtle and visually appealing indicator, this view is commonly used to show
/// progress or waiting states—such as while awaiting a response from an AI or network request.
///
/// - Usage:
///   Add `PulsingDotView()` wherever you want to show a loading animation in your SwiftUI hierarchy.
struct PulsingDotView: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3) { index in
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundStyle(.primary.opacity(0.5))
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .opacity(isAnimating ? 1.0 : 0.3)
                    .animation(
                        .easeInOut(duration: 0.6).repeatForever().delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
        }
        .onAppear { isAnimating = true }
    }
}
