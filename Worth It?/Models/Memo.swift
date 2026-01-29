//
//  Memo.swift
//  Worth It?
//
//  Follow-up memo for tracking decisions over time
//

import Foundation
import SwiftData

// MARK: - Memo Outcome Enum

enum MemoOutcome: String, CaseIterable, Codable {
    case didAgain = "did-again"
    case resisted = "resisted"
    case reflecting = "reflecting"
    case other = "other"

    var emoji: String {
        switch self {
        case .didAgain: return "🔄"
        case .resisted: return "💪"
        case .reflecting: return "💭"
        case .other: return "📝"
        }
    }

    var label: String {
        switch self {
        case .didAgain: return "Did it again"
        case .resisted: return "Resisted"
        case .reflecting: return "Still thinking"
        case .other: return "Other"
        }
    }
}

// MARK: - Memo Model

@Model
final class Memo {
    var id: UUID = UUID()
    var outcomeRaw: String = "did-again"
    var feelingRaw: String = "meh"
    var note: String = ""
    var createdAt: Date = Date()
    var isStarred: Bool = false
    var isHidden: Bool = false

    // MARK: - Relationship to Entry
    var entry: Entry?

    // MARK: - Computed Properties

    var outcome: MemoOutcome {
        get { MemoOutcome(rawValue: outcomeRaw) ?? .didAgain }
        set { outcomeRaw = newValue.rawValue }
    }

    var feeling: PhysicalRating {
        get { PhysicalRating(rawValue: feelingRaw) ?? .meh }
        set { feelingRaw = newValue.rawValue }
    }

    // MARK: - Initializer

    init(
        id: UUID = UUID(),
        outcome: MemoOutcome = .didAgain,
        feeling: PhysicalRating = .meh,
        note: String = "",
        createdAt: Date = Date(),
        isStarred: Bool = false,
        isHidden: Bool = false
    ) {
        self.id = id
        self.outcomeRaw = outcome.rawValue
        self.feelingRaw = feeling.rawValue
        self.note = note
        self.createdAt = createdAt
        self.isStarred = isStarred
        self.isHidden = isHidden
    }
}
