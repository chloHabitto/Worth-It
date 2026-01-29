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
        HStack(alignment: .top, spacing: 12) {
            // Star indicator (left side, only if starred)
            if memo.isStarred {
                Image(systemName: "star.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.yellow)
                    .padding(.top, 2)
            }

            // Main content
            VStack(alignment: .leading, spacing: 8) {
                // Top row: outcome, feeling, hidden badge, time, menu
                HStack(alignment: .center, spacing: 8) {
                    // Outcome emoji and label
                    Text(memo.outcome.emoji)
                        .font(.system(size: 18))
                    Text(memo.outcome.label)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppColors.foreground)

                    // Feeling emoji
                    Text(memo.feeling.emoji)
                        .font(.system(size: 18))

                    // Hidden badge
                    if memo.isHidden {
                        Text("Hidden")
                            .font(.system(size: 11))
                            .foregroundStyle(AppColors.mutedForeground)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(AppColors.muted)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }

                    Spacer()

                    // Time (without seconds)
                    Text(memo.createdAt.timeAgoShort())
                        .font(.system(size: 12))
                        .foregroundStyle(AppColors.mutedForeground)
                }

                // Note (if exists)
                if !memo.note.isEmpty {
                    Text("\"\(memo.note)\"")
                        .font(.system(size: 14))
                        .italic()
                        .foregroundStyle(AppColors.mutedForeground)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Menu button (right side)
            Menu {
                Button {
                    onToggleStar()
                } label: {
                    Label(
                        memo.isStarred ? "Unstar" : "Star as important",
                        systemImage: memo.isStarred ? "star.slash" : "star"
                    )
                }

                Button {
                    onEdit()
                } label: {
                    Label("Edit", systemImage: "pencil")
                }

                Button {
                    onToggleHide()
                } label: {
                    Label(
                        memo.isHidden ? "Show" : "Hide",
                        systemImage: memo.isHidden ? "eye" : "eye.slash"
                    )
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
        .padding(16)
        .background(memo.isStarred ? Color.yellow.opacity(0.05) : AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(memo.isStarred ? Color.yellow.opacity(0.3) : AppColors.border.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: AppShadows.soft, radius: AppShadows.softRadius, x: 0, y: AppShadows.softY)
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

        MemoCardView(
            memo: Memo(outcome: .reflecting, feeling: .meh, note: "", isHidden: true),
            onEdit: {},
            onDelete: {},
            onToggleStar: {},
            onToggleHide: {}
        )
    }
    .padding()
    .background(AppColors.background)
}
