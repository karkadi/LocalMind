//
//  View+Extension.swift
//  LocalMind
//
//  Created by Arkadiy KAZAZYAN on 19/10/2025.
//
import SwiftUI

extension View {
    
    var screenSize: CGSize {
#if os(iOS)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return windowScene.screen.bounds.size
        }
#elseif os(macOS)
        if let screen = NSScreen.main {
            return screen.visibleFrame.size
        }
#endif
        // Fallback for when screen is not available
#if os(iOS)
        return CGSize(width: 393, height: 852) // Common iPhone size
#elseif os(macOS)
        return CGSize(width: 1024, height: 768) // Common macOS size
#else
        return CGSize(width: 393, height: 852)
#endif
    }
    
    var screenWidth: CGFloat {
        screenSize.width
    }
    
    var screenHeight: CGFloat {
        screenSize.height
    }
    
    // Platform-specific background color
    var backgroundColor: Color {
#if os(macOS)
        return Color(nsColor: .windowBackgroundColor)
#else
        return Color(.systemBackground)
#endif
    }
    
    // MARK: - Layout Helpers
    func isLandscape(horizontalSizeClass: UserInterfaceSizeClass?,
                     verticalSizeClass: UserInterfaceSizeClass?) -> Bool {
#if os(iOS)
        horizontalSizeClass == .regular && verticalSizeClass == .compact
#else
        false
#endif
    }
    
    func getSidebarWidth(isLandscape: Bool) -> CGFloat {
#if os(macOS)
        return 250
#elseif os(iOS)
        if UIDevice.current.userInterfaceIdiom == .phone {
            return isLandscape ? screenWidth * 0.3 : screenWidth * 0.75
        } else {
            return screenWidth * 0.75
        }
#else
        return screenWidth * 0.75
#endif
    }
    
    var userRoleColor: Color {
        Color("UserRoleColor")
    }
}
