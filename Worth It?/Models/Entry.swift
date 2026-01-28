//
//  Entry.swift
//  Worth It?
//

import Foundation
import SwiftUI

// MARK: - Enums

enum EntryCategory: String, CaseIterable, Codable {
    case food
    case sleep
    case habit
    case social
    case other

    var displayName: String { rawValue.capitalized }

    var emoji: String {
        switch self {
        case .food: return "🍔"
        case .sleep: return "😴"
        case .habit: return "🔄"
        case .social: return "👥"
        case .other: return "📝"
        }
    }
}

enum TimeContext: String, CaseIterable, Codable {
    case morning
    case afternoon
    case evening
    case lateNight = "late-night"

    var displayName: String {
        switch self {
        case .morning: return "morning"
        case .afternoon: return "afternoon"
        case .evening: return "evening"
        case .lateNight: return "late-night"
        }
    }
}

enum PhysicalRating: String, CaseIterable, Codable {
    case fine
    case meh
    case bad
    case awful

    var displayName: String { rawValue.capitalized }

    var emoji: String {
        switch self {
        case .fine: return "😌"
        case .meh: return "😕"
        case .bad: return "😣"
        case .awful: return "🤢"
        }
    }

    var color: Color {
        switch self {
        case .fine: return WorthItColors.ratingFine
        case .meh: return WorthItColors.ratingMeh
        case .bad: return WorthItColors.ratingBad
        case .awful: return WorthItColors.ratingAwful
        }
    }
}

enum WorthIt: String, CaseIterable, Codable {
    case yes
    case meh
    case no

    var displayName: String { rawValue.capitalized }

    var emoji: String {
        switch self {
        case .yes: return "✓"
        case .meh: return "~"
        case .no: return "✗"
        }
    }

    var label: String {
        switch self {
        case .yes: return "Yes"
        case .meh: return "Meh"
        case .no: return "No"
        }
    }

    var color: Color {
        switch self {
        case .yes: return WorthItColors.worthYes
        case .meh: return WorthItColors.worthMeh
        case .no: return WorthItColors.worthNo
        }
    }

    var badgeColor: Color { color }
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

// MARK: - Date

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
