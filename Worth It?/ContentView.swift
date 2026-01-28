//
//  ContentView.swift
//  Worth It?
//
//  Created by Chloe Lee on 2026-01-28.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MainTabView()
    }
}

#Preview {
    ContentView()
        .environment(EntryStore.preview)
}
