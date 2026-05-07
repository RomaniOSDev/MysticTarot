//
//  CardMiniature.swift
//  MysticTarot
//

import SwiftUI

struct CardMiniature: View {
    let card: TarotCard
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                color.opacity(0.5),
                                Color.tarotMystic.opacity(0.35),
                                Color.tarotBackground.opacity(0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 140)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.2), color.opacity(0.55)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.2
                            )
                    )
                    .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 7)
                    .shadow(color: color.opacity(0.35), radius: 16, x: 0, y: 4)

                VStack(spacing: 6) {
                    Image(systemName: "star.circle.fill")
                        .font(.title)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [color, .white.opacity(0.95)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: color.opacity(0.6), radius: 6, y: 2)

                    Text(card.name)
                        .font(.caption)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 4)
                        .shadow(color: .black.opacity(0.4), radius: 1, x: 0, y: 1)
                }
            }

            if card.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundStyle(
                        LinearGradient(colors: [.tarotPositive, .yellow.opacity(0.9)], startPoint: .top, endPoint: .bottom)
                    )
                    .font(.caption)
                    .shadow(color: .tarotPositive.opacity(0.55), radius: 4, y: 1)
            }
        }
        .frame(width: 100)
    }
}
