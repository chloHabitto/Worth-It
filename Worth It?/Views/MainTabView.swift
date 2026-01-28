//
//  MainTabView.swift
//  Worth It?
//

import SwiftUI

enum Tab: Int, CaseIterable {
    case home = 0
    case search
    case library
    case account

    var title: String {
        switch self {
        case .home: return "Home"
        case .search: return "Search"
        case .library: return "Library"
        case .account: return "Account"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .search: return "magnifyingglass"
        case .library: return "books.vertical.fill"
        case .account: return "person.fill"
        }
    }
}

struct MainTabView: View {
    @Environment(EntryStore.self) private var store
    @State private var selectedTab: Tab = .home
    @State private var showLogExperience = false

    var body: some View {
        ZStack(alignment: .bottom) {
            tabContent
            tabBarOverlay
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showLogExperience) {
            LogExperienceView(store: store)
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .home:
            HomeView()
        case .search:
            SearchView()
        case .library:
            LibraryView()
        case .account:
            AccountView()
        }
    }

    private var tabBarOverlay: some View {
        VStack(spacing: 0) {
            Spacer()
            HStack(spacing: 0) {
                tabButton(.home)
                tabButton(.search)
                Spacer()
                    .frame(width: 56) // space for FAB
                tabButton(.library)
                tabButton(.account)
            }
            .overlay(alignment: .center) {
                floatingAddButton
            }
            .padding(.horizontal, 8)
            .padding(.top, 10)
            .padding(.bottom, 24)
            .background(
                WorthItColors.card
                    .opacity(0.95)
                    .background(.ultraThinMaterial)
                    .shadow(color: WorthItColors.border, radius: 0, y: -0.5)
            )
            .ignoresSafeArea(edges: .bottom)
        }
    }

    private func tabButton(_ tab: Tab) -> some View {
        let isSelected = selectedTab == tab
        return Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20))
                Text(tab.title)
                    .font(WorthItTheme.footnoteFont)
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(isSelected ? WorthItColors.primary : WorthItColors.mutedForeground)
        }
        .buttonStyle(.plain)
    }

    private var floatingAddButton: some View {
        Button {
            showLogExperience = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(WorthItColors.primary)
                .clipShape(Circle())
                .shadow(
                    color: WorthItShadows.glow,
                    radius: 10,
                    x: 0,
                    y: 4
                )
        }
        .offset(y: -18)
    }
}

// Placeholder views (to be filled when building those screens)

struct SearchView: View {
    var body: some View {
        NavigationStack {
            Text("Search")
                .font(WorthItTheme.title2Font)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WorthItTheme.background)
    }
}

struct LibraryView: View {
    var body: some View {
        NavigationStack {
            Text("Library")
                .font(WorthItTheme.title2Font)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WorthItTheme.background)
    }
}

struct AccountView: View {
    var body: some View {
        NavigationStack {
            Text("Account")
                .font(WorthItTheme.title2Font)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WorthItTheme.background)
    }
}

#Preview {
    MainTabView()
        .environment(EntryStore())
}
