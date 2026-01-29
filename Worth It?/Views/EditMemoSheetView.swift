//
//  EditMemoSheetView.swift
//  Worth It?
//

import SwiftUI

struct EditMemoSheetView: View {
    let memo: Memo
    let onSave: (MemoOutcome, PhysicalRating, String) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var outcome: MemoOutcome
    @State private var feeling: PhysicalRating
    @State private var note: String
    @FocusState private var isNoteFocused: Bool

    init(memo: Memo, onSave: @escaping (MemoOutcome, PhysicalRating, String) -> Void) {
        self.memo = memo
        self.onSave = onSave
        _outcome = State(initialValue: memo.outcome)
        _feeling = State(initialValue: memo.feeling)
        _note = State(initialValue: memo.note)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppColors.mutedForeground)
                        .frame(width: 32, height: 32)
                        .background(AppColors.muted)
                        .clipShape(Circle())
                }

                Spacer()

                Text("Edit Memo")
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundStyle(AppColors.foreground)

                Spacer()

                Button {
                    onSave(outcome, feeling, note.trimmingCharacters(in: .whitespacesAndNewlines))
                    dismiss()
                } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppColors.primaryForeground)
                        .frame(width: 32, height: 32)
                        .background(AppColors.primary)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)

            Divider()
                .background(AppColors.border.opacity(0.5))

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Outcome section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What happened?")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppColors.foreground)

                        VStack(spacing: 8) {
                            ForEach(MemoOutcome.allCases, id: \.self) { opt in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        outcome = opt
                                    }
                                } label: {
                                    HStack(spacing: 12) {
                                        Text(opt.emoji)
                                            .font(.system(size: 20))
                                        Text(opt.label)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundStyle(outcome == opt ? AppColors.primaryForeground : AppColors.foreground)
                                        Spacer()
                                        if outcome == opt {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundStyle(AppColors.primaryForeground)
                                        }
                                    }
                                    .padding(12)
                                    .background(outcome == opt ? AppColors.primary : AppColors.card)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(outcome == opt ? AppColors.primary : AppColors.border, lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // Feeling section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How did it feel?")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppColors.foreground)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            ForEach(PhysicalRating.allCases, id: \.self) { rating in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        feeling = rating
                                    }
                                } label: {
                                    VStack(spacing: 4) {
                                        Text(rating.emoji)
                                            .font(.system(size: 24))
                                        Text(rating.displayName)
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundStyle(feeling == rating ? AppColors.primaryForeground : AppColors.foreground)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(feeling == rating ? AppColors.primary : AppColors.card)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(feeling == rating ? AppColors.primary : AppColors.border, lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // Note section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Note (optional)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppColors.foreground)

                        TextEditor(text: $note)
                            .font(.system(size: 16))
                            .foregroundStyle(AppColors.foreground)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 80)
                            .padding(12)
                            .background(AppColors.card)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .inputFocusStyle(isFocused: isNoteFocused, cornerRadius: 12)
                            .focused($isNoteFocused)
                    }
                }
                .padding(24)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        }
        .background(AppColors.background.ignoresSafeArea())
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
    }
}

// MARK: - Preview

#Preview {
    Text("Trigger")
        .sheet(isPresented: .constant(true)) {
            EditMemoSheetView(
                memo: Memo(outcome: .resisted, feeling: .fine, note: "Felt good about it!")
            ) { outcome, feeling, note in
                print("Saved: \(outcome), \(feeling), \(note)")
            }
        }
}
