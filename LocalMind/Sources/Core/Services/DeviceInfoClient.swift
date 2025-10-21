//
//  DeviceInfoClient.swift
//  LocalMind
//
//  Created by Arkadiy KAZAZYAN on 23/10/2025.
//

import Foundation
import ComposableArchitecture
import SwiftUI

struct DeviceInfoClient: Sendable {
    var isiPad: @Sendable () -> Bool
    var isMacOS: @Sendable () -> Bool
    var shouldUseSplitView: @Sendable () -> Bool
}

extension DeviceInfoClient: DependencyKey {
    static let liveValue = DeviceInfoClient(
        isiPad: {
#if os(iOS)
            return MainActor.assumeIsolated {
                UIDevice.current.userInterfaceIdiom == .pad
            }
#else
            return false
#endif
        },
        isMacOS: {
#if os(macOS)
            return true
#else
            return false
#endif
        },
        shouldUseSplitView: {
#if os(iOS)
            return MainActor.assumeIsolated {
                UIDevice.current.userInterfaceIdiom == .pad
            }
#elseif os(macOS)
            return true
#else
            return false
#endif
        }
    )
    
    // Optional: For previews or testing
    static let testValue = DeviceInfoClient(
        isiPad: { false },
        isMacOS: { false },
        shouldUseSplitView: { false }
    )
}

extension DependencyValues {
    var deviceInfo: DeviceInfoClient {
        get { self[DeviceInfoClient.self] }
        set { self[DeviceInfoClient.self] = newValue }
    }
}
