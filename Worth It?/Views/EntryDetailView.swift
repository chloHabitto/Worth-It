//
//  EntryDetailView.swift
//  Worth It?
//

import SwiftUI

struct EntryDetailView: View {
    let entry: Entry
    var onDelete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirm = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerBlock
                detailBlock
                if !entry.note.isEmpty { noteBlock }
                deleteButton
            }
            .padding(20)
            .padding(.bottom, 40)
        }
        .background(AppColors.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Back") { dismiss() }
                    .foregroundStyle(AppColors.primary)
            }
        }
        .confirmationDialog("Delete this entry?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                onDelete()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This cannot be undone.")
        }
    }

    private var headerBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            WorthBadge(worthIt: entry.worthIt)
            Text(entry.action)
                .font(.system(size: 22, weight: .medium, design: .serif))
                .foregroundStyle(AppColors.foreground)
            Text(entry.createdAt, style: .date)
                .font(.footnote)
                .foregroundStyle(AppColors.mutedForeground)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .worthItCard()
    }

    private var detailBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            DetailRow(label: "Category", value: entry.category.displayName)
            if !entry.context.isEmpty {
                DetailRow(
                    label: "Time",
                    value: entry.context.map(\.displayName).joined(separator: ", ")
                )
            }
            DetailRow(label: "Physical", value: entry.physicalRating.displayName)
            if !entry.emotionalTags.isEmpty {
                DetailRow(
                    label: "Tags",
                    value: entry.emotionalTags.joined(separator: ", ")
                )
            }
        }
        .padding(16)
        .worthItCard()
    }

    private var noteBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Note")
                .font(.headline)
                .foregroundStyle(AppColors.foreground)
            Text(entry.note)
                .font(.body)
                .foregroundStyle(AppColors.mutedForeground)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .worthItCard()
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            showDeleteConfirm = true
        } label: {
            Label("Delete entry", systemImage: "trash")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.footnote)
                .foregroundStyle(AppColors.mutedForeground)
                .frame(width: 80, alignment: .leading)
            Text(value)
                .font(.body)
                .foregroundStyle(AppColors.foreground)
            Spacer(minLength: 0)
        }
    }
}

#Preview {
    NavigationStack {
        EntryDetailView(
            entry: Entry(
                action: "Late-night snack",
                category: .food,
                context: [.lateNight],
                physicalRating: .meh,
                emotionalTags: ["tired", "bored"],
                worthIt: .no,
                note: "Felt worse after."
            ),
            onDelete: {}
        )
    }
}
