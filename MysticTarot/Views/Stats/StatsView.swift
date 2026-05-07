//
//  StatsView.swift
//  MysticTarot
//

import Charts
import SwiftUI

struct StatsView: View {
    @ObservedObject var viewModel: MysticTarotViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HStack(spacing: 14) {
                    streakTile(
                        title: "Journal streak",
                        value: "\(viewModel.journalStreak)",
                        subtitle: "days in a row",
                        icon: "book.pages.fill"
                    )
                    streakTile(
                        title: "Spread streak",
                        value: "\(viewModel.spreadStreak)",
                        subtitle: "days in a row",
                        icon: "rectangle.stack.fill"
                    )
                }
                .padding(.horizontal)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    StatCard(
                        title: "Cards",
                        value: "\(viewModel.totalCards)",
                        icon: "square.stack.3d.up.fill",
                        color: .tarotMystic
                    )

                    StatCard(
                        title: "Spreads",
                        value: "\(viewModel.totalSpreads)",
                        icon: "rectangle.stack.fill",
                        color: .tarotPositive
                    )

                    StatCard(
                        title: "Favorites",
                        value: "\(viewModel.favoriteCards)",
                        icon: "star.fill",
                        color: .tarotPositive
                    )

                    StatCard(
                        title: "Notes",
                        value: "\(viewModel.totalNotes)",
                        icon: "note.text",
                        color: .tarotMystic
                    )
                }
                .padding(.horizontal)

                suitChartSection(
                    title: "Journal — suits",
                    caption: "Counts by linked deck card.",
                    slices: viewModel.journalArcanaDistribution()
                )

                suitChartSection(
                    title: "Spreads — suits",
                    caption: "Card pulls recorded in spreads.",
                    slices: viewModel.spreadArcanaDistribution()
                )

                VStack(alignment: .leading, spacing: 12) {
                    Text("Frequent cards")
                        .font(.headline.weight(.bold))
                        .tarotSectionTitleGradient(accent: .white)

                    if viewModel.frequentCards.isEmpty {
                        Text("Log spreads with named cards to see frequency insights.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        ForEach(viewModel.frequentCards) { card in
                            HStack {
                                Text(card.name)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(card.count)×")
                                    .foregroundColor(.tarotPositive)
                                    .bold()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .padding(16)
                .tarotPanel(cornerRadius: 16, depth: 0.88)
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Favorite arcana")
                        .font(.headline.weight(.bold))
                        .tarotSectionTitleGradient(accent: .white)

                    if viewModel.arcanaStats.isEmpty {
                        Text("Add cards across suits to populate this chart.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        ForEach(viewModel.arcanaStats) { stat in
                            HStack {
                                Image(systemName: stat.icon)
                                    .foregroundColor(.tarotMystic)
                                    .frame(width: 30)
                                Text(stat.name)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(stat.count)")
                                    .foregroundColor(.tarotPositive)
                                    .bold()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .padding(16)
                .tarotPanel(cornerRadius: 16, depth: 0.88)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .tarotScreenBackground()
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Statistics")
                    .font(.largeTitle.bold())
                    .foregroundColor(.tarotPositive)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func streakTile(title: String, value: String, subtitle: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.tarotPositive)
                Text(title)
                    .font(.caption.weight(.bold))
                    .foregroundColor(.gray)
            }
            Text(value)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.tarotMystic)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .tarotPanel(cornerRadius: 16, depth: 0.92)
    }

    @ViewBuilder
    private func suitChartSection(title: String, caption: String, slices: [MysticTarotViewModel.ArcanaSlice]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline.weight(.bold))
                .tarotSectionTitleGradient(accent: .tarotPositive)
            Text(caption)
                .font(.caption)
                .foregroundColor(.gray)

            if slices.isEmpty {
                Text("No data yet.")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
                Chart(slices) { slice in
                    BarMark(
                        x: .value("Count", slice.count),
                        y: .value("Suit", slice.arcana.rawValue)
                    )
                    .foregroundStyle(color(for: slice.arcana))
                }
                .chartXAxis {
                    AxisMarks(position: .bottom)
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: CGFloat(max(140, slices.count * 36)))
            }
        }
        .padding(16)
        .tarotPanel(cornerRadius: 16, depth: 0.9)
        .padding(.horizontal)
    }

    private func color(for arcana: ArcanaType) -> Color {
        switch arcana {
        case .major: return .tarotPositive
        case .cups: return .cyan.opacity(0.85)
        case .wands: return .orange.opacity(0.85)
        case .swords: return .mint.opacity(0.85)
        case .pentacles: return .yellow.opacity(0.85)
        }
    }
}
