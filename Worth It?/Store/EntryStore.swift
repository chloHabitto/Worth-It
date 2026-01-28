//
//  EntryStore.swift
//  Worth It?
//

import Foundation

@Observable
final class EntryStore {
    var entries: [Entry] = []

    init(entries: [Entry] = []) {
        self.entries = entries
    }

    /// Use only in SwiftUI previews — production app starts with empty entries.
    static var preview: EntryStore {
        let store = EntryStore()
        store.entries = Entry.sampleEntries
        return store
    }

    var recentEntries: [Entry] {
        entries.sorted { $0.createdAt > $1.createdAt }
    }

    func entries(matching query: String) -> [Entry] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return recentEntries }
        let q = query.lowercased()
        return recentEntries.filter {
            $0.action.lowercased().contains(q) ||
            $0.category.rawValue.lowercased().contains(q) ||
            $0.emotionalTags.contains { $0.lowercased().contains(q) } ||
            $0.note.lowercased().contains(q)
        }
    }

    func add(_ entry: Entry) {
        entries.insert(entry, at: 0)
    }

    func delete(_ entry: Entry) {
        entries.removeAll { $0.id == entry.id }
    }

    func delete(ids: Set<UUID>) {
        entries.removeAll { ids.contains($0.id) }
    }
}
