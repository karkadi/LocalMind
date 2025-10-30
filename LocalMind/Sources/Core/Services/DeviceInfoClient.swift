//
//  DeviceInfoClient.swift
//  LocalMind
//
//  Created by Arkadiy KAZAZYAN on 23/10/2025.
//

import Foundation
import ComposableArchitecture
import SwiftUI

/// A client responsible for providing information about the current device.
///
/// `DeviceInfoClient` offers properties and methods to retrieve relevant device
/// details, such as system version, model, unique identifiers, and other hardware
/// or software characteristics. This can be used for analytics, diagnostics,
/// feature gating, or tailoring behavior based on device capabilities.
///
/// Typical usage includes querying properties like:
/// - Device model name
/// - System name and version
/// - Device identifier (if available)
/// - Hardware capabilities (e.g., camera availability, biometric support)
///
/// All data access should respect user privacy and platform-specific guidelines.
///
/// - Note: The specific properties and methods available depend on the platform
///   (iOS, macOS, watchOS, visionOS, etc.) and the implementation details of this client.
///
/// Example:
/// ```swift
/// let info = DeviceInfoClient.shared
/// print("Device Model: \(info.modelName)")
/// print("System Version: \(info.systemVersion)")
/// ```
struct DeviceInfoClient: Sendable {
    var isiPad: @Sendable () -> Bool
    var isMacOS: @Sendable () -> Bool
    var shouldUseSplitView: @Sendable () -> Bool
}

// MARK: - Live Implementation
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
            // Explicitly ensure that iPhones never use SplitView, even in landscape
            return MainActor.assumeIsolated {
                let idiom = UIDevice.current.userInterfaceIdiom
                return idiom == .pad
            }
#elseif os(macOS)
            return true
#else
            return false
#endif
        }
    )
    
    // For previews or testing
    static let testValue = DeviceInfoClient(
        isiPad: { false },
        isMacOS: { false },
        shouldUseSplitView: { false }
    )
}

// MARK: - Dependency Registration
extension DependencyValues {
    var deviceInfo: DeviceInfoClient {
        get { self[DeviceInfoClient.self] }
        set { self[DeviceInfoClient.self] = newValue }
    }
}
