//
//  CardDetailView.swift
//  MysticTarot
//

import SwiftUI

struct CardDetailView: View {
    @ObservedObject var viewModel: MysticTarotViewModel
    let cardId: UUID
    @Binding var navigationPath: NavigationPath
    @State private var showEditSheet = false
    @State private var showDeleteConfirmation = false
    @State private var showNoteSheet = false

    private var card: TarotCard? {
        viewModel.cards.first(where: { $0.id == cardId })
    }

    private var cardNotes: [CardNote] {
        viewModel.notes(for: cardId)
    }

    var body: some View {
        Group {
            if let card {
                ScrollView {
                    VStack(spacing: 24) {
                        header(card)
                        studySection(card)
                        if !card.userTags.isEmpty {
                            userTagsSection(card)
                        }
                        meanings(card)
                        if !card.keywords.isEmpty {
                            keywordsSection(card)
                        }
                        descriptionSection(card)
                        if card.element != nil || card.planet != nil {
                            metaSection(card)
                        }
                        notesSection
                        actions
                    }
                    .padding(.bottom, 24)
                }
                .tarotScreenBackground()
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "trash.circle")
                        .font(.system(size: 48))
                        .foregroundColor(.tarotMystic)
                    Text("This card no longer exists.")
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .tarotScreenBackground()
                .onAppear {
                    if !navigationPath.isEmpty {
                        navigationPath.removeLast(navigationPath.count)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEditSheet) {
            if let card {
                AddEditCardSheet(viewModel: viewModel, card: card)
            }
        }
        .sheet(isPresented: $showNoteSheet) {
            AddCardNoteSheet(viewModel: viewModel, cardId: cardId)
        }
        .alert("Delete card?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let card { viewModel.deleteCard(card); navigationPath.removeLast() }
            }
        } message: {
            Text("This also removes linked notes from this screen and unattached spreads still keep manual names.")
        }
    }

    @ViewBuilder
    private func header(_ card: TarotCard) -> some View {
        VStack(alignment: .center, spacing: 8) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.tarotMystic)

            Text(card.name)
                .font(.largeTitle)
                .bold()
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Color.white.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.35), radius: 4, x: 0, y: 2)

            Text("\(card.arcana.rawValue) • No. \(card.number)")
                .font(.subheadline)
                .foregroundColor(.tarotMystic)

            if card.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundStyle(
                        LinearGradient(colors: [.tarotPositive, .yellow.opacity(0.9)], startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(color: .tarotPositive.opacity(0.45), radius: 6)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .tarotPanel(cornerRadius: 22, depth: 0.95)
        .padding(.horizontal)
    }

    @ViewBuilder
    private func studySection(_ card: TarotCard) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Study")
                .font(.headline.weight(.bold))
                .tarotSectionTitleGradient(accent: .tarotPositive)

            Picker(
                "Progress",
                selection: Binding(
                    get: { viewModel.cards.first(where: { $0.id == card.id })?.studyStatus ?? card.studyStatus },
                    set: { viewModel.setStudyStatus(card, status: $0) }
                )
            ) {
                ForEach(CardStudyStatus.allCases, id: \.self) { s in
                    Text(s.title).tag(s)
                }
            }
            .pickerStyle(.segmented)
            .colorMultiply(.white.opacity(0.95))

            if let last = viewModel.cards.first(where: { $0.id == card.id })?.lastReviewedAt {
                Text("Last review: \(formattedShortDate(last))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Button {
                viewModel.markCardReviewedNow(card)
            } label: {
                Label("Mark reviewed today", systemImage: "checkmark.circle.fill")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [Color.tarotPositive.opacity(0.35), Color.tarotMystic.opacity(0.22)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundColor(.tarotPositive)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(Color.tarotPositive.opacity(0.45), lineWidth: 1)
                    )
                    .shadow(color: .tarotPositive.opacity(0.25), radius: 10, y: 4)
            }
        }
        .padding(16)
        .tarotPanel(cornerRadius: 18, depth: 0.9)
        .padding(.horizontal)
    }

    @ViewBuilder
    private func userTagsSection(_ card: TarotCard) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your tags")
                .font(.headline.weight(.bold))
                .tarotSectionTitleGradient(accent: .tarotPositive)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(card.userTags, id: \.self) { tag in
                        Text(tag)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .foregroundColor(.white)
                            .tarotLiftedSurface(cornerRadius: 10)
                            .tarotFloatingShadow(depth: 0.55)
                    }
                }
            }
        }
        .padding(16)
        .tarotPanel(cornerRadius: 16, depth: 0.82)
        .padding(.horizontal)
    }

    @ViewBuilder
    private func meanings(_ card: TarotCard) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 10) {
                Text("📖 Upright meaning")
                    .font(.headline.weight(.bold))
                    .tarotSectionTitleGradient(accent: .tarotPositive)

                Text(card.uprightMeaning)
                    .foregroundColor(.white)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .tarotLiftedSurface(cornerRadius: 12)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("🔄 Reversed meaning")
                    .font(.headline.weight(.bold))
                    .tarotSectionTitleGradient(accent: .tarotMystic)

                Text(card.reversedMeaning)
                    .foregroundColor(.white)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .tarotLiftedSurface(cornerRadius: 12)
            }
        }
        .padding(16)
        .tarotPanel(cornerRadius: 18, depth: 0.88)
        .padding(.horizontal)
    }

    @ViewBuilder
    private func keywordsSection(_ card: TarotCard) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("🔮 Keywords")
                .font(.headline.weight(.bold))
                .tarotSectionTitleGradient(accent: .tarotPositive)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(card.keywords, id: \.self) { keyword in
                        Text(keyword)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .foregroundColor(.tarotPositive)
                            .tarotLiftedSurface(cornerRadius: 12)
                            .tarotFloatingShadow(depth: 0.5)
                    }
                }
            }
        }
        .padding(16)
        .tarotPanel(cornerRadius: 16, depth: 0.82)
        .padding(.horizontal)
    }

    @ViewBuilder
    private func descriptionSection(_ card: TarotCard) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("✨ Description")
                .font(.headline.weight(.bold))
                .tarotSectionTitleGradient(accent: .tarotPositive)

            Text(card.description)
                .foregroundColor(.white)
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .tarotLiftedSurface(cornerRadius: 12)
        }
        .padding(16)
        .tarotPanel(cornerRadius: 16, depth: 0.85)
        .padding(.horizontal)
    }

    @ViewBuilder
    private func metaSection(_ card: TarotCard) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Celestial & elemental")
                .font(.headline.weight(.bold))
                .tarotSectionTitleGradient(accent: .tarotPositive)
            if let element = card.element, !element.isEmpty {
                Text("Element: \(element)")
                    .foregroundColor(.white)
            }
            if let planet = card.planet, !planet.isEmpty {
                Text("Planet / energy: \(planet)")
                    .foregroundColor(.white)
            }
            Text("Suit archetype: \(card.arcana.element)")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .tarotPanel(cornerRadius: 16, depth: 0.8)
        .padding(.horizontal)
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("✍️ Notes")
                    .font(.headline.weight(.bold))
                    .tarotSectionTitleGradient(accent: .tarotPositive)
                Spacer()
                Button("Add") { showNoteSheet = true }
                    .foregroundColor(.tarotMystic)
            }
            .padding(.horizontal)

            if cardNotes.isEmpty {
                Text("Capture personal associations and study snippets.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            } else {
                ForEach(cardNotes) { note in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(formattedShortDate(note.date))
                                .font(.caption2)
                                .foregroundColor(.gray)
                            Spacer()
                            Button(role: .destructive) {
                                viewModel.deleteCardNote(note)
                            } label: {
                                Image(systemName: "trash")
                                    .font(.caption)
                            }
                            .buttonStyle(.borderless)
                        }
                        Text(note.content)
                            .font(.caption)
                            .foregroundColor(.white)
                        if !note.tags.isEmpty {
                            Text(note.tags.joined(separator: " · "))
                                .font(.caption2)
                                .foregroundColor(.tarotMystic)
                        }
                    }
                    .padding(12)
                    .tarotLiftedSurface(cornerRadius: 12)
                    .padding(.horizontal)
                }
            }
        }
    }

    private var actions: some View {
        HStack(spacing: 12) {
            Button("Edit") {
                showEditSheet = true
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [Color.tarotMystic, Color.tarotMystic.opacity(0.75)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(color: .tarotMystic.opacity(0.45), radius: 12, y: 6)

            Button("Delete") {
                showDeleteConfirmation = true
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.tarotBackground.opacity(0.4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.tarotMystic.opacity(0.8), Color.tarotPositive.opacity(0.35)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.2
                            )
                    )
            )
            .foregroundColor(.tarotMystic)
            .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}
