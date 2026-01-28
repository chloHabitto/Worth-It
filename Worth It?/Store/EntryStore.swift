//
//  EntryStore.swift
//  Worth It?
//
//  Thin wrapper around SwiftData for shared access pattern
//

import Foundation
import SwiftData

@Observable
final class EntryStore {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Fetching

    var entries: [Entry] {
        let descriptor = FetchDescriptor<Entry>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    var recentEntries: [Entry] {
        entries
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

    // MARK: - Mutations

    func add(_ entry: Entry) {
        modelContext.insert(entry)
        save()
    }

    func delete(_ entry: Entry) {
        modelContext.delete(entry)
        save()
    }

    func delete(ids: Set<UUID>) {
        for entry in entries where ids.contains(entry.id) {
            modelContext.delete(entry)
        }
        save()
    }

    func update(updated: Entry) {
        guard let existing = entries.first(where: { $0.id == updated.id }) else { return }
        existing.action = updated.action
        existing.category = updated.category
        existing.context = updated.context
        existing.physicalRating = updated.physicalRating
        existing.emotionalTags = updated.emotionalTags
        existing.worthIt = updated.worthIt
        existing.note = updated.note
        save()
    }

    // MARK: - Persistence

    private func save() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save: \(error)")
        }
    }

    // MARK: - Preview Support

    @MainActor
    static var preview: EntryStore {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Entry.self, configurations: config)
        let store = EntryStore(modelContext: container.mainContext)

        // Insert sample data
        for entry in Entry.sampleEntries {
            container.mainContext.insert(entry)
        }

        return store
    }
}
