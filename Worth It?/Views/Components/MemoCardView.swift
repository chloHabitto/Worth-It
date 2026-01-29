//
//  MemoCardView.swift
//  Worth It?
//

import SwiftUI

struct MemoCardView: View {
    let memo: Memo
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onToggleStar: () -> Void
    let onToggleHide: () -> Void

    @State private var showDeleteAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header row
            HStack {
                // Outcome badge
                HStack(spacing: 6) {
                    Text(memo.outcome.emoji)
                        .font(.system(size: 16))
                    Text(memo.outcome.label)
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundStyle(memo.outcome == .resisted ? AppColors.secondary : AppColors.foreground)

                Spacer()

                // Feeling indicator
                HStack(spacing: 4) {
                    Text(memo.feeling.emoji)
                        .font(.system(size: 16))
                    Text(memo.feeling.displayName)
                        .font(.system(size: 12))
                        .foregroundStyle(AppColors.mutedForeground)
                }

                // Menu
                Menu {
                    Button {
                        onEdit()
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }

                    Button {
                        onToggleStar()
                    } label: {
                        Label(memo.isStarred ? "Unstar" : "Star",
                              systemImage: memo.isStarred ? "star.slash" : "star")
                    }

                    Button {
                        onToggleHide()
                    } label: {
                        Label(memo.isHidden ? "Show" : "Hide",
                              systemImage: memo.isHidden ? "eye" : "eye.slash")
                    }

                    Divider()

                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.mutedForeground)
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
            }

            // Note
            if !memo.note.isEmpty {
                Text("\"\(memo.note)\"")
                    .font(.system(size: 14))
                    .italic()
                    .foregroundStyle(AppColors.foreground)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Timestamp
            Text(memo.createdAt, style: .relative)
                .font(.system(size: 12))
                .foregroundStyle(AppColors.mutedForeground)
        }
        .padding(16)
        .background(memo.isStarred ? Color.yellow.opacity(0.05) : AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(memo.isStarred ? Color.yellow.opacity(0.3) : AppColors.border.opacity(0.5), lineWidth: 1)
        )
        .opacity(memo.isHidden ? 0.5 : 1)
        .alert("Delete this memo?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("This cannot be undone.")
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 12) {
        MemoCardView(
            memo: Memo(outcome: .resisted, feeling: .fine, note: "Felt proud of myself!"),
            onEdit: {},
            onDelete: {},
            onToggleStar: {},
            onToggleHide: {}
        )

        MemoCardView(
            memo: Memo(outcome: .didAgain, feeling: .bad, note: "Regret it again...", isStarred: true),
            onEdit: {},
            onDelete: {},
            onToggleStar: {},
            onToggleHide: {}
        )
    }
    .padding()
    .background(AppColors.background)
}
