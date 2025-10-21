//
//  KeyPath+Extensions.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 17/10/2025.
//
//
// https://github.com/pointfreeco/swift-navigation/discussions/138
//
// This is a limitation of Swift currently, and a recently accepted proposal will fix the issue. For now you can ignore those warnings.

extension KeyPath: @unchecked @retroactive Sendable {}
