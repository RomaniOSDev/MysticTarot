//
//  AddEditCardSheet.swift
//  MysticTarot
//

import SwiftUI

struct AddEditCardSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: MysticTarotViewModel
    private let existing: TarotCard?

    @State private var name: String
    @State private var arcana: ArcanaType
    @State private var number: String
    @State private var uprightMeaning: String
    @State private var reversedMeaning: String
    @State private var cardDescription: String
    @State private var keywordsText: String
    @State private var element: String
    @State private var planet: String
    @State private var isFavorite: Bool
    @State private var userTagsText: String
    @State private var studyStatus: CardStudyStatus

    init(viewModel: MysticTarotViewModel, card: TarotCard?) {
        self.viewModel = viewModel
        self.existing = card
        _name = State(initialValue: card?.name ?? "")
        _arcana = State(initialValue: card?.arcana ?? .major)
        _number = State(initialValue: card.map { String($0.number) } ?? "0")
        _uprightMeaning = State(initialValue: card?.uprightMeaning ?? "")
        _reversedMeaning = State(initialValue: card?.reversedMeaning ?? "")
        _cardDescription = State(initialValue: card?.description ?? "")
        _keywordsText = State(initialValue: card.map { $0.keywords.joined(separator: ", ") } ?? "")
        _element = State(initialValue: card?.element ?? "")
        _planet = State(initialValue: card?.planet ?? "")
        _isFavorite = State(initialValue: card?.isFavorite ?? false)
        _userTagsText = State(initialValue: card.map { $0.userTags.joined(separator: ", ") } ?? "")
        _studyStatus = State(initialValue: card?.studyStatus ?? .notStarted)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Identity") {
                    VStack(alignment: .leading, spacing: 14) {
                        TextField("Name", text: $name)
                        Picker("Suit / arcana", selection: $arcana) {
                            ForEach(ArcanaType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        TextField("Number (0–21 major, 1–14 minor)", text: $number)
                            .keyboardType(.numberPad)
                    }
                    .tarotFormRowBackdrop()
                }

                Section("Meanings") {
                    VStack(alignment: .leading, spacing: 14) {
                        TextField("Upright", text: $uprightMeaning, axis: .vertical)
                            .lineLimit(3 ... 8)
                        TextField("Reversed", text: $reversedMeaning, axis: .vertical)
                            .lineLimit(3 ... 8)
                    }
                    .tarotFormRowBackdrop()
                }

                Section("Details") {
                    VStack(alignment: .leading, spacing: 14) {
                        TextField("Description / symbolism", text: $cardDescription, axis: .vertical)
                            .lineLimit(4 ... 12)
                        TextField("Keywords (comma-separated)", text: $keywordsText)
                        TextField("Your tags (comma-separated)", text: $userTagsText)
                        TextField("Element (optional)", text: $element)
                        TextField("Planet (optional)", text: $planet)
                        Picker("Study progress", selection: $studyStatus) {
                            ForEach(CardStudyStatus.allCases, id: \.self) { s in
                                Text(s.title).tag(s)
                            }
                        }
                        Toggle("Favorite", isOn: $isFavorite)
                    }
                    .tarotFormRowBackdrop()
                }
            }
            .foregroundColor(.primary)
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
            .tarotScreenBackground()
            .tint(.tarotPositive)
            .navigationTitle(existing == nil ? "New Card" : "Edit Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.tarotBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.tarotPositive)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save(); dismiss() }
                        .foregroundColor(.tarotPositive)
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func save() {
        let trimmedKeywords = keywordsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let trimmedUserTags = userTagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let num = Int(number) ?? 0
        let elementValue = element.trimmingCharacters(in: .whitespacesAndNewlines)
        let planetValue = planet.trimmingCharacters(in: .whitespacesAndNewlines)

        if let existing {
            let updated = TarotCard(
                id: existing.id,
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                arcana: arcana,
                number: num,
                uprightMeaning: uprightMeaning,
                reversedMeaning: reversedMeaning,
                description: cardDescription,
                keywords: trimmedKeywords,
                element: elementValue.isEmpty ? nil : elementValue,
                planet: planetValue.isEmpty ? nil : planetValue,
                isFavorite: isFavorite,
                createdAt: existing.createdAt,
                userTags: trimmedUserTags,
                studyStatus: studyStatus,
                lastReviewedAt: existing.lastReviewedAt
            )
            viewModel.updateCard(updated)
        } else {
            let card = TarotCard(
                id: UUID(),
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                arcana: arcana,
                number: num,
                uprightMeaning: uprightMeaning,
                reversedMeaning: reversedMeaning,
                description: cardDescription,
                keywords: trimmedKeywords,
                element: elementValue.isEmpty ? nil : elementValue,
                planet: planetValue.isEmpty ? nil : planetValue,
                isFavorite: isFavorite,
                createdAt: Date(),
                userTags: trimmedUserTags,
                studyStatus: studyStatus,
                lastReviewedAt: nil
            )
            viewModel.addCard(card)
        }
    }
}
