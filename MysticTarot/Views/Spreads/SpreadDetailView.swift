//
//  SpreadDetailView.swift
//  MysticTarot
//

import SwiftUI
import UIKit

struct SpreadDetailView: View {
    @ObservedObject var viewModel: MysticTarotViewModel
    let spreadId: UUID
    @Binding var navigationPath: NavigationPath

    @State private var showEditor = false
    @State private var confirmDelete = false
    @State private var copiedToast = false

    private var spread: SpreadModel? {
        viewModel.spreads.first(where: { $0.id == spreadId })
    }

    var body: some View {
        Group {
            if let spread {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        header(spread)

                        Text("Interpretation")
                            .font(.headline.weight(.bold))
                            .tarotSectionTitleGradient(accent: .tarotPositive)
                        Text(spread.interpretation)
                            .foregroundColor(.white)
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .tarotLiftedSurface(cornerRadius: 14)

                        Text("Recorded cards")
                            .font(.headline.weight(.bold))
                            .tarotSectionTitleGradient(accent: .tarotPositive)

                        if spread.cards.isEmpty {
                            Text("No picks recorded yet.")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(spread.cards.sorted(by: { $0.position < $1.position })) { card in
                                spreadCardRow(card)
                            }
                        }
                    }
                    .padding()
                }
                .tarotScreenBackground()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button {
                                viewModel.duplicateSpread(spread)
                            } label: {
                                Label("Duplicate spread", systemImage: "doc.on.doc")
                            }
                            Button {
                                UIPasteboard.general.string = viewModel.exportSpreadPlainText(spread)
                                copiedToast = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                                    copiedToast = false
                                }
                            } label: {
                                Label("Copy text summary", systemImage: "doc.on.clipboard")
                            }
                            Button {
                                showEditor = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                confirmDelete = true
                            } label: {
                                Label("Delete spread", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundColor(.tarotPositive)
                        }
                    }
                }
                .overlay(alignment: .top) {
                    if copiedToast {
                        Text("Copied to clipboard")
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.tarotMystic.opacity(0.95))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.top, 8)
                            .transition(.opacity)
                    }
                }
                .sheet(isPresented: $showEditor) {
                    SpreadEditorSheet(viewModel: viewModel, spread: spread)
                }
                .alert("Delete this spread?", isPresented: $confirmDelete) {
                    Button("Cancel", role: .cancel) {}
                    Button("Delete", role: .destructive) {
                        viewModel.deleteSpread(spread)
                        navigationPath.removeLast()
                    }
                } message: {
                    Text("This cannot be undone.")
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "rectangle.stack.fill.badge.minus")
                        .font(.system(size: 48))
                        .foregroundColor(.tarotMystic)
                    Text("Spread missing")
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
    }

    private func header(_ spread: SpreadModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: spread.type.icon)
                    .foregroundStyle(
                        LinearGradient(colors: [.tarotPositive, .white.opacity(0.9)], startPoint: .top, endPoint: .bottom)
                    )
                    .font(.title2)
                    .shadow(color: .tarotPositive.opacity(0.4), radius: 6, y: 2)
                VStack(alignment: .leading, spacing: 4) {
                    Text(spread.name)
                        .font(.title2)
                        .bold()
                        .foregroundStyle(
                            LinearGradient(colors: [.white, Color.white.opacity(0.88)], startPoint: .leading, endPoint: .trailing)
                        )
                    Text(spread.type.rawValue)
                        .font(.caption)
                        .foregroundColor(.tarotMystic)
                }
                Spacer()
                if spread.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundStyle(
                            LinearGradient(colors: [.tarotPositive, .yellow.opacity(0.85)], startPoint: .top, endPoint: .bottom)
                        )
                        .shadow(color: .tarotPositive.opacity(0.45), radius: 5)
                }
            }

            Text("Logged \(formattedShortDate(spread.date))")
                .font(.caption)
                .foregroundColor(.gray)

            Text("Question")
                .font(.caption.weight(.semibold))
                .tarotSectionTitleGradient(accent: .tarotPositive)
            Text(spread.question)
                .foregroundColor(.white)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .tarotPanel(cornerRadius: 18, depth: 0.9)
    }

    private func spreadCardRow(_ card: SpreadCardModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(card.cardName)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Label(card.orientation.rawValue, systemImage: card.orientation.icon)
                    .font(.caption)
                    .foregroundColor(.tarotPositive)
            }
            Text("#\(card.position) · \(card.positionName)")
                .font(.caption)
                .foregroundColor(.tarotMystic)

            if let notes = card.notes, !notes.isEmpty {
                Text(notes)
                    .foregroundColor(.gray)
                    .font(.caption)
            }
        }
        .padding(14)
        .tarotLiftedSurface(cornerRadius: 14)
    }
}
