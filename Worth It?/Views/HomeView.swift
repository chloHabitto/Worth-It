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
                    .pageEntrance(delay: 0, offsetY: -10)

                    // SEARCH: px-6 mb-8
                    SearchBarView(text: $searchText)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                        .pageEntrance(delay: 0.1, offsetY: 10)

                    // LOG BUTTON: px-6 mb-8
                    LogExperienceButton(action: { showLogSheet = true })
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                        .pageEntrance(delay: 0.2, offsetY: 10)

                    // RECENT SECTION: px-6 flex-1
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent memories")
                            .font(.system(size: 18, weight: .medium, design: .serif))
                            .foregroundStyle(AppColors.foreground)
                            .pageEntrance(delay: 0.3)

                        if store.entries.isEmpty {
                            EmptyStateView(
                                icon: "sparkles",
                                title: "No memories yet",
                                description: "Start by logging your first experience. It only takes a minute.",
                                actionLabel: "Log your first experience",
                                action: { showLogSheet = true }
                            )
                            .pageEntrance(delay: 0.4, offsetY: 20)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(Array(recentToShow.enumerated()), id: \.element.id) { index, entry in
                                    NavigationLink(value: entry) {
                                        EntryCardView(entry: entry, compact: true)
                                            .contentShape(Rectangle())
                                            .interactiveScale()
                                    }
                                    .buttonStyle(.plain)
                                    .staggeredAppear(index: index, baseDelay: 0.3)
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
                EntryDetailView(entry: entry, onDelete: { store.delete(entry) }, onUpdate: { store.update(updated: $0) })
            }
            .sheet(isPresented: $showLogSheet) {
                LogExperienceView(store: store)
            }
        }
    }
}

// MARK: - Empty State (recall-resolve style)

struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    var actionLabel: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            Circle()
                .fill(AppColors.muted)
                .frame(width: 64, height: 64)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 32))
                        .foregroundStyle(AppColors.mutedForeground)
                )
                .padding(.bottom, 16)

            Text(title)
                .font(.system(size: 18, weight: .medium, design: .serif))
                .foregroundStyle(AppColors.foreground)
                .padding(.bottom, 8)

            Text(description)
                .font(.system(size: 14))
                .foregroundStyle(AppColors.mutedForeground)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
                .padding(.bottom, 24)

            if let actionLabel = actionLabel, let action = action {
                Button(action: action) {
                    Text(actionLabel)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppColors.primaryForeground)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(AppColors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(.vertical, 64)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Search Bar (compact height, muted placeholder, focus shadow, animated clear)

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

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(AppColors.mutedForeground)
                }
                .transition(.scaleIn)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isFocused ? AppColors.primary.opacity(0.5) : AppColors.border.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(isFocused ? 0.08 : 0.04), radius: isFocused ? 12 : 8, x: 0, y: 4)
        .animation(AppAnimations.fast, value: isFocused)
        .animation(AppAnimations.fast, value: text.isEmpty)
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
                        .lineLimit(compact ? 1 : 2)
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
        .contentShape(Rectangle())
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

#Preview("Home") {
    HomeView()
        .environment(EntryStore.preview)
}

#Preview("Home empty") {
    HomeView()
        .environment(EntryStore.preview)
}
