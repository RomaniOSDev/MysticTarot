//
//  SpreadsView.swift
//  MysticTarot
//

import SwiftUI

struct SpreadsView: View {
    @ObservedObject var viewModel: MysticTarotViewModel
    @Binding var navigationPath: NavigationPath
    @State private var showNewSpreadSheet = false

    private var sortedSpreads: [SpreadModel] {
        viewModel.spreads.sorted { $0.date > $1.date }
    }

    var body: some View {
        List {
            ForEach(sortedSpreads) { spread in
                SpreadRowCard(spread: spread)
                    .contentShape(Rectangle())
                    .listRowBackground(Color.clear)
                    .onTapGesture {
                        navigationPath.append(spread.id)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            viewModel.deleteSpread(spread)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }

                        Button {
                            viewModel.toggleFavoriteSpread(spread)
                        } label: {
                            Label("Favorite", systemImage: "star")
                        }
                        .tint(.tarotPositive)
                    }
                    .foregroundColor(.white)
            }

            Section {
                Button {
                    showNewSpreadSheet = true
                } label: {
                    Label("New spread", systemImage: "rectangle.badge.plus")
                        .foregroundColor(.tarotPositive)
                }
                .padding(.vertical, 4)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .tarotScreenBackground()
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Spreads")
                    .font(.largeTitle.bold())
                    .foregroundColor(.tarotPositive)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showNewSpreadSheet) {
            SpreadEditorSheet(viewModel: viewModel, spread: nil)
        }
    }
}
