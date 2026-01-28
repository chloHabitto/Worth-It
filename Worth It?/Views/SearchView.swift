//
//  SearchView.swift
//  Worth It?
//

import SwiftUI

struct SearchView: View {
    @Environment(EntryStore.self) private var store
    @State private var query: String = ""
    @State private var selectedEntry: Entry? = nil

    private var results: [Entry] {
        store.entries(matching: query)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                    resultsSection
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 96)
            }
            .scrollIndicators(.hidden)
            .background(AppColors.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Entry.self) { entry in
                EntryDetailView(entry: entry, onDelete: { store.delete(entry) })
            }
        }
        .sheet(item: $selectedEntry) { entry in
            DecisionMomentView(
                entry: entry,
                onSkip: { selectedEntry = nil },
                onDoAnyway: { selectedEntry = nil },
                onClose: { selectedEntry = nil }
            )
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Search memories")
                .font(.system(size: 24, weight: .semibold, design: .serif))
                .foregroundStyle(AppColors.foreground)
                .pageEntrance(delay: 0, offsetY: -10)

            SearchBarView(text: $query, placeholder: "How did I feel after...")
        }
        .padding(.top, 48)
        .padding(.bottom, 24)
    }

    // MARK: - Content States

    private var resultsSection: some View {
        Group {
            if query.trimmingCharacters(in: .whitespaces).isEmpty {
                emptyQueryState
            } else if results.isEmpty {
                noResultsState
            } else {
                hasResultsState
            }
        }
    }

    private var emptyQueryState: some View {
        VStack(spacing: 16) {
            Circle()
                .fill(AppColors.muted)
                .frame(width: 64, height: 64)
                .overlay(
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 32))
                        .foregroundStyle(AppColors.mutedForeground)
                )

            Text("Search for past experiences like 'coffee late night' or 'skipped workout'")
                .font(.system(size: 14))
                .foregroundStyle(AppColors.mutedForeground)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .fadeIn(delay: 0.1)
    }

    private var noResultsState: some View {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "No matches",
            description: "No memories match '\(query)'."
        )
        .pageEntrance(delay: 0.1, offsetY: 20)
    }

    private var hasResultsState: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(results.count) memories found")
                .font(.system(size: 14))
                .foregroundStyle(AppColors.mutedForeground)
                .padding(.bottom, 4)

            ForEach(Array(results.enumerated()), id: \.element.id) { index, entry in
                Button {
                    selectedEntry = entry
                } label: {
                    EntryCardView(entry: entry, compact: false)
                        .interactiveScale()
                }
                .buttonStyle(.plain)
                .staggeredAppear(index: index, baseDelay: 0, delayPerItem: 0.05)
            }
        }
        .transition(.opacity)
        .animation(.easeOut(duration: 0.2), value: results.count)
    }
}

// MARK: - Decision Moment View

struct DecisionMomentView: View {
    let entry: Entry
    let onSkip: () -> Void
    let onDoAnyway: () -> Void
    let onClose: () -> Void

    @Environment(\.dismiss) private var dismiss

    private var bgGradient: LinearGradient {
        let startColor: Color
        switch entry.worthIt {
        case .yes: startColor = AppColors.secondary.opacity(0.2)
        case .meh: startColor = AppColors.accent.opacity(0.1)
        case .no: startColor = AppColors.destructive.opacity(0.1)
        }
        return LinearGradient(
            colors: [startColor, AppColors.background],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var worthLabel: String {
        switch entry.worthIt {
        case .yes: return "Worth it"
        case .meh: return "Meh"
        case .no: return "Not worth it"
        }
    }

    private var worthColor: Color {
        switch entry.worthIt {
        case .yes: return AppColors.secondaryForeground
        case .meh: return AppColors.foreground
        case .no: return AppColors.destructive
        }
    }

    var body: some View {
        ZStack {
            bgGradient.ignoresSafeArea()
                .transition(.opacity)

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button {
                        onClose()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(AppColors.foreground)
                            .padding(8)
                            .background(AppColors.muted)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)

                Spacer()

                VStack(spacing: 24) {
                    Text(entry.physicalRating.emoji)
                        .font(.system(size: 64))
                        .fadeIn(delay: 0.1)

                    HStack(spacing: 4) {
                        Text(entry.category.emoji)
                        Text(entry.context.map { $0.displayName }.joined(separator: " · "))
                        Text("·")
                        Text(entry.createdAt.timeAgoDisplay())
                    }
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.mutedForeground)
                    .fadeIn(delay: 0.2)

                    Text(entry.action)
                        .font(.system(size: 24, weight: .medium, design: .serif))
                        .foregroundStyle(AppColors.foreground)
                        .multilineTextAlignment(.center)
                        .fadeIn(delay: 0.3)

                    HStack(spacing: 4) {
                        Text(entry.worthIt.emoji)
                        Text(worthLabel)
                    }
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(worthColor)
                    .fadeIn(delay: 0.4)

                    if !entry.note.isEmpty {
                        Text("\"\(entry.note)\"")
                            .font(.system(size: 16))
                            .italic()
                            .foregroundStyle(AppColors.mutedForeground)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .fadeIn(delay: 0.45)
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        onSkip()
                        dismiss()
                    } label: {
                        Text("I'll skip it")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(AppColors.primaryForeground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppColors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button {
                        onDoAnyway()
                        dismiss()
                    } label: {
                        Text("Do it anyway")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(AppColors.foreground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppColors.card)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppColors.border, lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
                .pageEntrance(delay: 0.5, offsetY: 40)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Previews

#Preview("Search - Empty") {
    SearchView()
        .environment(EntryStore())
}

#Preview("Search - With Results") {
    SearchView()
        .environment(EntryStore.preview)
}

#Preview("Decision Moment") {
    DecisionMomentView(
        entry: Entry.sampleEntries[0],
        onSkip: {},
        onDoAnyway: {},
        onClose: {}
    )
}
