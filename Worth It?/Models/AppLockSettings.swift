//
//  AppLockSettings.swift
//  Worth It?
//
//  Translated from src/types/appLock.ts
//

import Foundation

// React: type LockTrigger = 'on_open' | 'on_background' | 'after_inactivity'
enum LockTrigger: String, Codable, CaseIterable {
    case onOpen = "on_open"
    case onBackground = "on_background"
    case afterInactivity = "after_inactivity"

    var displayName: String {
        switch self {
        case .onOpen: return "When app opens"
        case .onBackground: return "When app goes to background"
        case .afterInactivity: return "After inactivity"
        }
    }
}

// React: interface AppLockSettings
struct AppLockSettings: Codable {
    var isEnabled: Bool
    var pinHash: String?  // Stored as hashed value
    var biometricsEnabled: Bool
    var lockTrigger: LockTrigger
    var inactivityTimeout: Int  // in minutes

    // React: DEFAULT_LOCK_SETTINGS
    static let `default` = AppLockSettings(
        isEnabled: false,
        pinHash: nil,
        biometricsEnabled: false,
        lockTrigger: .onOpen,
        inactivityTimeout: 5
    )
}

// Inactivity timeout options
enum InactivityTimeout: Int, CaseIterable {
    case oneMinute = 1
    case fiveMinutes = 5
    case fifteenMinutes = 15
    case thirtyMinutes = 30

    var displayName: String {
        switch self {
        case .oneMinute: return "1 minute"
        case .fiveMinutes: return "5 minutes"
        case .fifteenMinutes: return "15 minutes"
        case .thirtyMinutes: return "30 minutes"
        }
    }
}
