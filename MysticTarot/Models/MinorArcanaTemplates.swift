//
//  MinorArcanaTemplates.swift
//  MysticTarot
//

import Foundation

enum MinorArcanaTemplates {
    static let templateTag = "minor-template"

    static func placeholderCards() -> [TarotCard] {
        let suits: [(ArcanaType, String)] = [
            (.cups, "Cups"),
            (.wands, "Wands"),
            (.swords, "Swords"),
            (.pentacles, "Pentacles")
        ]
        let ranks = [
            "Ace", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight",
            "Nine", "Ten", "Page", "Knight", "Queen", "King"
        ]
        var cards: [TarotCard] = []
        for (arcana, suitName) in suits {
            for (idx, rank) in ranks.enumerated() {
                cards.append(
                    TarotCard(
                        id: UUID(),
                        name: "\(rank) of \(suitName)",
                        arcana: arcana,
                        number: idx + 1,
                        uprightMeaning: "Add your upright meaning.",
                        reversedMeaning: "Add your reversed meaning.",
                        description: "Placeholder card — edit symbolism and notes.",
                        keywords: [],
                        element: arcana.element,
                        planet: nil,
                        isFavorite: false,
                        createdAt: Date(),
                        userTags: [templateTag],
                        studyStatus: .notStarted,
                        lastReviewedAt: nil
                    )
                )
            }
        }
        return cards
    }
}
