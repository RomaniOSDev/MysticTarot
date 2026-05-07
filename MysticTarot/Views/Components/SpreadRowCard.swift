//
//  SpreadRowCard.swift
//  MysticTarot
//

import SwiftUI

struct SpreadRowCard: View {
    let spread: SpreadModel

    private var dateLabel: String {
        formattedShortDate(spread.date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.tarotPositive.opacity(0.45),
                                    Color.tarotMystic.opacity(0.35),
                                    Color.tarotMystic.opacity(0.12)
                                ],
                                center: .topLeading,
                                startRadius: 4,
                                endRadius: 36
                            )
                        )
                        .frame(width: 52, height: 52)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color.tarotPositive.opacity(0.7),
                                            Color.tarotMystic.opacity(0.5)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )

                    Image(systemName: spread.type.icon)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.tarotPositive, .white.opacity(0.95)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .tarotPositive.opacity(0.45), radius: 6)
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(spread.name)
                            .font(.headline.weight(.bold))
                            .foregroundColor(.white)
                            .lineLimit(2)

                        if spread.isFavorite {
                            Image(systemName: "sparkles")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.tarotPositive)
                        }
                    }

                    Text(spread.type.rawValue.uppercased())
                        .font(.caption2.weight(.heavy))
                        .tracking(1.1)
                        .foregroundColor(.tarotPositive.opacity(0.92))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.tarotMystic.opacity(0.45)))
                        .overlay(
                            Capsule()
                                .strokeBorder(Color.tarotPositive.opacity(0.35), lineWidth: 1)
                        )
                }

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: 10) {
                    if spread.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(
                                LinearGradient(colors: [.tarotPositive, .yellow.opacity(0.85)], startPoint: .top, endPoint: .bottom)
                            )
                            .shadow(color: .tarotPositive.opacity(0.5), radius: 4)
                    }

                    Text(dateLabel)
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(.white.opacity(0.55))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Color.black.opacity(0.28)))
                }
            }

            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.caption)
                    .foregroundColor(.tarotMystic)
                    .padding(.top, 2)

                Text(spread.question)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.78))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.tarotBackground.opacity(0.55))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.tarotMystic.opacity(0.35), lineWidth: 1)
            )

            HStack(spacing: 12) {
                Label("\(spread.cards.count) cards drawn", systemImage: "square.stack.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.tarotPositive)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.white.opacity(0.35))

                Spacer()

                Image(systemName: "sparkle")
                    .font(.caption2)
                    .foregroundColor(.tarotMystic.opacity(0.8))
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 2)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.tarotMystic.opacity(0.52),
                            Color.tarotBackground.opacity(0.92),
                            Color.tarotMystic.opacity(0.38)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.tarotPositive.opacity(0.55),
                            Color.tarotMystic.opacity(0.45),
                            Color.tarotPositive.opacity(0.25)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        )
        .shadow(color: .black.opacity(0.42), radius: 14, y: 10)
        .shadow(color: .tarotMystic.opacity(0.35), radius: 20, y: 4)
    }
}
