//
//  SpreadEditorSheet.swift
//  MysticTarot
//

import SwiftUI

private struct SpreadLineDraft: Identifiable {
    let id: UUID
    var selectedCardId: UUID
    var position: Int
    var positionName: String
    var orientation: CardOrientation
    var notes: String
}

struct SpreadEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: MysticTarotViewModel
    private let existing: SpreadModel?

    @State private var name: String
    @State private var type: SpreadType
    @State private var question: String
    @State private var interpretation: String
    @State private var isFavorite: Bool
    @State private var lines: [SpreadLineDraft]

    init(viewModel: MysticTarotViewModel, spread: SpreadModel?) {
        self.viewModel = viewModel
        self.existing = spread
        _name = State(initialValue: spread?.name ?? "")
        _type = State(initialValue: spread?.type ?? .threeCard)
        _question = State(initialValue: spread?.question ?? "")
        _interpretation = State(initialValue: spread?.interpretation ?? "")
        _isFavorite = State(initialValue: spread?.isFavorite ?? false)

        let mapped: [SpreadLineDraft] =
            spread?.cards.map { c in
                SpreadLineDraft(
                    id: c.id,
                    selectedCardId: c.cardId,
                    position: c.position,
                    positionName: c.positionName,
                    orientation: c.orientation,
                    notes: c.notes ?? ""
                )
            } ?? []

        let seed: [SpreadLineDraft]
        if mapped.isEmpty, let firstId = viewModel.cards.first?.id {
            seed = [
                SpreadLineDraft(
                    id: UUID(),
                    selectedCardId: firstId,
                    position: 1,
                    positionName: "Focus",
                    orientation: .upright,
                    notes: ""
                )
            ]
        } else {
            seed = mapped
        }

        _lines = State(initialValue: seed)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Spread") {
                    VStack(alignment: .leading, spacing: 14) {
                        TextField("Title", text: $name)
                        Picker("Layout", selection: $type) {
                            ForEach(SpreadType.allCases, id: \.self) { value in
                                Label(value.rawValue, systemImage: value.icon).tag(value)
                            }
                        }
                        TextField("Question", text: $question, axis: .vertical)
                            .lineLimit(2 ... 6)
                        TextField("Interpretation / takeaway", text: $interpretation, axis: .vertical)
                            .lineLimit(3 ... 10)
                        Toggle("Favorite spread", isOn: $isFavorite)

                        Button {
                            applyPositionPreset()
                        } label: {
                            Label("Apply layout preset", systemImage: "square.grid.3x3.square")
                        }
                        .foregroundColor(.tarotPositive)
                        .disabled(viewModel.cards.isEmpty)
                    }
                    .tarotFormRowBackdrop()
                }

                Section("Cards in spread") {
                    if viewModel.cards.isEmpty {
                        Text("Add cards in the Cards tab to document a spread.")
                            .foregroundColor(.gray)
                            .tarotFormRowBackdrop()
                    } else {
                        ForEach(Array(lines.indices), id: \.self) { index in
                            lineEditor(bindingIndex: index)
                        }

                        Button {
                            guard let cid = viewModel.cards.first?.id else { return }
                            lines.append(
                                SpreadLineDraft(
                                    id: UUID(),
                                    selectedCardId: cid,
                                    position: (lines.max(by: { $0.position < $1.position })?.position ?? 0) + 1,
                                    positionName: "Position \(lines.count + 1)",
                                    orientation: .upright,
                                    notes: ""
                                )
                            )
                        } label: {
                            Label("Add position", systemImage: "plus.circle.fill")
                        }
                        .foregroundColor(.tarotPositive)
                        .tarotFormRowBackdrop()

                        Button(role: .destructive) {
                            if lines.count > 1 { lines.removeLast() }
                        } label: {
                            Label("Remove last position", systemImage: "minus.circle")
                        }
                        .disabled(lines.count <= 1)
                        .tarotFormRowBackdrop()
                    }
                }
            }
            .foregroundColor(.primary)
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
            .tarotScreenBackground()
            .tint(.tarotPositive)
            .navigationTitle(existing == nil ? "New Spread" : "Edit Spread")
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
                    .disabled(viewModel.cards.isEmpty || name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private func lineEditor(bindingIndex: Int) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Picker("Card", selection: $lines[bindingIndex].selectedCardId) {
                ForEach(viewModel.cards) { card in
                    Text(card.name).tag(card.id)
                }
            }
            Stepper("Position #: \(lines[bindingIndex].position)", value: $lines[bindingIndex].position, in: 1 ... 20)
            TextField("Position label (e.g. Past)", text: $lines[bindingIndex].positionName)
            Picker("Orientation", selection: $lines[bindingIndex].orientation) {
                ForEach(CardOrientation.allCases, id: \.self) { ori in
                    Label(ori.rawValue, systemImage: ori.icon).tag(ori)
                }
            }
            TextField("Spot notes", text: $lines[bindingIndex].notes, axis: .vertical)
                .lineLimit(2 ... 6)
        }
        .tarotFormRowBackdrop()
    }

    private func applyPositionPreset() {
        guard let firstId = viewModel.cards.first?.id else { return }
        let labels = SpreadPositionPresets.labels(for: type)
        lines = labels.enumerated().map { idx, positionName in
            SpreadLineDraft(
                id: UUID(),
                selectedCardId: firstId,
                position: idx + 1,
                positionName: positionName,
                orientation: .upright,
                notes: ""
            )
        }
    }

    private func save() {
        let mappedCards: [SpreadCardModel] = lines.map { line in
            let matched = viewModel.cards.first(where: { $0.id == line.selectedCardId })
            return SpreadCardModel(
                id: line.id,
                cardId: line.selectedCardId,
                cardName: matched?.name ?? "Unknown",
                position: line.position,
                positionName: line.positionName.isEmpty ? "Position \(line.position)" : line.positionName,
                orientation: line.orientation,
                notes: line.notes.isEmpty ? nil : line.notes
            )
        }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let now = Date()

        if let existing {
            let updated = SpreadModel(
                id: existing.id,
                date: existing.date,
                name: trimmedName,
                type: type,
                question: question,
                cards: mappedCards,
                interpretation: interpretation,
                isFavorite: isFavorite,
                createdAt: existing.createdAt
            )
            viewModel.updateSpread(updated)
        } else {
            let spread = SpreadModel(
                id: UUID(),
                date: now,
                name: trimmedName,
                type: type,
                question: question,
                cards: mappedCards,
                interpretation: interpretation,
                isFavorite: isFavorite,
                createdAt: now
            )
            viewModel.addSpread(spread)
        }
    }
}
