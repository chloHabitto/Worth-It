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
    private var _refreshTrigger: Int = 0

    var refreshTrigger: Int { _refreshTrigger }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Fetching

    var entries: [Entry] {
        // Touch refreshTrigger so SwiftUI tracks this dependency
        _ = _refreshTrigger

        let descriptor = FetchDescriptor<Entry>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    var recentEntries: [Entry] {
        entries.filter { !$0.isHidden }.sorted { $0.createdAt > $1.createdAt }
    }

    var hiddenEntries: [Entry] {
        entries.filter { $0.isHidden }.sorted { $0.createdAt > $1.createdAt }
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

    func hide(_ entry: Entry) {
        entry.isHidden = true
        save()
    }

    func unhide(_ entry: Entry) {
        entry.isHidden = false
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
        existing.isHidden = updated.isHidden
        save()
    }

    // MARK: - Memo Operations

    func addMemo(to entry: Entry, outcome: MemoOutcome, feeling: PhysicalRating, note: String) {
        let memo = Memo(outcome: outcome, feeling: feeling, note: note)
        memo.entry = entry
        if entry.memos == nil {
            entry.memos = []
        }
        entry.memos?.append(memo)
        modelContext.insert(memo)
        save()
    }

    func updateMemo(_ memo: Memo, outcome: MemoOutcome, feeling: PhysicalRating, note: String) {
        memo.outcome = outcome
        memo.feeling = feeling
        memo.note = note
        save()
    }

    func toggleMemoStar(_ memo: Memo) {
        memo.isStarred.toggle()
        save()
    }

    func toggleMemoHidden(_ memo: Memo) {
        memo.isHidden.toggle()
        save()
    }

    func deleteMemo(_ memo: Memo) {
        modelContext.delete(memo)
        save()
    }

    // MARK: - Persistence

    private func save() {
        do {
            try modelContext.save()
            _refreshTrigger += 1
        } catch {
            print("Failed to save: \(error)")
        }
    }

    // MARK: - Preview Support

    @MainActor
    static var preview: EntryStore {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Entry.self, Memo.self, configurations: config)
        let store = EntryStore(modelContext: container.mainContext)

        // Insert sample data
        for entry in Entry.sampleEntries {
            container.mainContext.insert(entry)
        }

        return store
    }
}
