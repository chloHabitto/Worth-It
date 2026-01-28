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
                .font(WorthItTheme.titleFont)
                .fontWeight(.semibold)
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
            TextField("Search experiences…", text: $searchText)
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
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                Text("Log experience")
                    .font(WorthItTheme.headlineFont)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(WorthItTheme.coral)
            .clipShape(RoundedRectangle(cornerRadius: WorthItTheme.cornerRadius))
            .shadow(
                color: WorthItTheme.coral.opacity(0.35),
                radius: 10,
                x: 0,
                y: 4
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Recent entries

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent")
                .font(WorthItTheme.title3Font)
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
                            HomeEntryRow(entry: entry)
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

// MARK: - Row

struct HomeEntryRow: View {
    let entry: Entry

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            WorthItBadge(value: entry.worthIt)
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.action)
                    .font(WorthItTheme.bodyFont)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                HStack(spacing: 6) {
                    Text(entry.category.displayName)
                        .font(WorthItTheme.footnoteFont)
                        .foregroundStyle(WorthItTheme.muted)
                    if let first = entry.context.first {
                        Text("·")
                            .foregroundStyle(WorthItTheme.muted)
                        Text(first.displayName)
                            .font(WorthItTheme.footnoteFont)
                            .foregroundStyle(WorthItTheme.muted)
                    }
                }
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(WorthItTheme.muted)
        }
        .padding(16)
        .worthItCard()
    }
}

// MARK: - Worth-it badge

struct WorthItBadge: View {
    let value: WorthIt

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 10, height: 10)
    }

    private var color: Color {
        switch value {
        case .yes: return Color.green
        case .meh: return Color.orange
        case .no: return WorthItTheme.coral
        }
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
