//
//  LogExperienceView.swift
//  Worth It?
//

import SwiftUI

// MARK: - Layout Constants

private enum LogFlowLayout {
    static let horizontalPadding: CGFloat = 24
    static let sectionSpacing: CGFloat = 24
    static let itemSpacing: CGFloat = 12
    static let chipSpacing: CGFloat = 8
    static let cardCornerRadius: CGFloat = 8
    static let buttonCornerRadius: CGFloat = 12
    static let progressPillWidth: CGFloat = 32
    static let progressPillHeight: CGFloat = 6
}

private enum LogFlowTypography {
    static let stepHeader = Font.system(size: 24, weight: .medium, design: .serif)
    static let subtitle = Font.body
    static let sectionLabel = Font.footnote
    static let chip = Font.system(size: 14, weight: .medium)
    static let ratingEmoji = Font.system(size: 32)
}

// MARK: - FlowLayout (wrapping chips)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        let result = computeFlow(width: width, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let width = bounds.width
        let result = computeFlow(width: width, subviews: subviews)
        for (index, point) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + point.x, y: bounds.minY + point.y),
                proposal: .unspecified
            )
        }
    }

    private func computeFlow(width: CGFloat, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        let maxWidth = width.isFinite ? width : .infinity

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            let requiredWidth = size.width + (x > 0 ? spacing : 0)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            if x > 0 { x += spacing }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width
        }
        let totalHeight = y + rowHeight
        return (CGSize(width: width, height: totalHeight), positions)
    }
}

// MARK: - Physical Rating Button (Step 3)

private struct PhysicalRatingButton: View {
    let rating: PhysicalRating
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(rating.emoji)
                    .font(.system(size: 32))
                Text(rating.displayName)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundStyle(isSelected ? AppColors.primaryForeground : AppColors.foreground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .contentShape(Rectangle())
            .background(isSelected ? AppColors.primary : AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: LogFlowLayout.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: LogFlowLayout.cardCornerRadius)
                    .stroke(isSelected ? AppColors.primary : AppColors.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Worth It Button (Step 4)

private struct WorthItButton: View {
    let option: WorthIt
    let isSelected: Bool
    let action: () -> Void
    let foreground: Color
    let background: Color

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(option.emoji)
                    .font(.system(size: 24))
                Text(option.label)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: LogFlowLayout.cardCornerRadius))
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Log Experience View (4-step flow)

struct LogExperienceView: View {
    @Environment(\.dismiss) private var dismiss
    let store: EntryStore

    @FocusState private var isTextFieldFocused: Bool
    @FocusState private var isNoteFieldFocused: Bool

    @State private var step: Int = 1
    @State private var action: String = ""
    @State private var category: EntryCategory = .other
    @State private var context: Set<TimeContext> = []
    @State private var physicalRating: PhysicalRating = .meh
    @State private var selectedEmotionTags: Set<String> = []
    @State private var worthIt: WorthIt = .meh
    @State private var note: String = ""

    private var canProceed: Bool {
        if step == 1 {
            return !action.trimmingCharacters(in: .whitespaces).isEmpty
        }
        return true
    }

    private static let quickPicks = [
        "ate junk food", "stayed up late", "skipped workout", "had coffee",
        "drank alcohol", "scrolled social media", "skipped meal",
    ]

    private static let emotionTags = [
        "regret", "tired", "anxious", "guilty", "satisfied", "energized", "calm", "stressed",
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                progressIndicator
                    .padding(.horizontal, LogFlowLayout.horizontalPadding)
                    .padding(.top, 16)
                    .padding(.bottom, 24)

                ScrollView {
                    VStack(alignment: .leading, spacing: LogFlowLayout.sectionSpacing) {
                        stepContent
                    }
                    .padding(.horizontal, LogFlowLayout.horizontalPadding)
                    .padding(.bottom, 24)
                }
                .scrollDismissesKeyboard(.interactively)

                footerButtons
                    .padding(.horizontal, LogFlowLayout.horizontalPadding)
                    .padding(.vertical, 16)
                    .background(AppColors.background)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.background)
            .ignoresSafeArea(.keyboard)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppColors.primary)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isTextFieldFocused = false
                        isNoteFieldFocused = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: Progress

    private var progressIndicator: some View {
        HStack(spacing: 4) {
            ForEach(1...4, id: \.self) { index in
                RoundedRectangle(cornerRadius: 4)
                    .fill(index <= step ? AppColors.primary : AppColors.muted)
                    .frame(width: LogFlowLayout.progressPillWidth, height: LogFlowLayout.progressPillHeight)
            }
        }
    }

    // MARK: Step content

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case 1: step1Content
        case 2: step2Content
        case 3: step3Content
        case 4: step4Content
        default: EmptyView()
        }
    }

    // Step 1: What did you do?
    private var step1Content: some View {
        VStack(alignment: .leading, spacing: LogFlowLayout.sectionSpacing) {
            stepHeader(title: "What did you do?", subtitle: "Be specific so future you can remember.")

            TextField("", text: $action, prompt: Text("e.g., ate spicy ramen at midnight").foregroundStyle(AppColors.mutedForeground))
                .textFieldStyle(.plain)
                .font(.system(size: 18))
                .foregroundStyle(AppColors.foreground)
                .padding(16)
                .background(AppColors.card)
                .clipShape(RoundedRectangle(cornerRadius: LogFlowLayout.cardCornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: LogFlowLayout.cardCornerRadius)
                        .stroke(AppColors.border, lineWidth: 1)
                )
                .focused($isTextFieldFocused)
                .submitLabel(.done)
                .onSubmit { isTextFieldFocused = false }

            VStack(alignment: .leading, spacing: LogFlowLayout.itemSpacing) {
                sectionLabel("Quick picks")
                FlowLayout(spacing: LogFlowLayout.chipSpacing) {
                    ForEach(Self.quickPicks, id: \.self) { pick in
                        Button {
                            action = pick
                        } label: {
                            Text(pick)
                                .font(LogFlowTypography.chip)
                                .foregroundStyle(action == pick ? AppColors.primaryForeground : AppColors.foreground)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .background(action == pick ? AppColors.primary : AppColors.muted)
                        .clipShape(Capsule())
                    }
                }
            }

            VStack(alignment: .leading, spacing: LogFlowLayout.itemSpacing) {
                sectionLabel("Category")
                FlowLayout(spacing: LogFlowLayout.chipSpacing) {
                    ForEach(EntryCategory.allCases, id: \.self) { cat in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { category = cat }
                        } label: {
                            HStack(spacing: 6) {
                                Text(cat.emoji)
                                Text(cat.displayName)
                                    .font(LogFlowTypography.chip)
                            }
                            .foregroundStyle(category == cat ? AppColors.primaryForeground : AppColors.foreground)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .background(category == cat ? AppColors.primary : AppColors.muted)
                        .clipShape(RoundedRectangle(cornerRadius: LogFlowLayout.cardCornerRadius))
                    }
                }
            }
        }
    }

    // Step 2: When was this?
    private var step2Content: some View {
        VStack(alignment: .leading, spacing: LogFlowLayout.sectionSpacing) {
            stepHeader(title: "When was this?", subtitle: "Context helps you remember.")

            LazyVGrid(columns: [GridItem(.flexible(), spacing: LogFlowLayout.itemSpacing), GridItem(.flexible(), spacing: LogFlowLayout.itemSpacing)], spacing: LogFlowLayout.itemSpacing) {
                ForEach(TimeContext.allCases, id: \.self) { ctx in
                    let isSelected = context.contains(ctx)
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if context.contains(ctx) {
                                context.remove(ctx)
                            } else {
                                context.insert(ctx)
                            }
                        }
                    } label: {
                        Text(ctx.displayName)
                            .font(LogFlowTypography.chip)
                            .foregroundStyle(isSelected ? AppColors.primaryForeground : AppColors.foreground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .background(isSelected ? AppColors.primary : AppColors.muted)
                    .clipShape(RoundedRectangle(cornerRadius: LogFlowLayout.cardCornerRadius))
                }
            }
        }
    }

    // Step 3: How did it feel after?
    private var step3Content: some View {
        VStack(alignment: .leading, spacing: LogFlowLayout.sectionSpacing) {
            stepHeader(title: "How did it feel after?", subtitle: "Be honest with yourself.")

            LazyVGrid(columns: [GridItem(.flexible(), spacing: LogFlowLayout.itemSpacing), GridItem(.flexible(), spacing: LogFlowLayout.itemSpacing)], spacing: LogFlowLayout.itemSpacing) {
                ForEach(PhysicalRating.allCases, id: \.self) { rating in
                    PhysicalRatingButton(
                        rating: rating,
                        isSelected: physicalRating == rating,
                        action: { withAnimation(.easeInOut(duration: 0.15)) { physicalRating = rating } }
                    )
                }
            }

            VStack(alignment: .leading, spacing: LogFlowLayout.itemSpacing) {
                sectionLabel("Emotions")
                FlowLayout(spacing: LogFlowLayout.chipSpacing) {
                    ForEach(Self.emotionTags, id: \.self) { tag in
                        let isSelected = selectedEmotionTags.contains(tag)
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if selectedEmotionTags.contains(tag) {
                                    selectedEmotionTags.remove(tag)
                                } else {
                                    selectedEmotionTags.insert(tag)
                                }
                            }
                        } label: {
                            Text(tag)
                                .font(LogFlowTypography.chip)
                                .foregroundStyle(isSelected ? AppColors.secondaryForeground : AppColors.foreground)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .background(isSelected ? AppColors.secondary : AppColors.muted)
                        .clipShape(Capsule())
                    }
                }
            }
        }
    }

    // Step 4: Was it worth it?
    private var step4Content: some View {
        VStack(alignment: .leading, spacing: LogFlowLayout.sectionSpacing) {
            stepHeader(title: "Was it worth it?", subtitle: "Would you do it again?")

            HStack(spacing: LogFlowLayout.itemSpacing) {
                ForEach(WorthIt.allCases, id: \.self) { option in
                    WorthItButton(
                        option: option,
                        isSelected: worthIt == option,
                        action: { withAnimation(.easeInOut(duration: 0.2)) { worthIt = option } },
                        foreground: worthItForeground(option),
                        background: worthItBackground(option)
                    )
                }
            }

            VStack(alignment: .leading, spacing: LogFlowLayout.itemSpacing) {
                sectionLabel("Note (optional)")
                ZStack(alignment: .topLeading) {
                    if note.isEmpty {
                        Text("e.g., Not worth the stomachache...")
                            .font(.system(size: 16))
                            .foregroundStyle(AppColors.mutedForeground)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                    }
                    TextEditor(text: $note)
                        .font(.system(size: 16))
                        .foregroundStyle(AppColors.foreground)
                        .scrollContentBackground(.hidden)
                        .padding(8)
                        .frame(minHeight: 80)
                        .focused($isNoteFieldFocused)
                }
                .background(AppColors.card)
                .clipShape(RoundedRectangle(cornerRadius: LogFlowLayout.cardCornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: LogFlowLayout.cardCornerRadius)
                        .stroke(AppColors.border.opacity(0.5), lineWidth: 1)
                )
            }
        }
    }

    private func worthItBackground(_ option: WorthIt) -> Color {
        guard worthIt == option else { return AppColors.muted }
        switch option {
        case .yes: return AppColors.secondary
        case .meh: return AppColors.accent.opacity(0.3)
        case .no: return AppColors.destructive.opacity(0.2)
        }
    }

    private func worthItForeground(_ option: WorthIt) -> Color {
        guard worthIt == option else { return AppColors.foreground }
        switch option {
        case .yes: return AppColors.secondaryForeground
        case .meh: return AppColors.foreground
        case .no: return AppColors.destructive
        }
    }

    // MARK: Shared components

    private func stepHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(LogFlowTypography.stepHeader)
                .foregroundStyle(AppColors.foreground)
            Text(subtitle)
                .font(LogFlowTypography.subtitle)
                .foregroundStyle(AppColors.mutedForeground)
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(LogFlowTypography.sectionLabel)
            .foregroundStyle(AppColors.mutedForeground)
    }

    // MARK: Footer

    private var footerButtons: some View {
        HStack(spacing: LogFlowLayout.itemSpacing) {
            if step > 1 {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { step -= 1 }
                } label: {
                    Text("Back")
                        .font(LogFlowTypography.chip)
                        .foregroundStyle(AppColors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: LogFlowLayout.buttonCornerRadius)
                        .stroke(AppColors.primary, lineWidth: 1)
                )
            }

            Button {
                if step < 4 {
                    withAnimation(.easeInOut(duration: 0.2)) { step += 1 }
                } else {
                    saveEntry()
                }
            } label: {
                HStack(spacing: 8) {
                    if step == 4 {
                        Image(systemName: "checkmark")
                        Text("Save")
                    } else {
                        Text("Next")
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                }
                .font(LogFlowTypography.chip)
                .foregroundStyle(AppColors.primaryForeground)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .background(AppColors.primary)
            .clipShape(RoundedRectangle(cornerRadius: LogFlowLayout.buttonCornerRadius))
            .opacity(canProceed ? 1 : 0.5)
            .disabled(!canProceed)
        }
    }

    // MARK: Save

    private func saveEntry() {
        let entry = Entry(
            action: action.trimmingCharacters(in: .whitespaces),
            category: category,
            context: Array(context),
            physicalRating: physicalRating,
            emotionalTags: Array(selectedEmotionTags),
            worthIt: worthIt,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        store.add(entry)
        dismiss()
    }
}

// MARK: - Preview

#Preview("Log experience") {
    LogExperienceView(store: EntryStore.preview)
}
