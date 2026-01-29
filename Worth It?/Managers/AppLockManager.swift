//
//  AppLockManager.swift
//  Worth It?
//
//  Translated from src/hooks/useAppLock.ts
//

import Foundation
import LocalAuthentication
import CryptoKit
import SwiftUI

@Observable
final class AppLockManager {
    // MARK: - Storage Keys
    private static let settingsKey = "worthit_lock_settings"
    private static let lastActivityKey = "worthit_last_activity"

    // MARK: - Published State
    var settings: AppLockSettings
    var isLocked: Bool = false  // Start unlocked, will be set on app ready

    // MARK: - Private State
    private var lastActivity: Date = Date()
    private var inactivityTimer: Timer?
    private var hasCheckedInitialLock = false

    // MARK: - Singleton
    static let shared = AppLockManager()

    // MARK: - Init
    init() {
        // Load settings from UserDefaults
        if let data = UserDefaults.standard.data(forKey: Self.settingsKey),
           let decoded = try? JSONDecoder().decode(AppLockSettings.self, from: data) {
            self.settings = decoded
        } else {
            self.settings = .default
        }

        // Load last activity for inactivity trigger
        let stored = UserDefaults.standard.double(forKey: Self.lastActivityKey)
        if stored > 0 {
            lastActivity = Date(timeIntervalSince1970: stored)
        }

        // DON'T lock here - wait until checkInitialLock() is called
    }

    // MARK: - Check Initial Lock (call from onAppear)
    /// Call this once when the app's main view appears
    func checkInitialLock() {
        guard !hasCheckedInitialLock else { return }
        hasCheckedInitialLock = true

        if settings.isEnabled {
            switch settings.lockTrigger {
            case .onOpen:
                isLocked = true
            case .onBackground:
                isLocked = false
            case .afterInactivity:
                let elapsed = Date().timeIntervalSince(lastActivity) / 60
                if elapsed >= Double(settings.inactivityTimeout) {
                    isLocked = true
                } else {
                    isLocked = false
                }
            }
        }

        setupInactivityTimer()
    }

    // MARK: - PIN Hashing
    // React: hashPin function
    private func hashPin(_ pin: String) -> String {
        let data = Data(pin.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    // MARK: - Settings Persistence
    private func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: Self.settingsKey)
        }
    }

    // MARK: - Enable Lock
    func enableLock(pin: String) {
        settings.pinHash = hashPin(pin)
        settings.isEnabled = true
        saveSettings()
        // Don't lock immediately after enabling - let user continue using app
    }

    // MARK: - Disable Lock
    func disableLock() {
        settings = .default
        isLocked = false
        hasCheckedInitialLock = false
        saveSettings()
        inactivityTimer?.invalidate()
        inactivityTimer = nil
    }

    // MARK: - Change PIN
    // React: changePin
    func changePin(newPin: String) {
        settings.pinHash = hashPin(newPin)
        saveSettings()
    }

    // MARK: - Toggle Biometrics
    // React: toggleBiometrics
    func toggleBiometrics(enabled: Bool) {
        settings.biometricsEnabled = enabled
        saveSettings()
    }

    // MARK: - Set Lock Trigger
    // React: setLockTrigger
    func setLockTrigger(_ trigger: LockTrigger) {
        settings.lockTrigger = trigger
        saveSettings()
        setupInactivityTimer()
    }

    // MARK: - Set Inactivity Timeout
    // React: setInactivityTimeout
    func setInactivityTimeout(_ minutes: Int) {
        settings.inactivityTimeout = minutes
        saveSettings()
        setupInactivityTimer()
    }

    // MARK: - Verify PIN
    // React: verifyPin
    func verifyPin(_ pin: String) -> Bool {
        guard let storedHash = settings.pinHash else { return false }
        return hashPin(pin) == storedHash
    }

    // MARK: - Unlock
    // React: unlock
    func unlock() {
        isLocked = false
        updateActivity()
    }

    // MARK: - Lock
    // React: lock
    func lock() {
        if settings.isEnabled {
            isLocked = true
        }
    }

    // MARK: - Update Activity
    // React: updateActivity
    func updateActivity() {
        lastActivity = Date()
        UserDefaults.standard.set(lastActivity.timeIntervalSince1970, forKey: Self.lastActivityKey)
    }

    // MARK: - Handle App State Changes
    // Called from ScenePhase changes
    func handleScenePhaseChange(from oldPhase: ScenePhase, to newPhase: ScenePhase) {
        guard settings.isEnabled else { return }

        switch settings.lockTrigger {
        case .onOpen:
            if newPhase == .background {
                isLocked = true
            }
        case .onBackground:
            // Lock when coming back from background
            if oldPhase == .background && newPhase == .active {
                lock()
            }
        case .afterInactivity:
            // Handled by timer
            break
        }

        if newPhase == .active {
            updateActivity()
        }
    }

    // MARK: - Inactivity Timer
    private func setupInactivityTimer() {
        inactivityTimer?.invalidate()
        inactivityTimer = nil

        guard settings.isEnabled && settings.lockTrigger == .afterInactivity else { return }

        // Check every 30 seconds
        inactivityTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.checkInactivity()
        }
        RunLoop.main.add(inactivityTimer!, forMode: .common)
    }

    private func checkInactivity() {
        let elapsed = Date().timeIntervalSince(lastActivity) / 60  // minutes
        if elapsed >= Double(settings.inactivityTimeout) {
            lock()
        }
    }

    // MARK: - Biometric Authentication
    func authenticateWithBiometrics() async -> Bool {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return false
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Unlock Worth It?"
            )
            return success
        } catch {
            print("Biometric auth error: \(error)")
            return false
        }
    }

    // MARK: - Check Biometrics Availability
    var isBiometricsAvailable: Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    var biometricType: LABiometryType {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return context.biometryType
    }
}
