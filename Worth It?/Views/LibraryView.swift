//
//  LibraryView.swift
//  Worth It?
//

import SwiftUI

struct LibraryView: View {
    @Environment(EntryStore.self) private var store
    @State private var selectedCategory: EntryCategory? = nil
    @State private var showLogSheet = false
    @State private var selectedEntry: Entry? = nil
    @State private var entryToDelete: Entry? = nil
    @State private var showDeleteConfirmation = false

    private var filteredEntries: [Entry] {
        guard let category = selectedCategory else {
            return store.recentEntries
        }
        return store.recentEntries.filter { $0.category == category }
    }

    var body: some View {
        NavigationStack {
            List {
                // Header
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Memory library")
                            .font(.system(size: 24, weight: .semibold, design: .serif))
                            .foregroundStyle(AppColors.foreground)
                            .pageEntrance(delay: 0, offsetY: -10)

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
                        }
                        .padding(.bottom, 8)
                        .pageEntrance(delay: 0.05, offsetY: 10)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 48, leading: 24, bottom: 24, trailing: 24))
                }

                if filteredEntries.isEmpty {
                    Section {
                        EmptyStateView(
                            icon: selectedCategory == nil ? "books.vertical" : "tray",
                            title: selectedCategory == nil ? "No memories yet" : "No memories in this category",
                            description: selectedCategory == nil
                                ? "Start logging experiences to build your memory library."
                                : "Try selecting a different category or log a new experience.",
                            actionLabel: selectedCategory == nil ? "Log your first experience" : nil,
                            action: selectedCategory == nil ? { showLogSheet = true } : nil
                        )
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
                    }
                } else {
                    Section {
                        Text("\(filteredEntries.count) \(filteredEntries.count == 1 ? "memory" : "memories")")
                            .font(.system(size: 14))
                            .foregroundStyle(AppColors.mutedForeground)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 0, leading: 24, bottom: 4, trailing: 24))

                        ForEach(filteredEntries) { entry in
                            Button {
                                selectedEntry = entry
                            } label: {
                                EntryCardView(entry: entry)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 24, bottom: 6, trailing: 24))
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    entryToDelete = entry
                                    showDeleteConfirmation = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    store.hide(entry)
                                } label: {
                                    Label("Hide", systemImage: "eye.slash")
                                }
                                .tint(AppColors.mutedForeground)
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .background(AppColors.background.ignoresSafeArea())
            .padding(.bottom, 96)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(item: $selectedEntry) { entry in
                EntryDetailView(entry: entry, onDelete: { store.delete(entry) }, onUpdate: { store.update(updated: $0) })
            }
            .sheet(isPresented: $showLogSheet) {
                LogExperienceView(store: store)
            }
            .alert("Delete memory?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { entryToDelete = nil }
                Button("Delete", role: .destructive) {
                    if let entry = entryToDelete {
                        store.delete(entry)
                    }
                    entryToDelete = nil
                }
            } message: {
                Text("This memory will be permanently deleted. This action cannot be undone.")
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
