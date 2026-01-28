//
//  Worth_It_App.swift
//  Worth It?
//
//  Main app entry with SwiftData + iCloud sync
//

import SwiftUI
import SwiftData

@main
struct Worth_It_App: App {
    @AppStorage("appTheme") private var selectedTheme: AppTheme = .system

    // SwiftData container with CloudKit sync
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Entry.self])

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
            ContentView()
                .preferredColorScheme(selectedTheme.colorScheme)
        }
        .modelContainer(sharedModelContainer)
    }
}
