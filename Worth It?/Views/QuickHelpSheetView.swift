//
//  QuickHelpSheetView.swift
//  Worth It?
//

import SwiftUI

// MARK: - Help Topic Enum

enum HelpTopic: String, CaseIterable, Identifiable {
    case gettingStarted = "getting-started"
    case logging = "logging"
    case ratings = "ratings"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .gettingStarted: return "sparkles"
        case .logging: return "book"
        case .ratings: return "hand.thumbsup"
        }
    }
    
    var title: String {
        switch self {
        case .gettingStarted: return "Getting Started"
        case .logging: return "How Logging Works"
        case .ratings: return "Understanding Ratings"
        }
    }
    
    var description: String {
        switch self {
        case .gettingStarted: return "Learn the basics of Worth It? and how to log your first memory."
        case .logging: return "Capture experiences with emotions, categories, and personal notes."
        case .ratings: return "What \"Worth It\", \"Meh\", and \"Not Worth It\" mean for your decisions."
        }
    }
}

// MARK: - Help Section Data

struct HelpSection: Identifiable {
    let id = UUID()
    let heading: String
    let content: String
}

// MARK: - Help Content

private let helpContent: [HelpTopic: [HelpSection]] = [
    .gettingStarted: [
        HelpSection(
            heading: "Welcome to Worth It?",
            content: "Worth It? helps you make better decisions by remembering how experiences actually felt. Before repeating a behavior, check how it made you feel last time."
        ),
        HelpSection(
            heading: "Your First Memory",
            content: "Tap the + button on the home screen to log your first experience. Describe what you did, how it felt, and whether it was worth it."
        ),
        HelpSection(
            heading: "The Core Loop",
            content: "Log → Search → Decide. Log experiences after they happen. Search your memories before repeating behaviors. Make better choices based on real feelings."
        ),
        HelpSection(
            heading: "Build the Habit",
            content: "The more you log, the more useful Worth It? becomes. Try logging at least one experience per day for the first week."
        )
    ],
    .logging: [
        HelpSection(
            heading: "What to Log",
            content: "Log any experience you might repeat—late-night snacks, workouts, social activities, purchases. Focus on things where knowing \"was it worth it?\" helps you decide next time."
        ),
        HelpSection(
            heading: "The 4 Steps",
            content: "1. What did you do? — Name the action\n2. Context — When did it happen?\n3. How did it feel? — Physical state + emotions\n4. Worth it? — Yes, Meh, or No"
        ),
        HelpSection(
            heading: "Be Honest",
            content: "Log how you actually felt, not how you think you should have felt. Honest entries lead to better future decisions."
        ),
        HelpSection(
            heading: "Add Notes",
            content: "Use the notes field to capture details you'll want to remember. \"Felt tired the next morning\" or \"Best decision I made all week\" adds context."
        )
    ],
    .ratings: [
        HelpSection(
            heading: "Worth It ✓",
            content: "You'd do it again. The experience was positive overall and you're glad it happened. This doesn't mean it was perfect—just that it was worthwhile."
        ),
        HelpSection(
            heading: "Meh ~",
            content: "It was okay, but not memorable. You neither regret it nor feel great about it. Useful for identifying things that aren't really adding value."
        ),
        HelpSection(
            heading: "Not Worth It ✗",
            content: "You wish you hadn't done it. Maybe it felt good in the moment but bad afterward, or maybe it just wasn't what you hoped. Next time, you'll think twice."
        ),
        HelpSection(
            heading: "No Wrong Answers",
            content: "Ratings are personal. A \"Not Worth It\" for you might be \"Worth It\" for someone else. What matters is building your own personal reference guide."
        )
    ]
]

// MARK: - Quick Help Sheet View

struct QuickHelpSheetView: View {
    let topic: HelpTopic
    @Environment(\.dismiss) private var dismiss
    
    private var sections: [HelpSection] {
        helpContent[topic] ?? []
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            sheetHeader
            
            // Divider below header
            Divider()
                .background(AppColors.border.opacity(0.5))
            
            // Scrollable Content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(Array(sections.enumerated()), id: \.element.id) { index, section in
                        HelpSectionView(section: section)
                            .pageEntrance(delay: Double(index) * 0.1, offsetY: 10)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 48)
            }
            .scrollIndicators(.hidden)
        }
        .background(AppColors.background.ignoresSafeArea())
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
    }
    
    // MARK: - Custom Sheet Header
    
    private var sheetHeader: some View {
        HStack(spacing: 12) {
            // Icon + Title (NOT a button, just a display)
            Circle()
                .fill(AppColors.primary.opacity(0.1))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: topic.icon)
                        .font(.system(size: 20))
                        .foregroundStyle(AppColors.primary)
                )
            
            Text(topic.title)
                .font(.system(size: 20, weight: .semibold, design: .serif))
                .foregroundStyle(AppColors.foreground)
            
            Spacer()
            
            // Close Button
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppColors.mutedForeground)
                    .frame(width: 32, height: 32)
                    .background(AppColors.muted)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
}

// MARK: - Help Section View

struct HelpSectionView: View {
    let section: HelpSection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(section.heading)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColors.foreground)
            
            Text(section.content)
                .font(.system(size: 14))
                .foregroundStyle(AppColors.mutedForeground)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    QuickHelpSheetView(topic: .gettingStarted)
}
