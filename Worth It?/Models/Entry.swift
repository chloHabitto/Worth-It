//
//  Entry.swift
//  Worth It?
//

import Foundation

// MARK: - Enums

enum EntryCategory: String, CaseIterable, Codable {
    case food
    case sleep
    case habit
    case social
    case other

    var displayName: String { rawValue.capitalized }
}

enum TimeContext: String, CaseIterable, Codable {
    case morning
    case afternoon
    case evening
    case lateNight = "late-night"

    var displayName: String {
        switch self {
        case .lateNight: return "Late night"
        default: return rawValue.capitalized
        }
    }
}

enum PhysicalRating: String, CaseIterable, Codable {
    case fine
    case meh
    case bad
    case awful

    var displayName: String { rawValue.capitalized }
}

enum WorthIt: String, CaseIterable, Codable {
    case yes
    case meh
    case no

    var displayName: String { rawValue.capitalized }
}

// MARK: - Entry

struct Entry: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var action: String
    var category: EntryCategory
    var context: [TimeContext]
    var physicalRating: PhysicalRating
    var emotionalTags: [String]
    var worthIt: WorthIt
    var note: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        action: String,
        category: EntryCategory,
        context: [TimeContext],
        physicalRating: PhysicalRating,
        emotionalTags: [String] = [],
        worthIt: WorthIt,
        note: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.action = action
        self.category = category
        self.context = context
        self.physicalRating = physicalRating
        self.emotionalTags = emotionalTags
        self.worthIt = worthIt
        self.note = note
        self.createdAt = createdAt
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
