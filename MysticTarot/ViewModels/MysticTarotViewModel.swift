//
//  MysticTarotViewModel.swift
//  MysticTarot
//

import Combine
import Foundation

@MainActor
final class MysticTarotViewModel: ObservableObject {
    @Published var cards: [TarotCard] = []
    @Published var spreads: [SpreadModel] = []
    @Published var journalEntries: [TarotJournal] = []
    @Published var cardNotes: [CardNote] = []
    @Published private(set) var streaks = StreakSnapshot()

    init() {
        loadFromUserDefaults()
    }

    // MARK: - Streaks

    var journalStreak: Int { streaks.journalStreak }
    var spreadStreak: Int { streaks.spreadStreak }

    private func saveStreaks() {
        if let data = try? JSONEncoder().encode(streaks) {
            UserDefaults.standard.set(data, forKey: streaksKey)
        }
    }

    private func loadStreaks() {
        if let data = UserDefaults.standard.data(forKey: streaksKey),
           let decoded = try? JSONDecoder().decode(StreakSnapshot.self, from: data) {
            streaks = decoded
        }
        repairStaleStreaks()
    }

    private func repairStaleStreaks() {
        let cal = Calendar.current
        let todayStart = cal.startOfDay(for: Date())
        guard let yesterdayStart = cal.date(byAdding: .day, value: -1, to: todayStart) else { return }

        if let lj = streaks.lastJournalDay1970 {
            let lastJ = Date(timeIntervalSince1970: lj)
            if lastJ < yesterdayStart {
                streaks.journalStreak = 0
                streaks.lastJournalDay1970 = nil
            }
        }

        if let ls = streaks.lastSpreadDay1970 {
            let lastS = Date(timeIntervalSince1970: ls)
            if lastS < yesterdayStart {
                streaks.spreadStreak = 0
                streaks.lastSpreadDay1970 = nil
            }
        }
        saveStreaks()
    }

    private func registerJournalActivity() {
        let cal = Calendar.current
        let today = Date()
        let todayStart = cal.startOfDay(for: today)
        let t1970 = todayStart.timeIntervalSince1970

        if let lj = streaks.lastJournalDay1970 {
            let lastStart = Date(timeIntervalSince1970: lj)
            if cal.isDate(lastStart, inSameDayAs: today) {
                saveStreaks()
                return
            }
            if let yStart = cal.date(byAdding: .day, value: -1, to: todayStart),
               cal.isDate(lastStart, inSameDayAs: yStart) {
                streaks.journalStreak += 1
            } else {
                streaks.journalStreak = 1
            }
        } else {
            streaks.journalStreak = 1
        }
        streaks.lastJournalDay1970 = t1970
        saveStreaks()
    }

    private func registerSpreadActivity() {
        let cal = Calendar.current
        let today = Date()
        let todayStart = cal.startOfDay(for: today)
        let t1970 = todayStart.timeIntervalSince1970

        if let ls = streaks.lastSpreadDay1970 {
            let lastStart = Date(timeIntervalSince1970: ls)
            if cal.isDate(lastStart, inSameDayAs: today) {
                saveStreaks()
                return
            }
            if let yStart = cal.date(byAdding: .day, value: -1, to: todayStart),
               cal.isDate(lastStart, inSameDayAs: yStart) {
                streaks.spreadStreak += 1
            } else {
                streaks.spreadStreak = 1
            }
        } else {
            streaks.spreadStreak = 1
        }
        streaks.lastSpreadDay1970 = t1970
        saveStreaks()
    }

    // MARK: - Computed properties

    var totalCards: Int { cards.count }
    var totalSpreads: Int { spreads.count }
    var favoriteCards: Int { cards.filter(\.isFavorite).count }
    var totalNotes: Int { cardNotes.count }

    var majorArcana: [TarotCard] {
        cards.filter { $0.arcana == .major }.sorted { $0.number < $1.number }
    }

    var cupsArcana: [TarotCard] {
        cards.filter { $0.arcana == .cups }.sorted { $0.number < $1.number }
    }

    var wandsArcana: [TarotCard] {
        cards.filter { $0.arcana == .wands }.sorted { $0.number < $1.number }
    }

    var swordsArcana: [TarotCard] {
        cards.filter { $0.arcana == .swords }.sorted { $0.number < $1.number }
    }

    var pentaclesArcana: [TarotCard] {
        cards.filter { $0.arcana == .pentacles }.sorted { $0.number < $1.number }
    }

    /// Filter gallery rows by study, favorites, and tag text (matches card tags + keywords).
    func cards(
        in arcana: ArcanaType,
        favoritesOnly: Bool,
        studyFilter: CardStudyStatus?,
        tagQuery: String
    ) -> [TarotCard] {
        let q = tagQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return cards
            .filter { card in
                guard card.arcana == arcana else { return false }
                if favoritesOnly, !card.isFavorite { return false }
                if let studyFilter, card.studyStatus != studyFilter { return false }
                if !q.isEmpty {
                    let hay = (card.userTags + card.keywords + [card.name]).joined(separator: " ").lowercased()
                    if !hay.contains(q) { return false }
                }
                return true
            }
            .sorted { $0.number < $1.number }
    }

    var cardOfDay: TarotCard? {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        guard !cards.isEmpty else { return nil }
        return cards[dayOfYear % cards.count]
    }

    struct FrequentCard: Identifiable {
        var id: String { name }
        let name: String
        let count: Int
    }

    var frequentCards: [FrequentCard] {
        let allCardNames = spreads.flatMap { $0.cards.map(\.cardName) }
        let grouped = Dictionary(grouping: allCardNames, by: { $0 })
        return grouped.map { name, occurrences in
            FrequentCard(name: name, count: occurrences.count)
        }
        .sorted { $0.count > $1.count }
        .prefix(5)
        .map { $0 }
    }

    struct ArcanaStat: Identifiable {
        var id: String { arcana.rawValue }
        let arcana: ArcanaType
        var name: String { arcana.rawValue }
        var icon: String { arcana.icon }
        let count: Int
    }

    var arcanaStats: [ArcanaStat] {
        let grouped = Dictionary(grouping: cards, by: \.arcana)
        return grouped.map { arcana, cardsInGroup in
            ArcanaStat(arcana: arcana, count: cardsInGroup.count)
        }
        .sorted { $0.count > $1.count }
    }

    struct ArcanaSlice: Identifiable {
        var id: String { arcana.rawValue }
        let arcana: ArcanaType
        let count: Int
    }

    /// Journal entries weighted by linked card’s suit / major.
    func journalArcanaDistribution() -> [ArcanaSlice] {
        var counts: [ArcanaType: Int] = [:]
        for entry in journalEntries {
            guard let card = cards.first(where: { $0.id == entry.cardId }) else { continue }
            counts[card.arcana, default: 0] += 1
        }
        return ArcanaType.allCases.compactMap { a in
            let c = counts[a] ?? 0
            return c > 0 ? ArcanaSlice(arcana: a, count: c) : nil
        }
        .sorted { $0.count > $1.count }
    }

    /// Cards drawn in spreads (by deck link).
    func spreadArcanaDistribution() -> [ArcanaSlice] {
        var counts: [ArcanaType: Int] = [:]
        for spread in spreads {
            for sc in spread.cards {
                guard let card = cards.first(where: { $0.id == sc.cardId }) else { continue }
                counts[card.arcana, default: 0] += 1
            }
        }
        return ArcanaType.allCases.compactMap { a in
            let c = counts[a] ?? 0
            return c > 0 ? ArcanaSlice(arcana: a, count: c) : nil
        }
        .sorted { $0.count > $1.count }
    }

    func sortedJournalEntries(search: String) -> [TarotJournal] {
        let q = search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let base: [TarotJournal]
        if q.isEmpty {
            base = journalEntries
        } else {
            base = journalEntries.filter { e in
                e.reflection.lowercased().contains(q)
                    || e.cardName.lowercased().contains(q)
                    || (e.mood?.lowercased().contains(q) ?? false)
            }
        }
        return base.sorted { a, b in
            if a.isPinned != b.isPinned { return a.isPinned && !b.isPinned }
            return a.date > b.date
        }
    }

    func notes(for cardId: UUID) -> [CardNote] {
        cardNotes.filter { $0.cardId == cardId }.sorted { $0.date > $1.date }
    }

    func markCardReviewedNow(_ card: TarotCard) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        cards[index].lastReviewedAt = Date()
        saveToUserDefaults()
    }

    func setStudyStatus(_ card: TarotCard, status: CardStudyStatus) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        cards[index].studyStatus = status
        saveToUserDefaults()
    }

    func addMinorArcanaTemplatesIfEmpty() {
        guard !cards.contains(where: { $0.userTags.contains(MinorArcanaTemplates.templateTag) }) else { return }
        cards.append(contentsOf: MinorArcanaTemplates.placeholderCards())
        saveToUserDefaults()
    }

    func duplicateSpread(_ spread: SpreadModel) {
        let now = Date()
        let newCards = spread.cards.map { c in
            SpreadCardModel(
                id: UUID(),
                cardId: c.cardId,
                cardName: c.cardName,
                position: c.position,
                positionName: c.positionName,
                orientation: c.orientation,
                notes: c.notes
            )
        }
        let copy = SpreadModel(
            id: UUID(),
            date: now,
            name: "\(spread.name) (copy)",
            type: spread.type,
            question: spread.question,
            cards: newCards,
            interpretation: spread.interpretation,
            isFavorite: false,
            createdAt: now
        )
        spreads.append(copy)
        registerSpreadActivity()
        saveToUserDefaults()
    }

    func exportSpreadPlainText(_ spread: SpreadModel) -> String {
        var lines: [String] = []
        lines.append(spread.name)
        lines.append("Type: \(spread.type.rawValue)")
        lines.append("Date: \(formattedShortDate(spread.date))")
        lines.append("Question: \(spread.question)")
        lines.append("")
        lines.append("Cards:")
        for c in spread.cards.sorted(by: { $0.position < $1.position }) {
            lines.append(
                "  \(c.position). \(c.positionName) — \(c.cardName) (\(c.orientation.rawValue))"
            )
            if let n = c.notes, !n.isEmpty {
                lines.append("     Notes: \(n)")
            }
        }
        lines.append("")
        lines.append("Interpretation:")
        lines.append(spread.interpretation)
        return lines.joined(separator: "\n")
    }

    // MARK: - Cards

    func addCard(_ card: TarotCard) {
        cards.append(card)
        saveToUserDefaults()
    }

    func updateCard(_ card: TarotCard) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index] = card
            saveToUserDefaults()
        }
    }

    func deleteCard(_ card: TarotCard) {
        cards.removeAll { $0.id == card.id }
        cardNotes.removeAll { $0.cardId == card.id }
        spreads = spreads.map { spread in
            var s = spread
            s.cards.removeAll { $0.cardId == card.id }
            return s
        }
        journalEntries.removeAll { $0.cardId == card.id }
        saveToUserDefaults()
    }

    func toggleFavorite(_ card: TarotCard) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index].isFavorite.toggle()
            saveToUserDefaults()
        }
    }

    // MARK: - Spreads

    func addSpread(_ spread: SpreadModel) {
        spreads.append(spread)
        registerSpreadActivity()
        saveToUserDefaults()
    }

    func updateSpread(_ spread: SpreadModel) {
        if let index = spreads.firstIndex(where: { $0.id == spread.id }) {
            spreads[index] = spread
            saveToUserDefaults()
        }
    }

    func deleteSpread(_ spread: SpreadModel) {
        spreads.removeAll { $0.id == spread.id }
        saveToUserDefaults()
    }

    func toggleFavoriteSpread(_ spread: SpreadModel) {
        if let index = spreads.firstIndex(where: { $0.id == spread.id }) {
            spreads[index].isFavorite.toggle()
            saveToUserDefaults()
        }
    }

    // MARK: - Journal

    func addJournalEntry(_ entry: TarotJournal) {
        journalEntries.append(entry)
        registerJournalActivity()
        saveToUserDefaults()
    }

    func updateJournalEntry(_ entry: TarotJournal) {
        if let index = journalEntries.firstIndex(where: { $0.id == entry.id }) {
            journalEntries[index] = entry
            saveToUserDefaults()
        }
    }

    func deleteJournalEntry(_ entry: TarotJournal) {
        journalEntries.removeAll { $0.id == entry.id }
        saveToUserDefaults()
    }

    func toggleFavoriteJournalEntry(_ entry: TarotJournal) {
        if let index = journalEntries.firstIndex(where: { $0.id == entry.id }) {
            journalEntries[index].isFavorite.toggle()
            saveToUserDefaults()
        }
    }

    func togglePinJournalEntry(_ entry: TarotJournal) {
        if let index = journalEntries.firstIndex(where: { $0.id == entry.id }) {
            journalEntries[index].isPinned.toggle()
            saveToUserDefaults()
        }
    }

    // MARK: - Notes

    func addCardNote(_ note: CardNote) {
        cardNotes.append(note)
        saveToUserDefaults()
    }

    func updateCardNote(_ note: CardNote) {
        if let index = cardNotes.firstIndex(where: { $0.id == note.id }) {
            cardNotes[index] = note
            saveToUserDefaults()
        }
    }

    func deleteCardNote(_ note: CardNote) {
        cardNotes.removeAll { $0.id == note.id }
        saveToUserDefaults()
    }

    // MARK: - Persistence

    private let cardsKey = "mystictarot_cards"
    private let spreadsKey = "mystictarot_spreads"
    private let journalKey = "mystictarot_journal"
    private let notesKey = "mystictarot_notes"
    private let streaksKey = "mystictarot_streaks"

    func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(cards) {
            UserDefaults.standard.set(encoded, forKey: cardsKey)
        }
        if let encoded = try? JSONEncoder().encode(spreads) {
            UserDefaults.standard.set(encoded, forKey: spreadsKey)
        }
        if let encoded = try? JSONEncoder().encode(journalEntries) {
            UserDefaults.standard.set(encoded, forKey: journalKey)
        }
        if let encoded = try? JSONEncoder().encode(cardNotes) {
            UserDefaults.standard.set(encoded, forKey: notesKey)
        }
        saveStreaks()
    }

    func loadFromUserDefaults() {
        loadStreaks()

        if let data = UserDefaults.standard.data(forKey: cardsKey),
           let decoded = try? JSONDecoder().decode([TarotCard].self, from: data) {
            cards = decoded
        }

        if let data = UserDefaults.standard.data(forKey: spreadsKey),
           let decoded = try? JSONDecoder().decode([SpreadModel].self, from: data) {
            spreads = decoded
        }

        if let data = UserDefaults.standard.data(forKey: journalKey),
           let decoded = try? JSONDecoder().decode([TarotJournal].self, from: data) {
            journalEntries = decoded
        }

        if let data = UserDefaults.standard.data(forKey: notesKey),
           let decoded = try? JSONDecoder().decode([CardNote].self, from: data) {
            cardNotes = decoded
        }

        if cards.isEmpty {
            loadDemoData()
        }
    }

    private func loadDemoData() {
        let card1 = TarotCard(
            id: UUID(),
            name: "The Fool",
            arcana: .major,
            number: 0,
            uprightMeaning: "New beginnings, spontaneity, faith in life",
            reversedMeaning: "Recklessness, chaos, naive risk",
            description: "The Fool marks the start of a path — a blank page and a spirit of possibilities.",
            keywords: ["beginning", "freedom", "wild card"],
            element: ArcanaType.major.element,
            planet: "Uranus",
            isFavorite: true,
            createdAt: Date()
        )

        let card2 = TarotCard(
            id: UUID(),
            name: "The Magician",
            arcana: .major,
            number: 1,
            uprightMeaning: "Willpower, concentration, manifestation",
            reversedMeaning: "Manipulation, scattered focus, indecision",
            description: "The Magician channels intention into tangible results.",
            keywords: ["power", "skill", "resourcefulness"],
            element: ArcanaType.major.element,
            planet: "Mercury",
            isFavorite: false,
            createdAt: Date()
        )

        cards = [card1, card2]

        let spread = SpreadModel(
            id: UUID(),
            date: Date(),
            name: "Daily draw",
            type: .oneCard,
            question: "What awaits me today?",
            cards: [],
            interpretation: "Opportunities and fresh openings ahead.",
            isFavorite: true,
            createdAt: Date()
        )

        spreads = [spread]
        saveToUserDefaults()
    }
}
