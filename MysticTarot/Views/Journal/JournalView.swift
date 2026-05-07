//
//  JournalView.swift
//  MysticTarot
//

import SwiftUI

struct JournalView: View {
    @ObservedObject var viewModel: MysticTarotViewModel
    @State private var showNewJournalSheet = false
    @State private var entryToEdit: TarotJournal?
    @State private var searchText = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.tarotMystic)
                TextField("Search journal, card, mood…", text: $searchText)
                    .foregroundColor(.white)
                    .textFieldStyle(.plain)
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(12)
            .tarotPanel(cornerRadius: 14, depth: 0.75)
            .padding(.horizontal)
            .padding(.top, 8)

            List {
                ForEach(viewModel.sortedJournalEntries(search: searchText)) { entry in
                    JournalRowCard(entry: entry)
                        .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            entryToEdit = entry
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                viewModel.deleteJournalEntry(entry)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            Button {
                                viewModel.togglePinJournalEntry(entry)
                            } label: {
                                Label(entry.isPinned ? "Unpin" : "Pin", systemImage: "pin")
                            }
                            .tint(.tarotMystic)

                            Button {
                                viewModel.toggleFavoriteJournalEntry(entry)
                            } label: {
                                Label("Favorite", systemImage: "star.fill")
                            }
                            .tint(.tarotPositive)
                        }
                        .foregroundColor(.white)
                }

                Section {
                    Button {
                        showNewJournalSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "square.and.pencil.circle.fill")
                                .font(.title2)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.tarotPositive, .tarotMystic],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            Text("New entry")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(.tarotPositive)
                            Spacer()
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundColor(.tarotMystic.opacity(0.8))
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16))
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.07),
                                        Color.tarotMystic.opacity(0.38),
                                        Color.tarotBackground.opacity(0.94)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [Color.tarotPositive.opacity(0.45), Color.tarotMystic.opacity(0.4)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.1
                                    )
                            )
                            .shadow(color: .black.opacity(0.35), radius: 12, x: 0, y: 8)
                            .shadow(color: Color.tarotMystic.opacity(0.22), radius: 18, x: 0, y: 4)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 4)
                    )
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .tarotScreenBackground()
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Journal")
                    .font(.largeTitle.bold())
                    .foregroundColor(.tarotPositive)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showNewJournalSheet) {
            JournalEntrySheet(viewModel: viewModel)
        }
        .sheet(item: $entryToEdit) { entry in
            JournalEntrySheet(viewModel: viewModel, existing: entry)
        }
    }
}
