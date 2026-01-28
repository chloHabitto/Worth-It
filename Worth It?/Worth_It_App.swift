//
//  Worth_It_App.swift
//  Worth It?
//
//  Created by Chloe Lee on 2026-01-28.
//

import SwiftUI

@main
struct Worth_It_App: App {
    @State private var entryStore = EntryStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(entryStore)
        }
    }
}
