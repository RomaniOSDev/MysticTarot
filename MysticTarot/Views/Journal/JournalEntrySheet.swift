//
//  JournalEntrySheet.swift
//  MysticTarot
//

import SwiftUI

struct JournalEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: MysticTarotViewModel
    let presetCard: TarotCard?
    let existing: TarotJournal?

    @State private var selectedCardId: UUID
    @State private var reflection: String
    @State private var mood: String
    @State private var isPinned: Bool

    init(viewModel: MysticTarotViewModel, presetCard: TarotCard? = nil, existing: TarotJournal? = nil) {
        self.viewModel = viewModel
        self.presetCard = presetCard
        self.existing = existing

        let initialId = existing?.cardId ?? presetCard?.id ?? viewModel.cards.first?.id ?? UUID()
        _selectedCardId = State(initialValue: initialId)
        _reflection = State(initialValue: existing?.reflection ?? "")
        _mood = State(initialValue: existing?.mood ?? "")
        _isPinned = State(initialValue: existing?.isPinned ?? false)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Card") {
                    Group {
                        if viewModel.cards.isEmpty {
                            Text("Add a card in the Cards tab first.")
                                .foregroundColor(.gray)
                        } else {
                            Picker("Linked card", selection: $selectedCardId) {
                                ForEach(viewModel.cards) { card in
                                    Text(card.name).tag(card.id)
                                }
                            }
                        }
                    }
                    .tarotFormRowBackdrop()
                }

                Section("Reflection") {
                    VStack(alignment: .leading, spacing: 14) {
                        TextField("Write your thoughts", text: $reflection, axis: .vertical)
                            .lineLimit(4 ... 14)
                        TextField("Mood (optional)", text: $mood)
                        Toggle("Pin to top", isOn: $isPinned)
                    }
                    .tarotFormRowBackdrop()
                }
            }
            .foregroundColor(.primary)
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
            .tarotScreenBackground()
            .tint(.tarotPositive)
            .navigationTitle(existing == nil ? "New Journal Entry" : "Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.tarotBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.tarotPositive)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .foregroundColor(.tarotPositive)
                    .disabled(viewModel.cards.isEmpty || reflection.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func save() {
        guard let linked = viewModel.cards.first(where: { $0.id == selectedCardId }) else { return }
        let moodValue = mood.trimmingCharacters(in: .whitespacesAndNewlines)
        if let existing {
            let updated = TarotJournal(
                id: existing.id,
                date: existing.date,
                cardId: linked.id,
                cardName: linked.name,
                reflection: reflection,
                mood: moodValue.isEmpty ? nil : moodValue,
                isFavorite: existing.isFavorite,
                isPinned: isPinned
            )
            viewModel.updateJournalEntry(updated)
        } else {
            let entry = TarotJournal(
                id: UUID(),
                date: Date(),
                cardId: linked.id,
                cardName: linked.name,
                reflection: reflection,
                mood: moodValue.isEmpty ? nil : moodValue,
                isFavorite: false,
                isPinned: isPinned
            )
            viewModel.addJournalEntry(entry)
        }
    }
}
