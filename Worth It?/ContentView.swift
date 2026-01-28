//
//  ContentView.swift
//  Worth It?
//
//  Root view that bridges SwiftData to EntryStore
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var entryStore: EntryStore?

    var body: some View {
        Group {
            if let store = entryStore {
                MainTabView()
                    .environment(store)
            } else {
                ProgressView()
                    .onAppear {
                        entryStore = EntryStore(modelContext: modelContext)
                    }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Entry.self, inMemory: true)
}
