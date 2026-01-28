//
//  MainTabView.swift
//  Worth It?
//

import SwiftUI

struct MainTabView: View {
    @Environment(EntryStore.self) private var store
    @State private var selectedTab = 0
    @State private var showLogSheet = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Main content
                Group {
                    switch selectedTab {
                    case 0: HomeView()
                    case 1: SearchView()
                    case 2: LibraryView()
                    case 3: AccountView()
                    default: HomeView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom, 70) // Space for tab bar

                // Custom tab bar
                VStack(spacing: 0) {
                    // Top border
                    Rectangle()
                        .fill(AppColors.border.opacity(0.5))
                        .frame(height: 1)

                    // Tab buttons
                    HStack(spacing: 0) {
                        TabButton(icon: "house", iconFilled: "house.fill", label: "Home", isSelected: selectedTab == 0) { selectedTab = 0 }

                        TabButton(icon: "magnifyingglass", iconFilled: "magnifyingglass", label: "Search", isSelected: selectedTab == 1) { selectedTab = 1 }

                        // Center FAB spacer
                        Spacer().frame(width: 64)

                        TabButton(icon: "books.vertical", iconFilled: "books.vertical.fill", label: "Library", isSelected: selectedTab == 2) { selectedTab = 2 }

                        TabButton(icon: "person", iconFilled: "person.fill", label: "Account", isSelected: selectedTab == 3) { selectedTab = 3 }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 12)
                }
                .frame(maxWidth: .infinity)
                .background(AppColors.card.opacity(0.8))
                .padding(.bottom, geometry.safeAreaInsets.bottom)

                // FAB button - positioned separately
                Button(action: { showLogSheet = true }) {
                    Circle()
                        .fill(AppColors.primary)
                        .frame(width: 56, height: 56)
                        .overlay(
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundStyle(AppColors.primaryForeground)
                        )
                        .shadow(color: AppColors.primary.opacity(0.15), radius: 20, x: 0, y: 0)
                }
                .offset(y: -(geometry.safeAreaInsets.bottom + 28))
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showLogSheet) {
            LogExperienceView(store: store)
        }
    }
}

struct TabButton: View {
    let icon: String
    let iconFilled: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? iconFilled : icon)
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? AppColors.primary : AppColors.mutedForeground)

                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .medium : .regular))
                    .foregroundStyle(isSelected ? AppColors.primary : AppColors.mutedForeground)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(.plain)
    }
}

#Preview {
    MainTabView()
        .environment(EntryStore.preview)
}
