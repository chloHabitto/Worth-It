//
//  AccountView.swift
//  Worth It?
//
//  Translated from AccountPage.tsx
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
    @AppStorage("appTheme") private var selectedTheme: AppTheme = .system
    @State private var showClearDataAlert = false

    private var entryCount: Int {
        store.entries.count
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
                        dataSection
                            .pageEntrance(delay: 0.15, offsetY: 10)
                        footer
                            .fadeIn(delay: 0.2)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 96)
            }
            .scrollIndicators(.hidden)
            .background(AppColors.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .preferredColorScheme(selectedTheme.colorScheme)
        }
        .alert("Clear all memories?", isPresented: $showClearDataAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete all", role: .destructive) {
                handleClearData()
            }
        } message: {
            Text("This will permanently delete all \(entryCount) logged \(entryCount == 1 ? "memory" : "memories"). This action cannot be undone.")
        }
    }

    // MARK: - Header

    private var header: some View {
        Text("Account")
            .font(.system(size: 24, weight: .semibold, design: .serif))
            .foregroundStyle(AppColors.foreground)
    }

    // MARK: - Profile Card

    private var profileCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
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

                VStack(alignment: .leading, spacing: 4) {
                    Text("Local User")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppColors.foreground)

                    HStack(spacing: 6) {
                        Image(systemName: "iphone")
                            .font(.system(size: 14))
                        Text("Data stored on this device")
                            .font(.system(size: 14))
                    }
                    .foregroundStyle(AppColors.mutedForeground)
                }

                Spacer()
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

    // MARK: - Data Section

    private var dataSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Data")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.mutedForeground)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(AppColors.muted.opacity(0.3))

            Divider()
                .background(AppColors.border.opacity(0.5))

            Button {
                showClearDataAlert = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "trash")
                        .font(.system(size: 20))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Clear all memories")
                            .font(.system(size: 16, weight: .medium))
                        Text("Permanently delete all logged entries")
                            .font(.system(size: 12))
                            .opacity(0.7)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .opacity(0.5)
                }
                .foregroundStyle(AppColors.destructive)
                .padding(16)
            }
            .buttonStyle(.plain)
        }
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.border.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: AppShadows.soft, radius: AppShadows.softRadius, x: 0, y: AppShadows.softY)
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 4) {
            Text("Worth It?")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppColors.mutedForeground)

            Text("Version 1.0")
                .font(.system(size: 12))
                .foregroundStyle(AppColors.mutedForeground.opacity(0.7))

            Text("Made with ❤️ for mindful living")
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

#Preview {
    AccountView()
        .environment(EntryStore.preview)
}
