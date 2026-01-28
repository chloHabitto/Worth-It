//
//  LibraryView.swift
//  Worth It?
//

import SwiftUI

struct LibraryView: View {
    @Environment(EntryStore.self) private var store
    @State private var selectedCategory: EntryCategory? = nil
    @State private var showLogSheet = false

    private var filteredEntries: [Entry] {
        guard let category = selectedCategory else {
            return store.recentEntries
        }
        return store.recentEntries.filter { $0.category == category }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Memory library")
                            .font(.system(size: 24, weight: .semibold, design: .serif))
                            .foregroundStyle(AppColors.foreground)
                            .padding(.horizontal, 24)
                            .pageEntrance(delay: 0, offsetY: -10)

                        // Category filter (full-width scroll, content inset 24)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                FilterChip(
                                    label: "All",
                                    isActive: selectedCategory == nil
                                ) {
                                    selectedCategory = nil
                                }
                                ForEach(EntryCategory.allCases, id: \.self) { category in
                                    FilterChip(
                                        label: "\(category.emoji) \(category.displayName)",
                                        isActive: selectedCategory == category
                                    ) {
                                        selectedCategory = category
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.bottom, 8)
                        .pageEntrance(delay: 0.05, offsetY: 10)
                    }
                    .padding(.top, 48)
                    .padding(.bottom, 24)

                    // Entries
                    VStack(alignment: .leading, spacing: 12) {
                        if !filteredEntries.isEmpty {
                            Text("\(filteredEntries.count) \(filteredEntries.count == 1 ? "memory" : "memories")")
                                .font(.system(size: 14))
                                .foregroundStyle(AppColors.mutedForeground)
                                .padding(.bottom, 4)
                                .fadeIn(delay: 0.1)

                            ForEach(Array(filteredEntries.enumerated()), id: \.element.id) { index, entry in
                                NavigationLink(value: entry) {
                                    EntryCardView(entry: entry)
                                        .interactiveScale()
                                }
                                .buttonStyle(.plain)
                                .transition(.asymmetric(insertion: .slideUp, removal: .scaleOut))
                                .staggeredAppear(index: index, baseDelay: 0.1, delayPerItem: 0.03)
                            }
                            .animation(.easeOut(duration: 0.25), value: filteredEntries.count)
                        } else {
                            EmptyStateView(
                                icon: selectedCategory == nil ? "books.vertical" : "tray",
                                title: selectedCategory == nil ? "No memories yet" : "No memories in this category",
                                description: selectedCategory == nil
                                    ? "Start logging experiences to build your memory library."
                                    : "Try selecting a different category or log a new experience.",
                                actionLabel: selectedCategory == nil ? "Log your first experience" : nil,
                                action: selectedCategory == nil ? { showLogSheet = true } : nil
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 96)
            }
            .scrollIndicators(.hidden)
            .background(AppColors.background.ignoresSafeArea())
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

// MARK: - Filter Chip

struct FilterChip: View {
    let label: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(isActive ? AppColors.primaryForeground : AppColors.foreground)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isActive ? AppColors.primary : AppColors.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 9999)
                        .stroke(AppColors.border, lineWidth: isActive ? 0 : 1)
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview("Library with entries") {
    LibraryView()
        .environment(EntryStore.preview)
}

#Preview("Library empty") {
    LibraryView()
        .environment(EntryStore.preview)
}
