//
//  AccountView.swift
//  Worth It?
//
//  Translated from AccountPage.tsx (recall-resolve)
//

import SwiftUI

// MARK: - Theme Options

enum AppTheme: String, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"

    var label: String {
        switch self {
        case .system: return "Auto"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var icon: String {
        switch self {
        case .system: return "laptopcomputer.and.iphone"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

// MARK: - Account View

struct AccountView: View {
    @Environment(EntryStore.self) private var store
    @Environment(AppLockManager.self) private var lockManager
    private var toast: ToastManager { ToastManager.shared }
    @AppStorage("appTheme") private var selectedTheme: AppTheme = .system
    @AppStorage("displayName") private var displayName: String = ""
    @AppStorage("profileImageData") private var profileImageBase64: String = ""
    @State private var showClearDataAlert = false
    @State private var showContactSheet = false

    private static let supportEmail = "support@worthit.app"

    private var entryCount: Int {
        store.entries.count
    }

    private var profileImage: Image? {
        guard let data = Data(base64Encoded: profileImageBase64),
              let uiImage = UIImage(data: data) else { return nil }
        return Image(uiImage: uiImage)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    header
                        .padding(.horizontal, 24)
                        .padding(.top, 48)
                        .padding(.bottom, 24)
                        .pageEntrance(delay: 0, offsetY: -10)

                    // Content
                    VStack(spacing: 20) {
                        profileCard
                            .pageEntrance(delay: 0.05, offsetY: 10)
                        appearanceSection
                            .pageEntrance(delay: 0.1, offsetY: 10)
                        dataPrivacySection
                            .pageEntrance(delay: 0.15, offsetY: 10)
                        supportSection
                            .pageEntrance(delay: 0.2, offsetY: 10)
                        aboutSection
                            .pageEntrance(delay: 0.25, offsetY: 10)
                        footer
                            .fadeIn(delay: 0.3)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 96)
            }
            .scrollIndicators(.hidden)
            .background(AppColors.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
        }
        .alert("Clear all memories?", isPresented: $showClearDataAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete all", role: .destructive) {
                handleClearData()
            }
        } message: {
            Text("This will permanently delete all \(entryCount) logged \(entryCount == 1 ? "memory" : "memories"). This action cannot be undone.")
        }
        .confirmationDialog("Contact Us", isPresented: $showContactSheet, titleVisibility: .visible) {
            Button("Open in Mail App") {
                openMailApp()
            }
            Button("Copy Email Address") {
                copyEmailToClipboard()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(Self.supportEmail)
        }
    }

    // MARK: - Header

    private var header: some View {
        Text("Account")
            .font(.system(size: 24, weight: .semibold, design: .serif))
            .foregroundStyle(AppColors.foreground)
    }

    // MARK: - Profile Card (Tappable - navigates to ProfileView)
    // React: <motion.button onClick={() => navigate('/profile')}>

    private var profileCard: some View {
        NavigationLink {
            ProfileView()
        } label: {
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    // Profile image or default avatar
                    if let profileImage = profileImage {
                        profileImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 64, height: 64)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        AppColors.primary.opacity(0.2),
                                        AppColors.accent.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 64, height: 64)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 32))
                                    .foregroundStyle(AppColors.primary)
                            )
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        // React: {displayName || 'Local User'}
                        Text(displayName.isEmpty ? "Local User" : displayName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(AppColors.foreground)

                        // Changed from "Data stored on this device" to show sync status
                        HStack(spacing: 6) {
                            Image(systemName: "icloud.fill")
                                .font(.system(size: 14))
                            Text("Synced across devices")
                                .font(.system(size: 14))
                        }
                        .foregroundStyle(AppColors.mutedForeground)
                    }

                    Spacer()

                    // React: <ChevronRight className="w-5 h-5 text-muted-foreground" />
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppColors.mutedForeground.opacity(0.5))
                }

                Divider()
                    .background(AppColors.border.opacity(0.5))
                    .padding(.top, 16)

                HStack {
                    Text("Memories logged")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.mutedForeground)
                    Spacer()
                    Text("\(entryCount)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.primary)
                }
                .padding(.top, 16)
            }
            .padding(20)
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppColors.border.opacity(0.5), lineWidth: 1)
            )
            .shadow(color: AppShadows.soft, radius: AppShadows.softRadius, x: 0, y: AppShadows.softY)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Appearance Section

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Appearance")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColors.foreground)

            HStack(spacing: 12) {
                ForEach(AppTheme.allCases, id: \.self) { theme in
                    ThemeButton(
                        theme: theme,
                        isSelected: selectedTheme == theme,
                        action: { selectedTheme = theme }
                    )
                }
            }
            .animation(.easeInOut(duration: 0.2), value: selectedTheme)
        }
        .padding(20)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.border.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: AppShadows.soft, radius: AppShadows.softRadius, x: 0, y: AppShadows.softY)
    }

    // MARK: - Data & Privacy Section

    private var dataPrivacySection: some View {
        SectionCard(title: "Data & Privacy") {
            NavigationLink {
                AppLockView()
            } label: {
                SettingsRowLabel(
                    icon: "lock.fill",
                    label: "App Lock",
                    sublabel: lockManager.settings.isEnabled
                        ? "PIN protection enabled"
                        : "Protect your app with PIN or Face ID"
                )
            }
            .buttonStyle(.plain)

            SettingsRow(
                icon: "square.and.arrow.down",
                label: "Export My Data",
                sublabel: "Download all your memories as JSON",
                action: handleExportData
            )

            SettingsRow(
                icon: "shield",
                label: "Privacy Policy",
                sublabel: "How we handle your data",
                isExternal: true,
                action: { /* TODO: Open privacy policy */ }
            )

            SettingsRow(
                icon: "doc.text",
                label: "Terms of Use",
                sublabel: "Our terms and conditions",
                isExternal: true,
                action: { /* TODO: Open terms */ }
            )

            if !store.hiddenEntries.isEmpty {
                NavigationLink {
                    HiddenMemoriesView()
                } label: {
                    SettingsRowLabel(
                        icon: "eye.slash",
                        label: "Hidden memories",
                        sublabel: "\(store.hiddenEntries.count) \(store.hiddenEntries.count == 1 ? "memory" : "memories") hidden"
                    )
                }
                .buttonStyle(.plain)
            }

            SettingsRow(
                icon: "trash",
                label: "Clear All Memories",
                sublabel: "Permanently delete all logged entries",
                isDestructive: true,
                isLast: true,
                action: { showClearDataAlert = true }
            )
        }
    }

    // MARK: - Support Section

    private var supportSection: some View {
        SectionCard(title: "Support") {
            NavigationLink {
                HelpView()
            } label: {
                SettingsRowLabel(
                    icon: "questionmark.circle",
                    label: "Help / FAQ",
                    sublabel: "Get answers to common questions"
                )
            }
            .buttonStyle(.plain)

            SettingsRow(
                icon: "envelope",
                label: "Contact Us",
                sublabel: "Reach out to our team",
                isExternal: true,
                action: { showContactSheet = true }
            )

            SettingsRow(
                icon: "bubble.left.and.bubble.right",
                label: "Send Feedback",
                sublabel: "Help us improve Worth It?",
                isExternal: true,
                isLast: true,
                action: { showContactSheet = true }
            )
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        SectionCard(title: "About") {
            SettingsRow(
                icon: "star",
                label: "Rate Worth It?",
                sublabel: "Leave a review on the App Store",
                isExternal: true,
                action: handleRateApp
            )

            SettingsRow(
                icon: "square.and.arrow.up",
                label: "Share with Friends",
                sublabel: "Spread the word",
                isLast: true,
                action: handleShare
            )
        }
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 4) {
            Text("Worth It?")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppColors.mutedForeground)

            Text("v1.0 · Made with 🧡")
                .font(.system(size: 12))
                .foregroundStyle(AppColors.mutedForeground.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 24)
        .padding(.bottom, 16)
    }

    // MARK: - Actions

    private func handleClearData() {
        let allIds = Set(store.entries.map { $0.id })
        store.delete(ids: allIds)
        toast.success("All memories cleared")
    }

    private func exportEntries(_ entries: [Entry]) -> Data? {
        let exportable = entries.map { entry in
            [
                "id": entry.id.uuidString,
                "action": entry.action,
                "category": entry.categoryRaw,
                "context": entry.contextRaw,
                "physicalRating": entry.physicalRatingRaw,
                "emotionalTags": entry.emotionalTags,
                "worthIt": entry.worthItRaw,
                "note": entry.note,
                "createdAt": ISO8601DateFormatter().string(from: entry.createdAt)
            ] as [String: Any]
        }
        return try? JSONSerialization.data(withJSONObject: exportable, options: .prettyPrinted)
    }

    private func handleExportData() {
        guard let data = exportEntries(store.entries),
              let jsonString = String(data: data, encoding: .utf8) else {
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        let filename = "worthit-export-\(dateString).json"

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try? jsonString.write(to: tempURL, atomically: true, encoding: .utf8)

        let activityVC = UIActivityViewController(
            activityItems: [tempURL],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
            toast.success("Data exported successfully")
        }
    }

    private func handleRateApp() {
        // TODO: Replace with actual App Store ID
        if let url = URL(string: "https://apps.apple.com/app/id123456789?action=write-review") {
            UIApplication.shared.open(url)
        }
    }

    private func handleShare() {
        let shareText = "Before you do it again… remember how it felt last time."
        let appURL = URL(string: "https://apps.apple.com/app/id123456789")!

        let activityVC = UIActivityViewController(
            activityItems: [shareText, appURL],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }

    private func openMailApp() {
        if let url = URL(string: "mailto:\(Self.supportEmail)") {
            UIApplication.shared.open(url)
        }
    }

    private func copyEmailToClipboard() {
        UIPasteboard.general.string = Self.supportEmail
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        toast.success("Email copied")
    }
}

// MARK: - Section Card (reusable pattern from React)

struct SectionCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            // Header: px-5 py-3 bg-muted/30 border-b
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.mutedForeground)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(AppColors.muted.opacity(0.3))

            Divider()
                .background(AppColors.border.opacity(0.5))

            // Content with dividers between rows
            VStack(spacing: 0) {
                content
            }
        }
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.border.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: AppShadows.soft, radius: AppShadows.softRadius, x: 0, y: AppShadows.softY)
    }
}

// MARK: - Settings Row (reusable pattern from React SettingsRow)

struct SettingsRow: View {
    let icon: String
    let label: String
    var sublabel: String? = nil
    var isExternal: Bool = false
    var isDestructive: Bool = false
    var isLast: Bool = false  // Controls bottom divider
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(label)
                            .font(.system(size: 16, weight: .medium))

                        if let sublabel = sublabel {
                            Text(sublabel)
                                .font(.system(size: 12))
                                .opacity(0.7)
                        }
                    }

                    Spacer()

                    Image(systemName: isExternal ? "arrow.up.right" : "chevron.right")
                        .font(.system(size: 14))
                        .opacity(0.5)
                }
                .foregroundStyle(isDestructive ? AppColors.destructive : AppColors.foreground)
                .padding(16)

                // Bottom divider (only if not last item)
                if !isLast {
                    Divider()
                        .background(AppColors.border.opacity(0.5))
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Theme Button

struct ThemeButton: View {
    let theme: AppTheme
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Circle()
                    .fill(isSelected ? AppColors.primary.opacity(0.2) : AppColors.muted)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: theme.icon)
                            .font(.system(size: 20))
                            .foregroundStyle(isSelected ? AppColors.primary : AppColors.mutedForeground)
                    )

                Text(theme.label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(isSelected ? AppColors.primary : AppColors.foreground)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? AppColors.primary.opacity(0.1) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? AppColors.primary : AppColors.border,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected ? AppColors.primary.opacity(0.1) : Color.clear,
                radius: 4,
                x: 0,
                y: 2
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Settings Row Label (for NavigationLink compatibility)

struct SettingsRowLabel: View {
    let icon: String
    let label: String
    var sublabel: String? = nil
    var isLast: Bool = false  // Controls bottom divider

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(AppColors.foreground)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AppColors.foreground)

                    if let sublabel = sublabel {
                        Text(sublabel)
                            .font(.system(size: 12))
                            .foregroundStyle(AppColors.mutedForeground)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppColors.mutedForeground.opacity(0.5))
            }
            .padding(16)
            .contentShape(Rectangle())

            // Bottom divider (only if not last item)
            if !isLast {
                Divider()
                    .background(AppColors.border.opacity(0.5))
            }
        }
    }
}

// MARK: - Preview

#Preview {
    AccountView()
        .environment(EntryStore.preview)
        .environment(AppLockManager.shared)
}
