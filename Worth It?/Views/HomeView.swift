//
//  HomeView.swift
//  Worth It?
//

import SwiftUI

struct HomeView: View {
    @Environment(EntryStore.self) private var store
    @State private var searchText = ""
    @State private var showLogExperience = false

    private var filteredEntries: [Entry] {
        store.entries(matching: searchText)
    }

    private var recentToShow: [Entry] {
        Array(filteredEntries.prefix(10))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    searchSection
                    logButtonSection
                    recentSection
                }
                .padding(.horizontal, WorthItLayout.horizontalPadding)
                .padding(.top, 8)
                .padding(.bottom, 100)
            }
            .scrollIndicators(.hidden)
            .background(WorthItColors.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showLogExperience) {
                LogExperienceView(store: store)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Worth It?")
                .font(.system(size: 36, weight: .bold, design: .serif))
                .foregroundStyle(WorthItColors.primary)
            Text("Before you do it again… remember.")
                .font(WorthItTheme.calloutFont)
                .foregroundStyle(WorthItColors.mutedForeground)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 12)
    }

    // MARK: - Search

    private var searchSection: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(WorthItColors.mutedForeground)
            TextField("How did I feel after...", text: $searchText)
                .font(WorthItTheme.bodyFont)
        }
        .padding(16)
        .background(WorthItColors.card)
        .clipShape(RoundedRectangle(cornerRadius: WorthItLayout.cornerRadius))
        .shadow(
            color: WorthItShadows.soft,
            radius: WorthItShadows.softRadius,
            x: 0,
            y: WorthItShadows.softY
        )
    }

    // MARK: - Log experience button

    private var logButtonSection: some View {
        Button {
            showLogExperience = true
        } label: {
            HStack(spacing: 16) {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text("Log an experience")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text("Quick & easy, under 60 seconds")
                        .font(.subheadline)
                        .opacity(0.8)
                }
                Spacer()
            }
            .foregroundStyle(.white)
            .padding(16)
            .background(WorthItColors.primary)
            .clipShape(RoundedRectangle(cornerRadius: WorthItLayout.buttonCornerRadius))
            .shadow(
                color: WorthItShadows.glow,
                radius: WorthItShadows.glowRadius,
                x: 0,
                y: 4
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Recent entries

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent memories")
                .font(.system(size: 18, weight: .medium, design: .serif))
                .foregroundStyle(WorthItColors.foreground)

            if recentToShow.isEmpty {
                Text("No entries yet. Log an experience to see it here.")
                    .font(WorthItTheme.subheadlineFont)
                    .foregroundStyle(WorthItColors.mutedForeground)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 16)
                    .worthItCard()
            } else {
                VStack(spacing: 10) {
                    ForEach(recentToShow) { entry in
                        NavigationLink(value: entry) {
                            EntryCardView(entry: entry)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .navigationDestination(for: Entry.self) { entry in
            EntryDetailView(entry: entry, onDelete: { store.delete(entry) })
        }
    }
}

// MARK: - Entry card

struct EntryCardView: View {
    let entry: Entry
    var compact: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // LEFT SIDE: Emoji + Text Content
            VStack(alignment: .leading, spacing: 4) {
                // Row 1: Category emoji + ACTION TEXT
                HStack(alignment: .top, spacing: 8) {
                    Text(entry.category.emoji)
                        .font(.title3)

                    Text(entry.action)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(WorthItColors.cardForeground)
                        .lineLimit(compact ? 1 : 2)
                }

                // Row 2: Time context + relative time
                HStack(spacing: 4) {
                    if let firstContext = entry.context.first {
                        Text(firstContext.displayName)
                    }
                    Text("·")
                    Text(entry.createdAt.timeAgoDisplay())
                }
                .font(.subheadline)
                .foregroundStyle(WorthItColors.mutedForeground)
            }

            Spacer(minLength: 8)

            // RIGHT SIDE: Rating emoji + Worth badge
            VStack(alignment: .trailing, spacing: 6) {
                Text(entry.physicalRating.emoji)
                    .font(.title2)

                WorthBadgeView(worthIt: entry.worthIt)
            }
        }
        .padding(WorthItLayout.cardPadding)
        .background(WorthItColors.card)
        .clipShape(RoundedRectangle(cornerRadius: WorthItLayout.cardCornerRadius))
        .shadow(
            color: WorthItShadows.soft,
            radius: WorthItShadows.softRadius,
            x: 0,
            y: WorthItShadows.softY
        )
    }
}

// MARK: - Worth badge (✓ Yes / ~ Meh / ✗ No)

struct WorthBadgeView: View {
    let worthIt: WorthIt

    var body: some View {
        HStack(spacing: 2) {
            Text(worthIt.emoji)
            Text(worthIt.label)
        }
        .font(.caption)
        .fontWeight(.medium)
        .foregroundStyle(worthIt.color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(worthIt.color.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: WorthItLayout.badgeCornerRadius))
    }
}

// MARK: - Placeholder for LogExperienceView (4-step flow next)

struct LogExperienceView: View {
    @Environment(\.dismiss) private var dismiss
    let store: EntryStore

    var body: some View {
        NavigationStack {
            VStack {
                Text("Log experience")
                    .font(WorthItTheme.title2Font)
                Text("4-step flow placeholder — to be built next.")
                    .font(WorthItTheme.bodyFont)
                    .foregroundStyle(WorthItTheme.muted)
                Spacer()
                Button("Done") { dismiss() }
                    .font(WorthItTheme.headlineFont)
                    .foregroundStyle(WorthItTheme.coral)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(WorthItTheme.background)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(WorthItTheme.coral)
                }
            }
        }
    }
}

#Preview("Home") {
    HomeView()
        .environment(EntryStore())
}
