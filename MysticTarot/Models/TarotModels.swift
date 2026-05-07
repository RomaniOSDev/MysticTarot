//
//  TarotModels.swift
//  MysticTarot
//

import Foundation

enum ArcanaType: String, CaseIterable, Codable {
    case major = "Major Arcana"
    case cups = "Cups"
    case wands = "Wands"
    case swords = "Swords"
    case pentacles = "Pentacles"

    var icon: String {
        switch self {
        case .major: return "star.fill"
        case .cups: return "drop.fill"
        case .wands: return "flame.fill"
        case .swords: return "wind"
        case .pentacles: return "circle.fill"
        }
    }

    var element: String {
        switch self {
        case .major: return "Spirit"
        case .cups: return "Water"
        case .wands: return "Fire"
        case .swords: return "Air"
        case .pentacles: return "Earth"
        }
    }
}

enum CardStudyStatus: String, CaseIterable, Codable {
    case notStarted
    case learning
    case learned

    var title: String {
        switch self {
        case .notStarted: return "New"
        case .learning: return "Learning"
        case .learned: return "Known"
        }
    }
}

enum CardOrientation: String, CaseIterable, Codable {
    case upright = "Upright"
    case reversed = "Reversed"

    var icon: String {
        switch self {
        case .upright: return "arrow.up"
        case .reversed: return "arrow.down"
        }
    }
}

enum SpreadType: String, CaseIterable, Codable {
    case oneCard = "One Card"
    case threeCard = "Three Cards"
    case celticCross = "Celtic Cross"
    case relationship = "Relationship"
    case career = "Career"
    case custom = "Custom"

    var icon: String {
        switch self {
        case .oneCard: return "1.circle"
        case .threeCard: return "3.circle"
        case .celticCross: return "plus"
        case .relationship: return "heart.fill"
        case .career: return "briefcase.fill"
        case .custom: return "star.fill"
        }
    }
}

struct TarotCard: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var arcana: ArcanaType
    var number: Int
    var uprightMeaning: String
    var reversedMeaning: String
    var description: String
    var keywords: [String]
    var element: String?
    var planet: String?
    var isFavorite: Bool
    let createdAt: Date
    var userTags: [String]
    var studyStatus: CardStudyStatus
    var lastReviewedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, name, arcana, number, uprightMeaning, reversedMeaning, description
        case keywords, element, planet, isFavorite, createdAt
        case userTags, studyStatus, lastReviewedAt
    }

    init(
        id: UUID,
        name: String,
        arcana: ArcanaType,
        number: Int,
        uprightMeaning: String,
        reversedMeaning: String,
        description: String,
        keywords: [String],
        element: String?,
        planet: String?,
        isFavorite: Bool,
        createdAt: Date,
        userTags: [String] = [],
        studyStatus: CardStudyStatus = .notStarted,
        lastReviewedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.arcana = arcana
        self.number = number
        self.uprightMeaning = uprightMeaning
        self.reversedMeaning = reversedMeaning
        self.description = description
        self.keywords = keywords
        self.element = element
        self.planet = planet
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.userTags = userTags
        self.studyStatus = studyStatus
        self.lastReviewedAt = lastReviewedAt
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        arcana = try c.decode(ArcanaType.self, forKey: .arcana)
        number = try c.decode(Int.self, forKey: .number)
        uprightMeaning = try c.decode(String.self, forKey: .uprightMeaning)
        reversedMeaning = try c.decode(String.self, forKey: .reversedMeaning)
        description = try c.decode(String.self, forKey: .description)
        keywords = try c.decode([String].self, forKey: .keywords)
        element = try c.decodeIfPresent(String.self, forKey: .element)
        planet = try c.decodeIfPresent(String.self, forKey: .planet)
        isFavorite = try c.decode(Bool.self, forKey: .isFavorite)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
        userTags = try c.decodeIfPresent([String].self, forKey: .userTags) ?? []
        studyStatus = try c.decodeIfPresent(CardStudyStatus.self, forKey: .studyStatus) ?? .notStarted
        lastReviewedAt = try c.decodeIfPresent(Date.self, forKey: .lastReviewedAt)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(arcana, forKey: .arcana)
        try c.encode(number, forKey: .number)
        try c.encode(uprightMeaning, forKey: .uprightMeaning)
        try c.encode(reversedMeaning, forKey: .reversedMeaning)
        try c.encode(description, forKey: .description)
        try c.encode(keywords, forKey: .keywords)
        try c.encodeIfPresent(element, forKey: .element)
        try c.encodeIfPresent(planet, forKey: .planet)
        try c.encode(isFavorite, forKey: .isFavorite)
        try c.encode(createdAt, forKey: .createdAt)
        try c.encode(userTags, forKey: .userTags)
        try c.encode(studyStatus, forKey: .studyStatus)
        try c.encodeIfPresent(lastReviewedAt, forKey: .lastReviewedAt)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: TarotCard, rhs: TarotCard) -> Bool {
        lhs.id == rhs.id
    }
}

struct SpreadModel: Identifiable, Codable, Hashable {
    let id: UUID
    let date: Date
    var name: String
    var type: SpreadType
    var question: String
    var cards: [SpreadCardModel]
    var interpretation: String
    var isFavorite: Bool
    let createdAt: Date

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: SpreadModel, rhs: SpreadModel) -> Bool {
        lhs.id == rhs.id
    }
}

struct SpreadCardModel: Identifiable, Codable, Hashable {
    let id: UUID
    let cardId: UUID
    var cardName: String
    var position: Int
    var positionName: String
    var orientation: CardOrientation
    var notes: String?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: SpreadCardModel, rhs: SpreadCardModel) -> Bool {
        lhs.id == rhs.id
    }
}

struct CardNote: Identifiable, Codable, Hashable {
    let id: UUID
    let cardId: UUID
    let date: Date
    var content: String
    var tags: [String]

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: CardNote, rhs: CardNote) -> Bool {
        lhs.id == rhs.id
    }
}

struct TarotJournal: Identifiable, Codable, Hashable {
    let id: UUID
    let date: Date
    var cardId: UUID
    var cardName: String
    var reflection: String
    var mood: String?
    var isFavorite: Bool
    var isPinned: Bool

    enum CodingKeys: String, CodingKey {
        case id, date, cardId, cardName, reflection, mood, isFavorite, isPinned
    }

    init(
        id: UUID,
        date: Date,
        cardId: UUID,
        cardName: String,
        reflection: String,
        mood: String?,
        isFavorite: Bool,
        isPinned: Bool = false
    ) {
        self.id = id
        self.date = date
        self.cardId = cardId
        self.cardName = cardName
        self.reflection = reflection
        self.mood = mood
        self.isFavorite = isFavorite
        self.isPinned = isPinned
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        date = try c.decode(Date.self, forKey: .date)
        cardId = try c.decode(UUID.self, forKey: .cardId)
        cardName = try c.decode(String.self, forKey: .cardName)
        reflection = try c.decode(String.self, forKey: .reflection)
        mood = try c.decodeIfPresent(String.self, forKey: .mood)
        isFavorite = try c.decode(Bool.self, forKey: .isFavorite)
        isPinned = try c.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(date, forKey: .date)
        try c.encode(cardId, forKey: .cardId)
        try c.encode(cardName, forKey: .cardName)
        try c.encode(reflection, forKey: .reflection)
        try c.encodeIfPresent(mood, forKey: .mood)
        try c.encode(isFavorite, forKey: .isFavorite)
        try c.encode(isPinned, forKey: .isPinned)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: TarotJournal, rhs: TarotJournal) -> Bool {
        lhs.id == rhs.id
    }
}

struct StreakSnapshot: Codable, Equatable {
    var journalStreak: Int = 0
    var spreadStreak: Int = 0
    var lastJournalDay1970: Double?
    var lastSpreadDay1970: Double?
}
