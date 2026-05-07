//
//  HomeView.swift
//  MysticTarot
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: MysticTarotViewModel
    @Binding var selectedTab: Int
    @Binding var navigationPath: NavigationPath

    private var latestJournal: TarotJournal? {
        viewModel.sortedJournalEntries(search: "").first
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 22) {
                heroBanner

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    HomeStatWidget(
                        title: "Journal streak",
                        value: "\(viewModel.journalStreak)d",
                        subtitle: "Keep reflecting",
                        icon: "book.pages.fill",
                        accent: .tarotPositive
                    )
                    HomeStatWidget(
                        title: "Spread streak",
                        value: "\(viewModel.spreadStreak)d",
                        subtitle: "Daily draws",
                        icon: "rectangle.stack.fill",
                        accent: .tarotMystic
                    )
                    HomeStatWidget(
                        title: "Cards",
                        value: "\(viewModel.totalCards)",
                        subtitle: "In your deck",
                        icon: "square.stack.3d.up.fill",
                        accent: .tarotMystic
                    )
                    HomeStatWidget(
                        title: "Spreads",
                        value: "\(viewModel.totalSpreads)",
                        subtitle: "Logged layouts",
                        icon: "square.grid.3x3.fill",
                        accent: .tarotPositive
                    )
                }

                if let card = viewModel.cardOfDay {
                    cardOfDayWidget(card)
                }

                quickActionsSection

                suitsCarousel

                if let entry = latestJournal {
                    journalSnippet(entry)
                }

                tipsStrip
            }
            .padding(.horizontal)
            .padding(.bottom, 28)
            .padding(.top, 8)
        }
        .tarotScreenBackground()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text("Home")
                        .font(.largeTitle.bold())
                        .foregroundColor(.tarotPositive)
                    Text("\(formattedShortDate(Date()))")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SettingsView()
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.tarotPositive)
                }
                .accessibilityLabel("Settings")
            }
        }
    }

    // MARK: - Hero

    private var heroBanner: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.tarotMystic.opacity(0.55),
                            Color.tarotBackground.opacity(0.95),
                            Color.tarotPositive.opacity(0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [.tarotPositive.opacity(0.6), .tarotMystic.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )

            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    ForEach(0 ..< 3, id: \.self) { ring in
                        Circle()
                            .strokeBorder(
                                Color.tarotPositive.opacity(0.25 - Double(ring) * 0.06),
                                lineWidth: 2
                            )
                            .frame(width: 96 + CGFloat(ring * 18), height: 96 + CGFloat(ring * 18))
                    }

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.tarotPositive.opacity(0.5), .tarotMystic.opacity(0.35)],
                                center: .center,
                                startRadius: 8,
                                endRadius: 48
                            )
                        )
                        .frame(width: 96, height: 96)
                        .overlay(
                            Image(systemName: "moon.stars.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, .tarotPositive],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: .tarotPositive.opacity(0.6), radius: 12)
                        )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Tonight’s practice")
                        .font(.caption.weight(.heavy))
                        .foregroundColor(.tarotPositive)
                        .textCase(.uppercase)
                        .tracking(1.2)

                    Text("Shuffle intention into focus — study cards, log spreads, write what shifts.")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.white.opacity(0.92))
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 10) {
                        heroChip(icon: "sparkles", text: "Ritual ready")
                        heroChip(icon: "eye.fill", text: "Mindful draw")
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(20)
        }
        .shadow(color: .black.opacity(0.35), radius: 20, y: 12)
    }

    private func heroChip(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption2.weight(.semibold))
        }
        .foregroundColor(.tarotPositive.opacity(0.95))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(Color.black.opacity(0.28)))
    }

    // MARK: - Card of day

    private func cardOfDayWidget(_ card: TarotCard) -> some View {
        Button {
            navigationPath.append(card.id)
        } label: {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Image(systemName: "sun.max.fill")
                        .font(.title2)
                        .foregroundStyle(
                            LinearGradient(colors: [.yellow.opacity(0.95), .tarotPositive], startPoint: .top, endPoint: .bottom)
                        )
                    Text("Card of the day")
                        .font(.caption.weight(.heavy))
                        .foregroundColor(.tarotPositive)
                        .textCase(.uppercase)
                    Spacer()
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(.white.opacity(0.45))
                }

                HStack(spacing: 18) {
                    tarotFigurePortrait(symbol: "person.fill.viewfinder", badge: "∞")

                    VStack(alignment: .leading, spacing: 6) {
                        Text(card.name)
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                        Text(card.arcana.rawValue)
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.tarotMystic)
                        Text("Tap for full meanings & notes")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    Spacer(minLength: 0)
                }
            }
            .padding(18)
            .tarotPanel(cornerRadius: 22, depth: 1)
        }
        .buttonStyle(.plain)
    }

    private func tarotFigurePortrait(symbol: String, badge: String) -> some View {
        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.tarotPositive.opacity(0.35), Color.tarotMystic.opacity(0.55)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 88, height: 112)
                .overlay(
                    Image(systemName: symbol)
                        .font(.system(size: 36))
                        .foregroundStyle(.white.opacity(0.9))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                )

            Text(badge)
                .font(.caption2.bold())
                .foregroundColor(.tarotPositive)
                .padding(6)
                .background(Circle().fill(Color.black.opacity(0.45)))
                .offset(x: 4, y: 4)
        }
    }

    // MARK: - Quick actions

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Shortcuts")
                .font(.headline.weight(.bold))
                .tarotSectionTitleGradient(accent: .tarotPositive)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                NavigationLink {
                    StudyHubView(viewModel: viewModel)
                } label: {
                    HomeActionTile(title: "Study", subtitle: "Flash & quiz", icon: "brain.head.profile", gradient: [.tarotMystic, .tarotPositive])
                }
                .buttonStyle(.plain)

                Button {
                    selectedTab = 1
                } label: {
                    HomeActionTile(title: "Deck", subtitle: "Browse cards", icon: "square.stack.3d.up.fill", gradient: [.purple.opacity(0.7), .tarotMystic])
                }

                Button {
                    selectedTab = 2
                } label: {
                    HomeActionTile(title: "Spreads", subtitle: "Layouts log", icon: "rectangle.stack.fill", gradient: [.tarotPositive.opacity(0.8), .cyan.opacity(0.35)])
                }

                Button {
                    selectedTab = 3
                } label: {
                    HomeActionTile(title: "Journal", subtitle: "Reflections", icon: "book.fill", gradient: [.indigo.opacity(0.65), .tarotMystic.opacity(0.9)])
                }

                Button {
                    selectedTab = 4
                } label: {
                    HomeActionTile(title: "Insights", subtitle: "Charts & streaks", icon: "chart.bar.fill", gradient: [.orange.opacity(0.55), .tarotPositive.opacity(0.75)])
                }
                .gridCellColumns(2)
            }
        }
    }

    // MARK: - Suits carousel (visual “gallery”)

    private var suitsCarousel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("The suits")
                .font(.headline.weight(.bold))
                .tarotSectionTitleGradient(accent: .tarotMystic)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 14),
                    GridItem(.flexible(), spacing: 14),
                    GridItem(.flexible(), spacing: 14)
                ],
                spacing: 14
            ) {
                suitOrb(.major, "Major", "star.fill")
                suitOrb(.cups, "Cups", "drop.fill")
                suitOrb(.wands, "Wands", "flame.fill")
                suitOrb(.swords, "Swords", "wind")
                suitOrb(.pentacles, "Coins", "circle.fill")
            }
            .padding(.vertical, 6)
        }
    }

    private func suitOrb(_ arcana: ArcanaType, _ label: String, _ icon: String) -> some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.tarotPositive.opacity(0.45), Color.tarotMystic.opacity(0.25)],
                            center: .topLeading,
                            startRadius: 4,
                            endRadius: 52
                        )
                    )
                    .frame(width: 84, height: 84)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                    )

                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundStyle(
                        LinearGradient(colors: [.white, .tarotPositive.opacity(0.95)], startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(color: .tarotPositive.opacity(0.35), radius: 8)
            }

            Text(label)
                .font(.caption.weight(.bold))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Journal snippet

    private func journalSnippet(_ entry: TarotJournal) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "quote.opening")
                    .foregroundColor(.tarotPositive)
                Text("Latest journal")
                    .font(.headline.weight(.bold))
                    .tarotSectionTitleGradient(accent: .white)
                Spacer()
                Button("Open") { selectedTab = 3 }
                    .font(.caption.weight(.bold))
                    .foregroundColor(.tarotPositive)
            }

            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "text.book.closed.fill")
                    .font(.title)
                    .foregroundStyle(
                        LinearGradient(colors: [.tarotMystic, .tarotPositive], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 44)

                VStack(alignment: .leading, spacing: 6) {
                    Text(entry.cardName)
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(.white)
                    Text(entry.reflection)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(3)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .tarotPanel(cornerRadius: 16, depth: 0.88)
        }
    }

    private var tipsStrip: some View {
        HStack(spacing: 12) {
            Image(systemName: "hands.sparkles.fill")
                .font(.title2)
                .foregroundColor(.tarotPositive)
            VStack(alignment: .leading, spacing: 4) {
                Text("Tip")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.tarotPositive)
                Text("Pin important journal entries and tag cards to filter your study sessions faster.")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.75))
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .tarotPanel(cornerRadius: 14, depth: 0.82)
    }
}

// MARK: - Widget tiles

private struct HomeStatWidget: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    Circle()
                        .fill(accent.opacity(0.22))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.body.weight(.semibold))
                        .foregroundColor(accent)
                }
                Spacer()
            }

            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(title)
                .font(.caption.weight(.bold))
                .foregroundColor(.gray)

            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.tarotMystic.opacity(0.85))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .tarotPanel(cornerRadius: 18, depth: 0.92)
    }
}

private struct HomeActionTile: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: [Color]

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 52, height: 52)
                    .overlay(
                        Image(systemName: icon)
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundColor(.white.opacity(0.35))
        }
        .padding(14)
        .tarotPanel(cornerRadius: 18, depth: 0.78)
    }
}
