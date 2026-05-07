//
//  ContentView.swift
//  MysticTarot
//
//  Created by Roman on 5/6/26.
//

import SwiftUI

/// Shows onboarding once, then the main tab experience.
struct MysticTarotRootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                ContentView()
            } else {
                OnboardingView()
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct ContentView: View {
    @StateObject private var viewModel = MysticTarotViewModel()
    @State private var selectedTab = 0
    @State private var homePath = NavigationPath()
    @State private var galleryPath = NavigationPath()
    @State private var spreadsPath = NavigationPath()

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $homePath) {
                HomeView(viewModel: viewModel, selectedTab: $selectedTab, navigationPath: $homePath)
                    .navigationDestination(for: UUID.self) { id in
                        CardDetailView(viewModel: viewModel, cardId: id, navigationPath: $homePath)
                    }
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)

            NavigationStack(path: $galleryPath) {
                CardGalleryView(viewModel: viewModel, navigationPath: $galleryPath)
                    .navigationDestination(for: UUID.self) { id in
                        CardDetailView(viewModel: viewModel, cardId: id, navigationPath: $galleryPath)
                    }
            }
            .tabItem {
                Label("Cards", systemImage: "square.stack.3d.up.fill")
            }
            .tag(1)

            NavigationStack(path: $spreadsPath) {
                SpreadsView(viewModel: viewModel, navigationPath: $spreadsPath)
                    .navigationDestination(for: UUID.self) { id in
                        SpreadDetailView(viewModel: viewModel, spreadId: id, navigationPath: $spreadsPath)
                    }
            }
            .tabItem {
                Label("Spreads", systemImage: "rectangle.stack.fill")
            }
            .tag(2)

            NavigationStack {
                JournalView(viewModel: viewModel)
            }
            .tabItem {
                Label("Journal", systemImage: "book.fill")
            }
            .tag(3)

            NavigationStack {
                StatsView(viewModel: viewModel)
            }
            .tabItem {
                Label("Statistics", systemImage: "chart.bar.fill")
            }
            .tag(4)
        }
        .tint(.tarotPositive)
    }
}

#Preview("Main app") {
    ContentView()
}

#Preview("Onboarding") {
    OnboardingView()
}
