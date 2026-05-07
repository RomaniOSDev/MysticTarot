//
//  AddCardNoteSheet.swift
//  MysticTarot
//

import SwiftUI

struct AddCardNoteSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: MysticTarotViewModel
    let cardId: UUID

    @State private var content: String = ""
    @State private var tagsText: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Note") {
                    TextField("What did you notice?", text: $content, axis: .vertical)
                        .lineLimit(4 ... 12)
                        .tarotFormRowBackdrop()
                }

                Section("Tags") {
                    TextField("Comma-separated tags", text: $tagsText)
                        .tarotFormRowBackdrop()
                }
            }
            .foregroundColor(.primary)
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
            .tarotScreenBackground()
            .tint(.tarotPositive)
            .navigationTitle("New Note")
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
                        let tags = tagsText
                            .split(separator: ",")
                            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                            .filter { !$0.isEmpty }
                        let note = CardNote(
                            id: UUID(),
                            cardId: cardId,
                            date: Date(),
                            content: content,
                            tags: tags
                        )
                        viewModel.addCardNote(note)
                        dismiss()
                    }
                    .foregroundColor(.tarotPositive)
                    .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
