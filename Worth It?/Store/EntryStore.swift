//
//  EntryStore.swift
//  Worth It?
//

import Foundation

@Observable
final class EntryStore {
    var entries: [Entry] = []

    init(entries: [Entry] = []) {
        self.entries = entries.isEmpty ? EntryStore.sampleEntries : entries
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
        entries.append(entry)
    }

    func delete(_ entry: Entry) {
        entries.removeAll { $0.id == entry.id }
    }

    func delete(ids: Set<UUID>) {
        entries.removeAll { ids.contains($0.id) }
    }

    private static var sampleEntries: [Entry] {
        [
            Entry(
                action: "Had spicy ramen at night",
                category: .food,
                context: [.lateNight],
                physicalRating: .bad,
                emotionalTags: ["regret", "tired"],
                worthIt: .no,
                note: "My stomach hurt all night",
                createdAt: Date().addingTimeInterval(-840)
            ),
            Entry(
                action: "Late-night snack",
                category: .food,
                context: [.lateNight],
                physicalRating: .meh,
                emotionalTags: ["tired", "bored"],
                worthIt: .no,
                note: "Felt worse after.",
                createdAt: Date().addingTimeInterval(-3600)
            ),
            Entry(
                action: "Morning run",
                category: .habit,
                context: [.morning],
                physicalRating: .fine,
                emotionalTags: ["energized"],
                worthIt: .yes,
                note: "20 min, felt great.",
                createdAt: Date().addingTimeInterval(-86400)
            ),
            Entry(
                action: "Coffee with a friend",
                category: .social,
                context: [.afternoon],
                physicalRating: .fine,
                emotionalTags: ["happy", "connected"],
                worthIt: .yes,
                createdAt: Date().addingTimeInterval(-172800)
            ),
        ]
    }
}
