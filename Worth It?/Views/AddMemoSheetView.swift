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
    @FocusState private var isNoteFocused: Bool

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
                .padding(.bottom, 16)
            }
            .scrollIndicators(.hidden)
        }
        .background(AppColors.background.ignoresSafeArea())
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
    }

    // MARK: - Header

    private var sheetHeader: some View {
        VStack(spacing: 12) {
            // Top row: Close button + Title
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

                Color.clear
                    .frame(width: 32, height: 32)
            }

            Text(stepTitle)
                .font(.system(size: 20, weight: .semibold, design: .serif))
                .foregroundStyle(AppColors.foreground)

            Text("Following up on: \(actionName)")
                .font(.system(size: 14))
                .foregroundStyle(AppColors.mutedForeground)
                .lineLimit(1)

            HStack(spacing: 6) {
                ForEach(1...3, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(i <= step.rawValue ? AppColors.primary : AppColors.muted)
                        .frame(width: 32, height: 6)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    private var stepTitle: String {
        switch step {
        case .outcome: return "What happened?"
        case .feeling: return "How did it feel?"
        case .note: return "Any thoughts?"
        }
    }

    private var canProceed: Bool {
        switch step {
        case .outcome:
            return outcome != nil
        case .feeling:
            return feeling != nil
        case .note:
            return outcome != nil && feeling != nil
        }
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: 12) {
            if step != .outcome {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        if step == .feeling {
                            step = .outcome
                        } else if step == .note {
                            step = .feeling
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .medium))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundStyle(AppColors.foreground)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.border, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }

            Button {
                if step == .note {
                    if let outcome = outcome, let feeling = feeling {
                        onAdd(outcome, feeling, note.trimmingCharacters(in: .whitespacesAndNewlines))
                        dismiss()
                    }
                } else {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        if step == .outcome {
                            step = .feeling
                        } else if step == .feeling {
                            step = .note
                        }
                    }
                }
            } label: {
                Text(step == .note ? "Save" : "Next")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(canProceed ? AppColors.primaryForeground : AppColors.mutedForeground)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(canProceed ? AppColors.primary : AppColors.muted)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .disabled(!canProceed)
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
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                ForEach(MemoOutcome.allCases, id: \.self) { opt in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            outcome = opt
                        }
                    } label: {
                        HStack(spacing: 16) {
                            Text(opt.emoji)
                                .font(.system(size: 28))

                            Text(opt.label)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(outcome == opt ? AppColors.primaryForeground : AppColors.foreground)

                            Spacer()

                            if outcome == opt {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(AppColors.primaryForeground)
                            }
                        }
                        .padding(16)
                        .background(outcome == opt ? AppColors.primary : AppColors.card)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(outcome == opt ? AppColors.primary : AppColors.border, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            Button {
                outcome = .other
                feeling = .meh
                withAnimation(.easeInOut(duration: 0.25)) {
                    step = .note
                }
            } label: {
                HStack(spacing: 4) {
                    Text("Skip to note")
                        .font(.system(size: 14))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundStyle(AppColors.mutedForeground)
            }
            .padding(.top, 4)

            navigationButtons
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
                        withAnimation(.easeInOut(duration: 0.15)) {
                            feeling = rating
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Text(rating.emoji)
                                .font(.system(size: 36))
                            Text(rating.displayName)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(feeling == rating ? AppColors.primaryForeground : AppColors.foreground)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(feeling == rating ? AppColors.primary : AppColors.card)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(feeling == rating ? AppColors.primary : AppColors.border, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            navigationButtons
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }

    // MARK: - Note Step

    private var noteStep: some View {
        VStack(spacing: 24) {
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
                    .inputFocusStyle(isFocused: isNoteFocused, cornerRadius: 12)
                    .focused($isNoteFocused)
            }

            navigationButtons
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
