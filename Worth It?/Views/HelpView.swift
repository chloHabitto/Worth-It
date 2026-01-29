//
//  HelpView.swift
//  Worth It?
//
//  Translated from HelpPage.tsx (recall-resolve)
//

import SwiftUI

// MARK: - Quick Help Data

struct QuickHelpItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

private let quickHelpItems: [QuickHelpItem] = [
    QuickHelpItem(
        icon: "sparkles",
        title: "Getting Started",
        description: "Learn the basics of Worth It? and how to log your first memory."
    ),
    QuickHelpItem(
        icon: "book",
        title: "How Logging Works",
        description: "Capture experiences with emotions, categories, and personal notes."
    ),
    QuickHelpItem(
        icon: "hand.thumbsup",
        title: "Understanding Ratings",
        description: "What \"Worth It\", \"Meh\", and \"Not Worth It\" mean for your decisions."
    )
]

// MARK: - FAQ Data

struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

struct FAQSection: Identifiable {
    let id = UUID()
    let title: String
    let items: [FAQItem]
}

private let faqSections: [FAQSection] = [
    FAQSection(
        title: "General Questions",
        items: [
            FAQItem(
                question: "What is Worth It?",
                answer: "Worth It? is a mindful decision-making companion that helps you remember how experiences actually felt. Before repeating a behavior, you can check how it made you feel last time—helping you make better choices."
            ),
            FAQItem(
                question: "How does it help me?",
                answer: "By logging your experiences and how they made you feel, you build a personal database of memories. Next time you're about to do something, you can quickly check if it was worth it before—breaking unhelpful patterns and reinforcing positive ones."
            ),
            FAQItem(
                question: "Is my data private?",
                answer: "Absolutely. All your data is stored locally on your device. We never upload your memories to any server, and you have complete control over your information."
            )
        ]
    ),
    FAQSection(
        title: "Logging Memories",
        items: [
            FAQItem(
                question: "What should I log?",
                answer: "Log any experience you might repeat—whether it's a late-night snack, a workout, a social activity, or a purchase. Focus on things where knowing \"was it worth it?\" would help you decide next time."
            ),
            FAQItem(
                question: "Can I edit or delete entries?",
                answer: "Yes! Tap any memory to view its details, then tap the pencil icon to edit any field. You can also delete entries from the detail view if needed."
            ),
            FAQItem(
                question: "What are categories for?",
                answer: "Categories help organize your memories and make searching easier. You can filter by category to see patterns in specific areas of your life, like Food, Sleep, Social, or Habits."
            )
        ]
    ),
    FAQSection(
        title: "Data & Privacy",
        items: [
            FAQItem(
                question: "Where is my data stored?",
                answer: "All data stays on your device in local storage. We never upload your memories to any server, ensuring complete privacy."
            ),
            FAQItem(
                question: "How do I export my data?",
                answer: "Go to Account → Data & Privacy → Export My Data. This downloads a JSON file with all your memories that you can save or transfer."
            ),
            FAQItem(
                question: "Can I backup my memories?",
                answer: "Currently, you can export your data as a JSON file for backup. We recommend doing this periodically to ensure you don't lose your memories if you reset your device."
            )
        ]
    ),
    FAQSection(
        title: "Tips & Best Practices",
        items: [
            FAQItem(
                question: "When's the best time to log?",
                answer: "Log experiences immediately after they happen, when feelings are fresh. The more accurate your emotional recall, the more helpful the entry will be for future decisions."
            ),
            FAQItem(
                question: "How to get the most out of Worth It?",
                answer: "Be honest with your ratings, add descriptive notes, and most importantly—check your past entries before repeating behaviors. The app works best when it becomes part of your decision-making process."
            )
        ]
    )
]

// MARK: - Help View

struct HelpView: View {
    @State private var searchQuery: String = ""
    @State private var expandedItems: Set<String> = []
    
    private var filteredSections: [FAQSection] {
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else {
            return faqSections
        }
        
        let query = searchQuery.lowercased()
        return faqSections.compactMap { section in
            let filteredItems = section.items.filter { item in
                item.question.lowercased().contains(query) ||
                item.answer.lowercased().contains(query)
            }
            
            guard !filteredItems.isEmpty else { return nil }
            return FAQSection(title: section.title, items: filteredItems)
        }
    }
    
    private var hasResults: Bool {
        !filteredSections.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    searchBarSection
                    
                    if searchQuery.isEmpty {
                        quickHelpSection
                    }
                    
                    faqSection
                    
                    stillNeedHelpSection
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 96)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .background(AppColors.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Help & FAQ")
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .foregroundStyle(AppColors.foreground)
                }
            }
        }
    }
    
    // MARK: - Search Bar Section
    
    private var searchBarSection: some View {
        SearchBarView(text: $searchQuery, placeholder: "Search help topics...")
            .padding(.top, 16)
            .pageEntrance(delay: 0.05, offsetY: 10)
    }
    
    // MARK: - Quick Help Section
    
    private var quickHelpSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Help")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppColors.mutedForeground)
                .padding(.leading, 4)
            
            VStack(spacing: 12) {
                ForEach(Array(quickHelpItems.enumerated()), id: \.element.id) { index, item in
                    QuickHelpCard(item: item)
                        .pageEntrance(delay: 0.1 + Double(index) * 0.05, offsetY: 10)
                }
            }
        }
        .pageEntrance(delay: 0.1, offsetY: 10)
    }
    
    // MARK: - FAQ Section
    
    private var faqSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(searchQuery.isEmpty ? "Frequently Asked Questions" : "Search Results")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppColors.mutedForeground)
                .padding(.leading, 4)
            
            if !hasResults {
                noResultsView
            } else {
                VStack(spacing: 16) {
                    ForEach(filteredSections) { section in
                        FAQSectionCard(
                            section: section,
                            expandedItems: $expandedItems
                        )
                    }
                }
            }
        }
        .pageEntrance(delay: searchQuery.isEmpty ? 0.3 : 0.1, offsetY: 10)
    }
    
    private var noResultsView: some View {
        VStack(spacing: 16) {
            Text("No results found for \"\(searchQuery)\"")
                .font(.system(size: 14))
                .foregroundStyle(AppColors.mutedForeground)
                .multilineTextAlignment(.center)
            
            Button {
                searchQuery = ""
            } label: {
                Text("Clear search")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppColors.primary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, 24)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.border.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: AppShadows.soft, radius: AppShadows.softRadius, x: 0, y: AppShadows.softY)
    }
    
    // MARK: - Still Need Help Section
    
    private var stillNeedHelpSection: some View {
        VStack(spacing: 16) {
            Text("Still need help?")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColors.foreground)
            
            Text("Can't find what you're looking for? We're here to help.")
                .font(.system(size: 14))
                .foregroundStyle(AppColors.mutedForeground)
                .multilineTextAlignment(.center)
            
            Button {
                if let url = URL(string: "mailto:support@worthitapp.com") {
                    UIApplication.shared.open(url)
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "envelope")
                        .font(.system(size: 16))
                    Text("Contact Us")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundStyle(AppColors.primaryForeground)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(AppColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            LinearGradient(
                colors: [
                    AppColors.primary.opacity(0.1),
                    AppColors.accent.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.primary.opacity(0.2), lineWidth: 1)
        )
        .pageEntrance(delay: 0.4, offsetY: 10)
    }
}

// MARK: - Quick Help Card

struct QuickHelpCard: View {
    let item: QuickHelpItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Circle()
                .fill(AppColors.primary.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: item.icon)
                        .font(.system(size: 18))
                        .foregroundStyle(AppColors.primary)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppColors.foreground)
                
                Text(item.description)
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.mutedForeground)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.border.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: AppShadows.soft, radius: AppShadows.softRadius, x: 0, y: AppShadows.softY)
    }
}

// MARK: - FAQ Section Card

struct FAQSectionCard: View {
    let section: FAQSection
    @Binding var expandedItems: Set<String>
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(section.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.foreground)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AppColors.muted.opacity(0.3))
            
            Divider()
                .background(AppColors.border.opacity(0.5))
            
            VStack(spacing: 0) {
                ForEach(Array(section.items.enumerated()), id: \.element.id) { index, item in
                    FAQAccordionItem(
                        item: item,
                        isExpanded: expandedItems.contains(item.id.uuidString),
                        onToggle: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                if expandedItems.contains(item.id.uuidString) {
                                    expandedItems.remove(item.id.uuidString)
                                } else {
                                    expandedItems.insert(item.id.uuidString)
                                }
                            }
                        }
                    )
                    
                    if index < section.items.count - 1 {
                        Divider()
                            .background(AppColors.border.opacity(0.5))
                            .padding(.horizontal, 16)
                    }
                }
            }
        }
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.border.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: AppShadows.soft, radius: AppShadows.softRadius, x: 0, y: AppShadows.softY)
    }
}

// MARK: - FAQ Accordion Item

struct FAQAccordionItem: View {
    let item: FAQItem
    let isExpanded: Bool
    let onToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onToggle) {
                HStack {
                    Text(item.question)
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.foreground)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppColors.mutedForeground)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(16)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                Text(item.answer)
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.mutedForeground)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

// MARK: - Preview

#Preview {
    HelpView()
}
