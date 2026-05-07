//
//  Color+Tarot.swift
//  MysticTarot
//

import SwiftUI

extension Color {
    static let tarotBackground = Color(red: 0.055, green: 0.051, blue: 0.071) // #0E0D12
    static let tarotMystic = Color(red: 0.545, green: 0.188, blue: 0.612) // #8B309C
    static let tarotPositive = Color(red: 0.141, green: 0.812, blue: 0.643) // #24CFA4
}

extension View {
    /// Full-screen mystical layered background (gradients + stars).
    func tarotScreenBackground() -> some View {
        background(
            TarotScreenBackground()
                .ignoresSafeArea()
        )
    }

    func tarotInsetFormStyle() -> some View {
        scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
            .tarotScreenBackground()
            .tint(.tarotPositive)
    }

    func tarotFormRowBackdrop() -> some View {
        listRowBackground(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.tarotMystic.opacity(0.42),
                            Color.tarotBackground.opacity(0.88),
                            Color.tarotMystic.opacity(0.28)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.tarotPositive.opacity(0.35), Color.tarotMystic.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 5)
                .padding(.vertical, 3)
                .padding(.horizontal, 2)
        )
        .listRowSeparatorTint(.tarotMystic.opacity(0.35))
    }
}
