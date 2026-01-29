//
//  HiddenMemoriesView.swift
//  Worth It?
//
//  Lists hidden entries; user can unhide from here.
//

import SwiftUI

struct HiddenMemoriesView: View {
    @Environment(EntryStore.self) private var store
    @State private var selectedEntry: Entry? = nil

    private var hiddenEntries: [Entry] {
        store.hiddenEntries
    }

    var body: some View {
        Group {
            if hiddenEntries.isEmpty {
                ContentUnavailableView(
                    "No hidden memories",
                    systemImage: "eye.slash",
                    description: Text("Memories you hide will appear here. Unhide them to show again in your library.")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppColors.background.ignoresSafeArea())
            } else {
                List {
                    ForEach(hiddenEntries) { entry in
                        Button {
                            selectedEntry = entry
                        } label: {
                            EntryCardView(entry: entry, compact: true)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 24, bottom: 6, trailing: 24))
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button {
                                store.unhide(entry)
                            } label: {
                                Label("Unhide", systemImage: "eye")
                            }
                            .tint(AppColors.primary)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(AppColors.background.ignoresSafeArea())
            }
        }
        .navigationTitle("Hidden memories")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedEntry) { entry in
            EntryDetailView(entry: entry, onDelete: { store.delete(entry) }, onUpdate: { store.update(updated: $0) })
        }
    }
}

#Preview {
    NavigationStack {
        HiddenMemoriesView()
            .environment(EntryStore.preview)
    }
}
