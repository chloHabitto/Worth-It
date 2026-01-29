//
//  AddMemoSheetView.swift
//  Worth It?
//

import SwiftUI

struct AddMemoSheetView: View {
    let actionName: String
    let onAdd: (MemoOutcome, PhysicalRating, String) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var step: Step = .outcome
    @State private var outcome: MemoOutcome? = nil
    @State private var feeling: PhysicalRating? = nil
    @State private var note: String = ""

    private enum Step: Int {
        case outcome = 1
        case feeling = 2
        case note = 3
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            sheetHeader

            Divider()
                .background(AppColors.border.opacity(0.5))

            // Content
            ScrollView {
                VStack(spacing: 24) {
                    stepContent
                }
                .padding(24)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        }
        .background(AppColors.background.ignoresSafeArea())
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
    }

    // MARK: - Header

    private var sheetHeader: some View {
        VStack(spacing: 8) {
            // Progress indicator
            HStack(spacing: 6) {
                ForEach(1...3, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(i <= step.rawValue ? AppColors.primary : AppColors.muted)
                        .frame(width: 32, height: 6)
                }
            }
            .padding(.top, 8)

            Text(stepTitle)
                .font(.system(size: 20, weight: .semibold, design: .serif))
                .foregroundStyle(AppColors.foreground)

            Text("Following up on: \(actionName)")
                .font(.system(size: 14))
                .foregroundStyle(AppColors.mutedForeground)
                .lineLimit(1)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
    }

    private var stepTitle: String {
        switch step {
        case .outcome: return "What happened?"
        case .feeling: return "How did it feel?"
        case .note: return "Any thoughts?"
        }
    }

    // MARK: - Step Content

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case .outcome:
            outcomeStep
        case .feeling:
            feelingStep
        case .note:
            noteStep
        }
    }

    // MARK: - Outcome Step

    private var outcomeStep: some View {
        VStack(spacing: 12) {
            ForEach(MemoOutcome.allCases, id: \.self) { opt in
                Button {
                    outcome = opt
                    withAnimation(.easeInOut(duration: 0.25)) {
                        step = .feeling
                    }
                } label: {
                    HStack(spacing: 16) {
                        Text(opt.emoji)
                            .font(.system(size: 28))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(opt.label)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(AppColors.foreground)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppColors.mutedForeground)
                    }
                    .padding(16)
                    .background(AppColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.border, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }

    // MARK: - Feeling Step

    private var feelingStep: some View {
        VStack(spacing: 20) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(PhysicalRating.allCases, id: \.self) { rating in
                    Button {
                        feeling = rating
                        withAnimation(.easeInOut(duration: 0.25)) {
                            step = .note
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Text(rating.emoji)
                                .font(.system(size: 36))
                            Text(rating.displayName)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(AppColors.foreground)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(AppColors.card)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    step = .outcome
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .medium))
                    Text("Back")
                        .font(.system(size: 14))
                }
                .foregroundStyle(AppColors.mutedForeground)
            }
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }

    // MARK: - Note Step

    private var noteStep: some View {
        VStack(spacing: 24) {
            // Summary of selections
            HStack(spacing: 16) {
                if let outcome = outcome {
                    HStack(spacing: 6) {
                        Text(outcome.emoji)
                            .font(.system(size: 20))
                        Text(outcome.label)
                            .font(.system(size: 14, weight: .medium))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppColors.muted)
                    .clipShape(Capsule())
                }

                if let feeling = feeling {
                    HStack(spacing: 6) {
                        Text(feeling.emoji)
                            .font(.system(size: 20))
                        Text(feeling.displayName)
                            .font(.system(size: 14, weight: .medium))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppColors.muted)
                    .clipShape(Capsule())
                }
            }

            // Note input
            VStack(alignment: .leading, spacing: 8) {
                Text("Note (optional)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppColors.foreground)

                TextEditor(text: $note)
                    .font(.system(size: 16))
                    .foregroundStyle(AppColors.foreground)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 100)
                    .padding(12)
                    .background(AppColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.border, lineWidth: 1)
                    )
            }

            // Actions
            VStack(spacing: 12) {
                Button {
                    if let outcome = outcome, let feeling = feeling {
                        onAdd(outcome, feeling, note.trimmingCharacters(in: .whitespacesAndNewlines))
                        dismiss()
                    }
                } label: {
                    Text("Save memo")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AppColors.primaryForeground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppColors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)

                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        step = .feeling
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 12, weight: .medium))
                        Text("Back")
                            .font(.system(size: 14))
                    }
                    .foregroundStyle(AppColors.mutedForeground)
                }
            }
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }
}

// MARK: - Preview

#Preview {
    Text("Trigger")
        .sheet(isPresented: .constant(true)) {
            AddMemoSheetView(actionName: "Had spicy ramen at night") { outcome, feeling, note in
                print("Added: \(outcome), \(feeling), \(note)")
            }
        }
}
