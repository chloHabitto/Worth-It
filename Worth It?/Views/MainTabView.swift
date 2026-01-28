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
        ZStack(alignment: .bottom) {
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

            // Custom tab bar: bg-card/80 backdrop-blur-lg border-t border-border/50
            VStack(spacing: 0) {
                Divider()
                    .background(AppColors.border.opacity(0.5))

                HStack(spacing: 0) {
                    TabButton(
                        icon: "house",
                        iconFilled: "house.fill",
                        label: "Home",
                        isSelected: selectedTab == 0
                    ) { selectedTab = 0 }

                    TabButton(
                        icon: "magnifyingglass",
                        iconFilled: "magnifyingglass",
                        label: "Search",
                        isSelected: selectedTab == 1
                    ) { selectedTab = 1 }

                    Button(action: { showLogSheet = true }) {
                        Circle()
                            .fill(AppColors.primary)
                            .frame(width: 56, height: 56)
                            .overlay(
                                Image(systemName: "plus")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundStyle(AppColors.primaryForeground)
                            )
                            .shadow(color: AppColors.primary.opacity(0.15), radius: 40, x: 0, y: 0)
                    }
                    .offset(y: -32)

                    TabButton(
                        icon: "chart.bar",
                        iconFilled: "chart.bar.fill",
                        label: "Library",
                        isSelected: selectedTab == 2
                    ) { selectedTab = 2 }

                    TabButton(
                        icon: "person",
                        iconFilled: "person.fill",
                        label: "Account",
                        isSelected: selectedTab == 3
                    ) { selectedTab = 3 }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .background(
                AppColors.card.opacity(0.8)
                    .background(.ultraThinMaterial)
            )
            .ignoresSafeArea(edges: .bottom)
        }
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
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isSelected)

                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .medium : .regular))
                    .foregroundStyle(isSelected ? AppColors.primary : AppColors.mutedForeground)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
        }
        .frame(maxWidth: .infinity)
    }
}

struct SearchView: View {
    var body: some View {
        NavigationStack {
            Text("Search")
                .font(.system(size: 22, weight: .medium, design: .serif))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
}

struct LibraryView: View {
    var body: some View {
        NavigationStack {
            Text("Library")
                .font(.system(size: 22, weight: .medium, design: .serif))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
}

struct AccountView: View {
    var body: some View {
        NavigationStack {
            Text("Account")
                .font(.system(size: 22, weight: .medium, design: .serif))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
}

#Preview {
    MainTabView()
        .environment(EntryStore())
}
