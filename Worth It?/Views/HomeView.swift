//
//  HomeView.swift
//  Worth It?
//

import SwiftUI

struct HomeView: View {
    @Environment(EntryStore.self) private var store
    @State private var searchText = ""
    @State private var showLogSheet = false

    private var filteredEntries: [Entry] {
        store.entries(matching: searchText)
    }

    private var recentToShow: [Entry] {
        Array(filteredEntries.prefix(10))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // HEADER: px-6 pt-12 pb-6
                    VStack(alignment: .leading, spacing: 4) {
                        // text-3xl font-serif font-semibold — NOTE: semibold NOT italic
                        Text("Worth It?")
                            .font(.system(size: 30, weight: .semibold, design: .serif))
                            .foregroundStyle(AppColors.foreground)

                        Text("Before you do it again… remember.")
                            .font(.body)
                            .foregroundStyle(AppColors.mutedForeground)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 48)
                    .padding(.bottom, 24)

                    // SEARCH: px-6 mb-8
                    SearchBarView(text: $searchText)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)

                    // LOG BUTTON: px-6 mb-8
                    LogExperienceButton(action: { showLogSheet = true })
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)

                    // RECENT SECTION: px-6 flex-1
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent memories")
                            .font(.system(size: 18, weight: .medium, design: .serif))
                            .foregroundStyle(AppColors.foreground)

                        if recentToShow.isEmpty {
                            Text("No entries yet. Log an experience to see it here.")
                                .font(.system(size: 14))
                                .foregroundStyle(AppColors.mutedForeground)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 20)
                                .padding(.horizontal, 16)
                                .background(AppColors.card)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(AppColors.border.opacity(0.5), lineWidth: 1)
                                )
                        } else {
                            VStack(spacing: 12) {
                                ForEach(recentToShow) { entry in
                                    NavigationLink(value: entry) {
                                        EntryCardView(entry: entry, compact: true)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 96)
            }
            .scrollIndicators(.hidden)
            .background(AppColors.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Entry.self) { entry in
                EntryDetailView(entry: entry, onDelete: { store.delete(entry) })
            }
            .sheet(isPresented: $showLogSheet) {
                LogExperienceView(store: store)
            }
        }
    }
}

// MARK: - Search Bar (compact height, muted placeholder, focus shadow)

struct SearchBarView: View {
    @Binding var text: String
    var placeholder: String = "How did I feel after..."
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 20))
                .foregroundStyle(isFocused ? AppColors.primary : AppColors.mutedForeground)

            TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(AppColors.mutedForeground))
                .font(.system(size: 16))
                .foregroundStyle(AppColors.foreground)
                .focused($isFocused)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.border.opacity(0.5), lineWidth: 1)
        )
        .shadow(
            color: isFocused ? AppShadows.medium : AppShadows.soft,
            radius: isFocused ? AppShadows.mediumRadius : AppShadows.softRadius,
            x: 0,
            y: isFocused ? AppShadows.mediumY : AppShadows.softY
        )
    }
}

// MARK: - Log Experience Button (w-full gap-4 p-5 bg-primary rounded-xl shadow-glow)

struct LogExperienceButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Circle()
                    .fill(AppColors.primaryForeground.opacity(0.2))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(AppColors.primaryForeground)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("Log an experience")
                        .font(.system(size: 18, weight: .medium))
                    Text("Quick & easy, under 60 seconds")
                        .font(.system(size: 14))
                        .opacity(0.7)
                }

                Spacer()
            }
            .foregroundStyle(AppColors.primaryForeground)
            .padding(20)
            .background(AppColors.primary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: AppColors.primary.opacity(0.15), radius: 40, x: 0, y: 0)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Entry Card (exact Tailwind translation: action text as headline)

struct EntryCardView: View {
    let entry: Entry
    var compact: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 8) {
                    Text(entry.category.emoji)
                        .font(.system(size: 18))

                    Text(entry.action)
                        .font(.system(size: compact ? 14 : 16, weight: .medium))
                        .foregroundStyle(AppColors.foreground)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .padding(.bottom, 4)

                HStack(spacing: 8) {
                    Text(entry.context.map { $0.displayName }.joined(separator: " · "))
                    Text("·")
                    Text(entry.createdAt.timeAgoDisplay())
                }
                .font(.system(size: 12))
                .foregroundStyle(AppColors.mutedForeground)
                .padding(.bottom, 8)
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 6) {
                Text(entry.physicalRating.emoji)
                    .font(.system(size: 24))

                WorthBadge(worthIt: entry.worthIt)
            }
        }
        .padding(compact ? 12 : 16)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppColors.border.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 4)
    }
}

// MARK: - Worth Badge (yes=secondary, meh=accent/20, no=destructive/10)

struct WorthBadge: View {
    let worthIt: WorthIt

    var backgroundColor: Color {
        switch worthIt {
        case .yes: return AppColors.secondary
        case .meh: return AppColors.accent.opacity(0.2)
        case .no: return AppColors.destructive.opacity(0.1)
        }
    }

    var textColor: Color {
        switch worthIt {
        case .yes: return AppColors.secondaryForeground
        case .meh: return AppColors.foreground
        case .no: return AppColors.destructive
        }
    }

    var body: some View {
        HStack(spacing: 2) {
            Text(worthIt.emoji)
            Text(worthIt.label)
        }
        .font(.system(size: 12, weight: .medium))
        .foregroundStyle(textColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
        .background(backgroundColor)
        .clipShape(Capsule())
    }
}

// MARK: - Log Experience (placeholder)

struct LogExperienceView: View {
    @Environment(\.dismiss) private var dismiss
    let store: EntryStore

    var body: some View {
        NavigationStack {
            VStack {
                Text("Log experience")
                    .font(.system(size: 22, weight: .medium, design: .serif))
                Text("4-step flow placeholder — to be built next.")
                    .font(.body)
                    .foregroundStyle(AppColors.mutedForeground)
                Spacer()
                Button("Done") { dismiss() }
                    .font(.headline)
                    .foregroundStyle(AppColors.primary)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.background)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppColors.primary)
                }
            }
        }
    }
}

#Preview("Home") {
    HomeView()
        .environment(EntryStore())
}
