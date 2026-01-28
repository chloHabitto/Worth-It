//
//  Worth_It_App.swift
//  Worth It?
//

import SwiftUI

@main
struct Worth_It_App: App {
    @State private var entryStore = EntryStore()
    @AppStorage("appTheme") private var selectedTheme: AppTheme = .system

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(entryStore)
                .preferredColorScheme(selectedTheme.colorScheme)
        }
    }
}
