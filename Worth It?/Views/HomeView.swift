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
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 100)
            }
            .scrollIndicators(.hidden)
            .background(WorthItTheme.background)
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
                .foregroundStyle(WorthItTheme.coral)
            Text("Before you do it again… remember.")
                .font(WorthItTheme.calloutFont)
                .foregroundStyle(WorthItTheme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 12)
    }

    // MARK: - Search

    private var searchSection: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(WorthItTheme.muted)
            TextField("How did I feel after...", text: $searchText)
                .font(WorthItTheme.bodyFont)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(WorthItTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: WorthItTheme.cornerRadius))
        .shadow(
            color: .black.opacity(WorthItTheme.cardShadowOpacity),
            radius: WorthItTheme.cardShadowRadius,
            x: 0,
            y: WorthItTheme.cardShadowY
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
            .background(WorthItTheme.coral)
            .clipShape(RoundedRectangle(cornerRadius: WorthItTheme.cornerRadius))
            .shadow(
                color: WorthItTheme.coral.opacity(0.3),
                radius: 12,
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
                .foregroundStyle(.primary)

            if recentToShow.isEmpty {
                Text("No entries yet. Log an experience to see it here.")
                    .font(WorthItTheme.subheadlineFont)
                    .foregroundStyle(WorthItTheme.muted)
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

// MARK: - Entry card (reference design)

struct EntryCardView: View {
    let entry: Entry

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(entry.category.emoji)
                        .font(.title3)
                    Text(entry.action)
                        .font(.headline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .foregroundStyle(.primary)
                }
                HStack(spacing: 4) {
                    Text(entry.context.first?.displayName ?? "")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("·")
                        .foregroundStyle(.secondary)
                    Text(entry.createdAt.timeAgoDisplay())
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 0)
            VStack(alignment: .trailing, spacing: 4) {
                Text(entry.physicalRating.emoji)
                    .font(.title2)
                WorthBadge(worthIt: entry.worthIt)
            }
        }
        .padding(16)
        .background(WorthItTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Worth badge (✓ Yes / ~ Meh / ✗ No)

struct WorthBadge: View {
    let worthIt: WorthIt

    var body: some View {
        HStack(spacing: 2) {
            Text(worthIt.emoji)
            Text(worthIt.label)
        }
        .font(.caption)
        .fontWeight(.medium)
        .foregroundStyle(worthIt.badgeColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(worthIt.badgeColor.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
