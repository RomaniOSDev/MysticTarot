//
//  CardSectionView.swift
//  MysticTarot
//

import SwiftUI

struct CardSectionView: View {
    let title: String
    let cards: [TarotCard]
    let color: Color
    var onSelect: (TarotCard) -> Void
    var onToggleFavorite: (TarotCard) -> Void
    var onAddJournal: (TarotCard) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline.weight(.bold))
                .tarotSectionTitleGradient(accent: color)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(cards) { card in
                        CardMiniature(card: card, color: color)
                            .onTapGesture {
                                onSelect(card)
                            }
                            .contextMenu {
                                Button {
                                    onToggleFavorite(card)
                                } label: {
                                    Label(card.isFavorite ? "Remove from favorites" : "Add to favorites", systemImage: "star")
                                }

                                Button {
                                    onAddJournal(card)
                                } label: {
                                    Label("Add journal entry", systemImage: "book")
                                }
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
