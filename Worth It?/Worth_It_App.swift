//
//  Worth_It_App.swift
//  Worth It?
//
//  Main app entry with SwiftData + iCloud sync
//

import SwiftUI
import SwiftData
import LocalAuthentication

@main
struct Worth_It_App: App {
    @State private var lockManager = AppLockManager.shared
    @State private var toastManager = ToastManager.shared
    @State private var showSplash = true
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("appTheme") private var selectedTheme: AppTheme = .system

    // SwiftData container with CloudKit sync
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Entry.self, Memo.self])

        // Configure for iCloud sync
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .private("iCloud.com.chloe-lee.Worth-It")
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environment(lockManager)
                    .environment(toastManager)
                    .toastContainer()
                    .preferredColorScheme(selectedTheme.colorScheme)

                if showSplash {
                    SplashScreenView()
                        .transition(.opacity)
                        .zIndex(200)
                }

                if lockManager.settings.isEnabled && lockManager.isLocked {
                    LockScreenView(
                        onUnlock: { lockManager.unlock() },
                        verifyPin: { lockManager.verifyPin($0) },
                        biometricsEnabled: lockManager.settings.biometricsEnabled,
                        biometricType: lockManager.biometricType,
                        onBiometricAuth: { await lockManager.authenticateWithBiometrics() }
                    )
                    .transition(.opacity)
                    .zIndex(100)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: lockManager.isLocked)
            .animation(.easeOut(duration: 0.4), value: showSplash)
            .onAppear {
                lockManager.checkInitialLock()
                Task {
                    try? await Task.sleep(for: .seconds(2))
                    showSplash = false
                }
            }
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { oldPhase, newPhase in
            lockManager.handleScenePhaseChange(from: oldPhase, to: newPhase)
        }
    }
}
