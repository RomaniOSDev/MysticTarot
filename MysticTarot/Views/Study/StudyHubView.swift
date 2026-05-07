//
//  StudyHubView.swift
//  MysticTarot
//

import SwiftUI

struct StudyHubView: View {
    @ObservedObject var viewModel: MysticTarotViewModel

    var body: some View {
        List {
            Section {
                NavigationLink {
                    FlashStudyView(viewModel: viewModel)
                } label: {
                    Label("Flash cards", systemImage: "rectangle.portrait.on.rectangle.portrait.fill")
                }
                .disabled(viewModel.cards.isEmpty)
                .listRowBackground(studyHubRowBackground)

                NavigationLink {
                    QuizStudyView(viewModel: viewModel)
                } label: {
                    Label("Meaning quiz", systemImage: "checkmark.circle.fill")
                }
                .disabled(viewModel.cards.count < 4)
                .listRowBackground(studyHubRowBackground)
            } footer: {
                Text("Practice with cards from your deck. Quiz needs four cards to build answer choices.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .tarotScreenBackground()
        .navigationTitle("Study")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var studyHubRowBackground: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.08),
                        Color.tarotMystic.opacity(0.34),
                        Color.tarotBackground.opacity(0.96)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.tarotPositive.opacity(0.38), Color.tarotMystic.opacity(0.42)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.32), radius: 10, x: 0, y: 7)
            .padding(.vertical, 4)
            .padding(.horizontal, 4)
    }
}

struct FlashStudyView: View {
    @ObservedObject var viewModel: MysticTarotViewModel
    @State private var current: TarotCard?
    @State private var showAnswer = false

    var body: some View {
        VStack(spacing: 24) {
            if let card = current {
                VStack(spacing: 16) {
                    Text(card.name)
                        .font(.title.bold())
                        .foregroundStyle(
                            LinearGradient(colors: [.white, Color.white.opacity(0.88)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .shadow(color: .black.opacity(0.35), radius: 3, y: 2)
                        .multilineTextAlignment(.center)

                    Text(card.arcana.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.tarotMystic)

                    if showAnswer {
                        Text(card.uprightMeaning)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.leading)
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .tarotLiftedSurface(cornerRadius: 14)

                        Text("Reversed")
                            .font(.caption.weight(.bold))
                            .foregroundColor(.tarotPositive)
                        Text(card.reversedMeaning)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .tarotLiftedSurface(cornerRadius: 12)
                    } else {
                        Text("Recall the upright meaning, then reveal.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(14)
                            .frame(maxWidth: .infinity)
                            .tarotLiftedSurface(cornerRadius: 12)
                    }
                }
                .padding(18)
                .tarotPanel(cornerRadius: 22, depth: 0.92)

                HStack(spacing: 16) {
                    Button(showAnswer ? "Hide" : "Reveal") {
                        showAnswer.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.tarotMystic)
                    .shadow(color: .tarotMystic.opacity(0.35), radius: 10, y: 4)

                    Button("Next card") {
                        pickCard()
                    }
                    .buttonStyle(.bordered)
                    .tint(.tarotPositive)
                    .shadow(color: .black.opacity(0.25), radius: 8, y: 3)
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "square.stack.3d.up.slash")
                        .font(.system(size: 44))
                        .foregroundColor(.tarotMystic)
                    Text("No cards")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Add cards in your deck first.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Spacer()
        }
        .padding()
        .tarotScreenBackground()
        .onAppear {
            if current == nil { pickCard() }
        }
        .navigationTitle("Flash cards")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func pickCard() {
        showAnswer = false
        current = viewModel.cards.randomElement()
    }
}

struct QuizStudyView: View {
    @ObservedObject var viewModel: MysticTarotViewModel
    @State private var questionCard: TarotCard?
    @State private var choices: [String] = []
    @State private var correctIndex = 0
    @State private var picked: Int?
    @State private var score = 0
    @State private var rounds = 0

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Score \(score) / \(max(rounds, 1))")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(
                        LinearGradient(colors: [.tarotPositive, .tarotMystic.opacity(0.9)], startPoint: .leading, endPoint: .trailing)
                    )
                    .shadow(color: .tarotPositive.opacity(0.35), radius: 4, y: 1)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .tarotPanel(cornerRadius: 14, depth: 0.75)

            if let card = questionCard {
                Text("Which meaning fits this card?")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text(card.name)
                    .font(.title2.bold())
                    .foregroundStyle(
                        LinearGradient(colors: [.white, Color.white.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 3, y: 2)
                    .multilineTextAlignment(.center)

                Text(card.arcana.rawValue)
                    .font(.caption)
                    .foregroundColor(.tarotMystic)

                VStack(spacing: 10) {
                    ForEach(Array(choices.enumerated()), id: \.offset) { idx, text in
                        Button {
                            guard picked == nil else { return }
                            picked = idx
                            rounds += 1
                            if idx == correctIndex { score += 1 }
                        } label: {
                            HStack {
                                Text(text)
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                                if let picked {
                                    Image(systemName: idx == correctIndex ? "checkmark.circle.fill" : (picked == idx ? "xmark.circle.fill" : "circle"))
                                        .foregroundColor(idx == correctIndex ? .tarotPositive : (picked == idx ? .red.opacity(0.8) : .gray))
                                }
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.tarotMystic.opacity(picked == nil ? 0.42 : (idx == correctIndex ? 0.48 : 0.22)),
                                                Color.tarotBackground.opacity(0.92)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(Color.tarotMystic.opacity(0.45), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.28), radius: 10, x: 0, y: 6)
                        }
                        .disabled(picked != nil && picked != idx && idx != correctIndex)
                    }
                }

                if picked != nil {
                    Button("Next question") {
                        nextRound()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.tarotPositive)
                    .shadow(color: .tarotPositive.opacity(0.35), radius: 12, y: 5)
                }
            } else if viewModel.cards.count < 4 {
                VStack(spacing: 12) {
                    Image(systemName: "square.stack.3d.up.slash")
                        .font(.largeTitle)
                        .foregroundColor(.tarotMystic)
                    Text("Add at least four cards to play the quiz.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                }
                .padding()
            } else {
                ProgressView()
                    .tint(.tarotPositive)
            }

            Spacer()
        }
        .padding()
        .tarotScreenBackground()
        .onAppear {
            nextRound()
        }
        .navigationTitle("Quiz")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func nextRound() {
        picked = nil
        let deck = viewModel.cards
        guard deck.count >= 4,
              let correct = deck.randomElement()
        else {
            questionCard = nil
            choices = []
            return
        }
        let others = deck.filter { $0.id != correct.id }
        let wrongThree = Array(others.shuffled().prefix(3)).map(\.uprightMeaning)
        guard wrongThree.count == 3 else {
            questionCard = nil
            choices = []
            return
        }
        var opts = wrongThree + [correct.uprightMeaning]
        opts.shuffle()
        guard let ci = opts.firstIndex(of: correct.uprightMeaning) else {
            questionCard = nil
            choices = []
            return
        }
        questionCard = correct
        choices = opts
        correctIndex = ci
    }
}
