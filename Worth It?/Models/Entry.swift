//
//  Entry.swift
//  Worth It?
//
//  SwiftData model with iCloud sync support
//

import Foundation
import SwiftUI
import SwiftData

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

// MARK: - Entry (SwiftData Model)

@Model
final class Entry {
    var id: UUID = UUID()
    var action: String = ""
    var categoryRaw: String = "other"
    var contextRaw: [String] = []
    var physicalRatingRaw: String = "meh"
    var emotionalTags: [String] = []
    var worthItRaw: String = "meh"
    var note: String = ""
    var createdAt: Date = Date()
    var isHidden: Bool = false

    // MARK: - Computed Properties for Type-Safe Access

    var category: EntryCategory {
        get { EntryCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    var context: [TimeContext] {
        get { contextRaw.compactMap { TimeContext(rawValue: $0) } }
        set { contextRaw = newValue.map(\.rawValue) }
    }

    var physicalRating: PhysicalRating {
        get { PhysicalRating(rawValue: physicalRatingRaw) ?? .meh }
        set { physicalRatingRaw = newValue.rawValue }
    }

    var worthIt: WorthIt {
        get { WorthIt(rawValue: worthItRaw) ?? .meh }
        set { worthItRaw = newValue.rawValue }
    }

    // MARK: - Memos Relationship
    @Relationship(deleteRule: .cascade, inverse: \Memo.entry)
    var memos: [Memo]? = nil

    // MARK: - Initializer

    init(
        id: UUID = UUID(),
        action: String,
        category: EntryCategory,
        context: [TimeContext],
        physicalRating: PhysicalRating,
        emotionalTags: [String] = [],
        worthIt: WorthIt,
        note: String = "",
        createdAt: Date = Date(),
        isHidden: Bool = false
    ) {
        self.id = id
        self.action = action
        self.categoryRaw = category.rawValue
        self.contextRaw = context.map(\.rawValue)
        self.physicalRatingRaw = physicalRating.rawValue
        self.emotionalTags = emotionalTags
        self.worthItRaw = worthIt.rawValue
        self.note = note
        self.createdAt = createdAt
        self.isHidden = isHidden
    }
}

// MARK: - Sample data (previews only)

extension Entry {
    static var sampleEntries: [Entry] {
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

// MARK: - Date Extension

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    /// Returns a short relative time string without showing seconds
    /// Examples: "just now", "2m ago", "1h ago", "3d ago", "2w ago"
    func timeAgoShort() -> String {
        let now = Date()
        let components = Calendar.current.dateComponents(
            [.year, .month, .weekOfYear, .day, .hour, .minute],
            from: self,
            to: now
        )

        if let years = components.year, years > 0 {
            return "\(years)y ago"
        }
        if let months = components.month, months > 0 {
            return "\(months)mo ago"
        }
        if let weeks = components.weekOfYear, weeks > 0 {
            return "\(weeks)w ago"
        }
        if let days = components.day, days > 0 {
            return "\(days)d ago"
        }
        if let hours = components.hour, hours > 0 {
            return "\(hours)h ago"
        }
        if let minutes = components.minute, minutes > 0 {
            return "\(minutes)m ago"
        }
        return "just now"
    }
}
