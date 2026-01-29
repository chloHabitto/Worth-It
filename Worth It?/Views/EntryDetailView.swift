//
//  EntryDetailView.swift
//  Worth It?
//

import SwiftUI

/// Wrapper so we can use .sheet(item:) with Memo (SwiftData @Model types avoid explicit Identifiable).
private struct MemoSheetItem: Identifiable {
    let memo: Memo
    var id: UUID { memo.id }
}

struct EntryDetailView: View {
    let entry: Entry
    var onDelete: () -> Void
    var onUpdate: ((Entry) -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @Environment(EntryStore.self) private var store

    @State private var isEditing = false
    @State private var showMemoSheet = false
    @State private var editingMemo: MemoSheetItem? = nil
    @State private var showHiddenMemos = false
    @State private var showDiscardAlert = false
    @State private var showDeleteConfirmation = false

    // Edit state
    @State private var editAction: String = ""
    @State private var editCategory: EntryCategory = .food
    @State private var editContext: Set<TimeContext> = []
    @State private var editPhysicalRating: PhysicalRating? = nil
    @State private var editEmotionalTags: Set<String> = []
    @State private var editWorthIt: WorthIt? = nil
    @State private var editNote: String = ""
    @FocusState private var isEditActionFocused: Bool
    @FocusState private var isEditNoteFocused: Bool

    private static let emotionTags = ["regret", "tired", "anxious", "guilty", "satisfied", "energized", "calm", "stressed"]

    private let sectionSpacing: CGFloat = 24
    private let itemSpacing: CGFloat = 12
    private let pagePadding: CGFloat = 24
    private let bottomPadding: CGFloat = 96

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: sectionSpacing) {
                if isEditing {
                    editModeContent
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .offset(y: 20)),
                            removal: .opacity.combined(with: .offset(y: -20))
                        ))
                } else {
                    viewModeContent
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .offset(y: 20)),
                            removal: .opacity.combined(with: .offset(y: -20))
                        ))
                }
            }
            .padding(.horizontal, pagePadding)
            .padding(.bottom, bottomPadding)
        }
        .scrollIndicators(.hidden)
        .background(AppColors.background)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar(.visible, for: .navigationBar)
        .toolbar {
            if isEditing {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        cancelEditing()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Edit memory")
                        .font(.system(size: 20, weight: .medium, design: .serif))
                        .foregroundStyle(AppColors.foreground)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        saveChanges()
                    } label: {
                        Image(systemName: "checkmark")
                            .foregroundStyle(AppColors.primary)
                    }
                }
            } else {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(AppColors.foreground)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Memory details")
                        .font(.system(size: 20, weight: .medium, design: .serif))
                        .foregroundStyle(AppColors.foreground)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            startEditing()
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        Button(role: .destructive) {
                            showDeleteConfirmation = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
            if isEditing, (isEditActionFocused || isEditNoteFocused) {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isEditActionFocused = false
                        isEditNoteFocused = false
                    }
                    .foregroundStyle(AppColors.primaryForeground)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppColors.primary)
                    .clipShape(Capsule())
                }
            }
        }
        .alert("Discard changes?", isPresented: $showDiscardAlert) {
            Button("Keep Editing", role: .cancel) {}
            Button("Discard", role: .destructive) {
                withAnimation(.easeInOut(duration: 0.25)) { isEditing = false }
            }
        } message: {
            Text("You have unsaved changes that will be lost.")
        }
        .alert("Delete memory?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                onDelete()
                dismiss()
            }
        } message: {
            Text("This memory will be permanently deleted.")
        }
        .sheet(isPresented: $showMemoSheet) {
            AddMemoSheetView(actionName: entry.action) { outcome, feeling, note in
                store.addMemo(to: entry, outcome: outcome, feeling: feeling, note: note)
            }
        }
        .sheet(item: $editingMemo) { item in
            EditMemoSheetView(memo: item.memo) { outcome, feeling, note in
                store.updateMemo(item.memo, outcome: outcome, feeling: feeling, note: note)
            }
        }
    }

    // MARK: - View Mode Content

    private var viewModeContent: some View {
        VStack(alignment: .leading, spacing: sectionSpacing) {
            consolidatedHeroCard
            timelineSection
        }
    }

    // MARK: - Consolidated Hero Card

    private var consolidatedHeroCard: some View {
        VStack(spacing: 0) {
            // Emotional anchor
            Text(entry.physicalRating.emoji)
                .font(.system(size: 56))
                .padding(.bottom, 16)

            // Action title
            Text(entry.action)
                .font(.system(size: 22, weight: .medium, design: .serif))
                .foregroundStyle(AppColors.foreground)
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)

            // Category & Context
            HStack(spacing: 4) {
                Text(entry.category.emoji)
                Text(entry.category.displayName)
                Text("·")
                Text(entry.context.map(\.displayName).joined(separator: " · "))
            }
            .font(.system(size: 14))
            .foregroundStyle(AppColors.mutedForeground)
            .padding(.bottom, 8)

            // Time ago
            Text(entry.createdAt, style: .relative)
                .font(.system(size: 12))
                .foregroundStyle(AppColors.mutedForeground)
                .padding(.bottom, 16)

            // Worth It Badge
            WorthBadgeLarge(worthIt: entry.worthIt)

            // Integrated "How it felt" section
            VStack(spacing: 12) {
                Divider()
                    .background(AppColors.border.opacity(0.5))
                    .padding(.top, 16)

                HStack(spacing: 8) {
                    Text(entry.physicalRating.emoji)
                        .font(.system(size: 20))
                    Text("Felt \(entry.physicalRating.displayName.lowercased())")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.mutedForeground)
                }

                if !entry.emotionalTags.isEmpty {
                    HStack {
                        Spacer(minLength: 0)
                        FlowLayout(spacing: 8) {
                            ForEach(entry.emotionalTags, id: \.self) { tag in
                                Text(tag)
                                    .font(.system(size: 14))
                                    .foregroundStyle(AppColors.mutedForeground)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(AppColors.muted)
                                    .clipShape(Capsule())
                            }
                        }
                        Spacer(minLength: 0)
                    }
                }
            }

            // Integrated note section
            if !entry.note.isEmpty {
                VStack(spacing: 12) {
                    Divider()
                        .background(AppColors.border.opacity(0.5))
                        .padding(.top, 12)

                    Text("\"\(entry.note)\"")
                        .font(.system(size: 14))
                        .italic()
                        .foregroundStyle(AppColors.mutedForeground)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
        .overlay(RoundedRectangle(cornerRadius: AppLayout.cornerRadius).stroke(AppColors.border.opacity(0.5), lineWidth: 1))
        .shadow(color: AppShadows.soft, radius: AppShadows.softRadius, x: 0, y: 4)
    }

    // MARK: - Timeline Section

    private var timelineSection: some View {
        VStack(spacing: 12) {
            // Section header
            Text("─────── Timeline ───────")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppColors.mutedForeground)
                .frame(maxWidth: .infinity)

            // Add memo button
            Button {
                showMemoSheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .medium))
                    Text("Add a memo")
                        .font(.system(size: 14, weight: .medium))
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

            // Hidden memos toggle
            if (entry.memos ?? []).contains(where: { $0.isHidden }) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showHiddenMemos.toggle()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: showHiddenMemos ? "eye.slash" : "eye")
                            .font(.system(size: 12))
                        Text(showHiddenMemos
                             ? "Hide hidden memos"
                             : "Show \((entry.memos ?? []).filter { $0.isHidden }.count) hidden")
                            .font(.system(size: 12))
                    }
                    .foregroundStyle(AppColors.mutedForeground)
                }
            }

            // Memos list
            if !(entry.memos ?? []).isEmpty {
                VStack(spacing: 8) {
                    ForEach(filteredMemos, id: \.id) { memo in
                        MemoCardView(
                            memo: memo,
                            onEdit: { editingMemo = MemoSheetItem(memo: memo) },
                            onDelete: { store.deleteMemo(memo) },
                            onToggleStar: { store.toggleMemoStar(memo) },
                            onToggleHide: { store.toggleMemoHidden(memo) }
                        )
                    }
                }
            }
        }
    }

    private var filteredMemos: [Memo] {
        (entry.memos ?? [])
            .filter { showHiddenMemos || !$0.isHidden }
            .sorted { $0.createdAt > $1.createdAt }
    }

    // MARK: - Edit Mode Content

    private var editModeContent: some View {
        VStack(alignment: .leading, spacing: sectionSpacing) {
            editActionField
            editCategorySection
            editContextSection
            editPhysicalRatingSection
            editEmotionsSection
            editWorthItSection
            editNoteField
        }
    }

    private var editActionField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What did you do?")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppColors.foreground)

            TextField("e.g., Late-night snack", text: $editAction)
                .font(.system(size: 16))
                .padding(12)
                .background(AppColors.card)
                .clipShape(RoundedRectangle(cornerRadius: AppLayout.cardCornerRadius))
                .inputFocusStyle(isFocused: isEditActionFocused, cornerRadius: AppLayout.cardCornerRadius)
                .focused($isEditActionFocused)
                .submitLabel(.done)
        }
    }

    private var editCategorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppColors.foreground)

            FlowLayout(spacing: 8) {
                ForEach(EntryCategory.allCases, id: \.self) { cat in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) { editCategory = cat }
                    } label: {
                        HStack(spacing: 6) {
                            Text(cat.emoji)
                            Text(cat.displayName)
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(editCategory == cat ? AppColors.primaryForeground : AppColors.foreground)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(editCategory == cat ? AppColors.primary : AppColors.muted)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var editContextSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("When was this?")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppColors.foreground)

            FlowLayout(spacing: 8) {
                ForEach(TimeContext.allCases, id: \.self) { ctx in
                    let isSelected = editContext.contains(ctx)
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            if isSelected { editContext.remove(ctx) }
                            else { editContext.insert(ctx) }
                        }
                    } label: {
                        Text(ctx.displayName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(isSelected ? AppColors.primaryForeground : AppColors.foreground)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(isSelected ? AppColors.primary : AppColors.muted)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var editPhysicalRatingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How did it feel physically?")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppColors.foreground)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(PhysicalRating.allCases, id: \.self) { rating in
                    let isSelected = editPhysicalRating == rating
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) { editPhysicalRating = rating }
                    } label: {
                        VStack(spacing: 4) {
                            Text(rating.emoji)
                                .font(.system(size: 24))
                            Text(rating.displayName)
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundStyle(isSelected ? AppColors.primaryForeground : AppColors.foreground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(isSelected ? AppColors.primary : AppColors.muted)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var editEmotionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Emotions")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppColors.foreground)

            FlowLayout(spacing: 8) {
                ForEach(Self.emotionTags, id: \.self) { tag in
                    let isSelected = editEmotionalTags.contains(tag)
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            if isSelected { editEmotionalTags.remove(tag) }
                            else { editEmotionalTags.insert(tag) }
                        }
                    } label: {
                        Text(tag)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(isSelected ? AppColors.primaryForeground : AppColors.foreground)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(isSelected ? AppColors.primary : AppColors.muted)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var editWorthItSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Was it worth it?")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppColors.foreground)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(WorthIt.allCases, id: \.self) { worth in
                    let isSelected = editWorthIt == worth
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) { editWorthIt = worth }
                    } label: {
                        VStack(spacing: 4) {
                            Text(worth.emoji)
                                .font(.system(size: 20))
                            Text(worth.label)
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundStyle(isSelected ? AppColors.primaryForeground : AppColors.foreground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(isSelected ? AppColors.primary : AppColors.muted)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var editNoteField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Note (optional)")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppColors.foreground)

            TextEditor(text: $editNote)
                .font(.system(size: 16))
                .foregroundStyle(AppColors.foreground)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 80)
                .padding(8)
                .background(AppColors.card)
                .clipShape(RoundedRectangle(cornerRadius: AppLayout.cardCornerRadius))
                .inputFocusStyle(isFocused: isEditNoteFocused, cornerRadius: AppLayout.cardCornerRadius)
                .focused($isEditNoteFocused)
        }
    }

    // MARK: - Helpers

    private func startEditing() {
        editAction = entry.action
        editCategory = entry.category
        editContext = Set(entry.context)
        editPhysicalRating = entry.physicalRating
        editEmotionalTags = Set(entry.emotionalTags)
        editWorthIt = entry.worthIt
        editNote = entry.note
        withAnimation(.easeInOut(duration: 0.25)) { isEditing = true }
    }

    private func cancelEditing() {
        if hasChanges {
            showDiscardAlert = true
        } else {
            withAnimation(.easeInOut(duration: 0.25)) { isEditing = false }
        }
    }

    private func saveChanges() {
        guard let rating = editPhysicalRating,
              let worth = editWorthIt,
              !editAction.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let updatedEntry = Entry(
            id: entry.id,
            action: editAction.trimmingCharacters(in: .whitespaces),
            category: editCategory,
            context: Array(editContext),
            physicalRating: rating,
            emotionalTags: Array(editEmotionalTags),
            worthIt: worth,
            note: editNote.trimmingCharacters(in: .whitespacesAndNewlines),
            createdAt: entry.createdAt
        )

        onUpdate?(updatedEntry)
        withAnimation(.easeInOut(duration: 0.25)) { isEditing = false }
    }

    private var hasChanges: Bool {
        editAction != entry.action ||
        editCategory != entry.category ||
        Set(entry.context) != editContext ||
        editPhysicalRating != entry.physicalRating ||
        Set(entry.emotionalTags) != editEmotionalTags ||
        editWorthIt != entry.worthIt ||
        editNote != entry.note
    }
}

// MARK: - WorthBadgeLarge

struct WorthBadgeLarge: View {
    let worthIt: WorthIt

    private var backgroundColor: Color {
        switch worthIt {
        case .yes: return AppColors.secondary
        case .meh: return AppColors.accent.opacity(0.2)
        case .no: return AppColors.destructive.opacity(0.1)
        }
    }

    private var textColor: Color {
        switch worthIt {
        case .yes: return AppColors.secondaryForeground
        case .meh: return AppColors.foreground
        case .no: return AppColors.destructive
        }
    }

    private var label: String {
        switch worthIt {
        case .yes: return "Worth It"
        case .meh: return "Meh"
        case .no: return "Not Worth It"
        }
    }

    var body: some View {
        HStack(spacing: 6) {
            Text(worthIt.emoji)
            Text(label)
        }
        .font(.system(size: 18, weight: .medium))
        .foregroundStyle(textColor)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(backgroundColor)
        .clipShape(Capsule())
    }
}

// MARK: - Preview

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
            onDelete: {},
            onUpdate: { _ in }
        )
        .environment(EntryStore.preview)
    }
}
