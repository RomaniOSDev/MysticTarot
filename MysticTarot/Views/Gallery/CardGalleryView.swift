//
//  CardGalleryView.swift
//  MysticTarot
//

import SwiftUI

struct CardGalleryView: View {
    @ObservedObject var viewModel: MysticTarotViewModel
    @Binding var navigationPath: NavigationPath
    @State private var showAddCard = false
    @State private var journalSheetCard: TarotCard?
    @State private var showFilters = false
    @State private var favoritesOnly = false
    @State private var studyFilter: CardStudyStatus?
    @State private var tagFilter = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Study your deck • \(viewModel.totalCards) cards • \(viewModel.totalSpreads) spreads")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        StatCard(
                            title: "Cards tracked",
                            value: "\(viewModel.totalCards)",
                            icon: "square.stack.3d.up.fill",
                            color: .tarotMystic
                        )
                        .frame(width: 168)

                        StatCard(
                            title: "Journal streak",
                            value: "\(viewModel.journalStreak)d",
                            icon: "flame.fill",
                            color: .tarotPositive
                        )
                        .frame(width: 168)

                        StatCard(
                            title: "Spread streak",
                            value: "\(viewModel.spreadStreak)d",
                            icon: "rectangle.stack.fill",
                            color: .tarotMystic
                        )
                        .frame(width: 168)

                        StatCard(
                            title: "Notes",
                            value: "\(viewModel.totalNotes)",
                            icon: "note.text",
                            color: .tarotMystic
                        )
                        .frame(width: 168)
                    }
                }
                .padding(.horizontal)

                filterChipsRow

                if let cardOfDay = viewModel.cardOfDay {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("✨ CARD OF THE DAY ✨")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.tarotPositive)

                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.tarotMystic)
                                .font(.largeTitle)

                            VStack(alignment: .leading) {
                                Text(cardOfDay.name)
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.white)

                                Text(cardOfDay.arcana.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.tarotMystic)
                            }

                            Spacer()

                            Text("Daily insight")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.tarotPositive.opacity(0.2))
                                .foregroundColor(.tarotPositive)
                                .cornerRadius(8)
                        }
                    }
                    .padding(16)
                    .tarotPanel(cornerRadius: 16, depth: 0.95)
                    .padding(.horizontal)
                    .onTapGesture {
                        navigationPath.append(cardOfDay.id)
                    }
                }

                LazyVStack(spacing: 20) {
                    CardSectionView(
                        title: "🌟 MAJOR ARCANA",
                        cards: viewModel.cards(in: .major, favoritesOnly: favoritesOnly, studyFilter: studyFilter, tagQuery: tagFilter),
                        color: .tarotPositive,
                        onSelect: { navigationPath.append($0.id) },
                        onToggleFavorite: { viewModel.toggleFavorite($0) },
                        onAddJournal: { journalSheetCard = $0 }
                    )

                    CardSectionView(
                        title: "💧 CUPS",
                        cards: viewModel.cards(in: .cups, favoritesOnly: favoritesOnly, studyFilter: studyFilter, tagQuery: tagFilter),
                        color: .tarotMystic,
                        onSelect: { navigationPath.append($0.id) },
                        onToggleFavorite: { viewModel.toggleFavorite($0) },
                        onAddJournal: { journalSheetCard = $0 }
                    )

                    CardSectionView(
                        title: "🔥 WANDS",
                        cards: viewModel.cards(in: .wands, favoritesOnly: favoritesOnly, studyFilter: studyFilter, tagQuery: tagFilter),
                        color: .tarotMystic,
                        onSelect: { navigationPath.append($0.id) },
                        onToggleFavorite: { viewModel.toggleFavorite($0) },
                        onAddJournal: { journalSheetCard = $0 }
                    )

                    CardSectionView(
                        title: "⚔️ SWORDS",
                        cards: viewModel.cards(in: .swords, favoritesOnly: favoritesOnly, studyFilter: studyFilter, tagQuery: tagFilter),
                        color: .tarotMystic,
                        onSelect: { navigationPath.append($0.id) },
                        onToggleFavorite: { viewModel.toggleFavorite($0) },
                        onAddJournal: { journalSheetCard = $0 }
                    )

                    CardSectionView(
                        title: "🪙 PENTACLES",
                        cards: viewModel.cards(in: .pentacles, favoritesOnly: favoritesOnly, studyFilter: studyFilter, tagQuery: tagFilter),
                        color: .tarotMystic,
                        onSelect: { navigationPath.append($0.id) },
                        onToggleFavorite: { viewModel.toggleFavorite($0) },
                        onAddJournal: { journalSheetCard = $0 }
                    )
                }
                .padding()
            }
            .padding(.top, 8)
        }
        .tarotScreenBackground()
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Your Deck")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.tarotPositive)
            }
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink {
                    StudyHubView(viewModel: viewModel)
                } label: {
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(.tarotPositive)
                }
                .accessibilityLabel("Study")
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 4) {
                    Button {
                        showFilters = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(.tarotPositive)
                    }
                    Menu {
                        Button {
                            viewModel.addMinorArcanaTemplatesIfEmpty()
                        } label: {
                            Label("Add minor arcana templates", systemImage: "square.grid.3x3.fill")
                        }
                        .disabled(viewModel.cards.contains(where: { $0.userTags.contains(MinorArcanaTemplates.templateTag) }))

                        Button {
                            showAddCard = true
                        } label: {
                            Label("New card", systemImage: "plus.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.tarotMystic)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddCard) {
            AddEditCardSheet(viewModel: viewModel, card: nil)
        }
        .sheet(isPresented: $showFilters) {
            NavigationStack {
                Form {
                    Section("Visibility") {
                        Toggle("Favorites only", isOn: $favoritesOnly)
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Study progress")
                                .font(.subheadline.weight(.semibold))
                            Button("All cards") { studyFilter = nil }
                                .foregroundColor(studyFilter == nil ? .tarotPositive : .primary)
                            ForEach(CardStudyStatus.allCases, id: \.self) { s in
                                Button(s.title) { studyFilter = s }
                                    .foregroundColor(studyFilter == s ? .tarotPositive : .primary)
                            }
                        }
                    }
                    Section("Tags & keywords") {
                        TextField("Search in tags or keywords", text: $tagFilter)
                    }
                }
                .foregroundColor(.primary)
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
                .tarotScreenBackground()
                .navigationTitle("Filters")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { showFilters = false }
                            .foregroundColor(.tarotPositive)
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
        .sheet(item: $journalSheetCard) { card in
            JournalEntrySheet(viewModel: viewModel, presetCard: card)
        }
    }

    private var filterChipsRow: some View {
        HStack(spacing: 8) {
            if favoritesOnly || studyFilter != nil || !tagFilter.isEmpty {
                Text("Filters on")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.tarotPositive)
            }
            if favoritesOnly {
                chip("Favorites")
            }
            if let s = studyFilter {
                chip(s.title)
            }
            if !tagFilter.isEmpty {
                chip("“\(tagFilter)”")
            }
            Spacer()
        }
        .padding(.horizontal)
        .opacity((favoritesOnly || studyFilter != nil || !tagFilter.isEmpty) ? 1 : 0)
    }

    private func chip(_ text: String) -> some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundColor(.white)
            .tarotLiftedSurface(cornerRadius: 10)
            .tarotFloatingShadow(depth: 0.65)
    }
}
