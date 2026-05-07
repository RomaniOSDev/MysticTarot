//
//  JournalRowCard.swift
//  MysticTarot
//

import SwiftUI

struct JournalRowCard: View {
    let entry: TarotJournal

    private var dateLabel: String {
        formattedShortDate(entry.date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.tarotMystic.opacity(0.65),
                                    Color.tarotPositive.opacity(0.18),
                                    Color.tarotBackground.opacity(0.95)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 72)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [.tarotPositive.opacity(0.65), .tarotMystic.opacity(0.45)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )

                    Image(systemName: "moon.stars.fill")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.tarotPositive, .white.opacity(0.92)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .tarotPositive.opacity(0.45), radius: 6)
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(entry.cardName)
                            .font(.headline.weight(.bold))
                            .foregroundColor(.white)
                            .lineLimit(2)

                        if entry.isFavorite {
                            Image(systemName: "star.fill")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.yellow.opacity(0.95), .tarotPositive],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: .tarotPositive.opacity(0.4), radius: 4)
                        }

                        if entry.isPinned {
                            Image(systemName: "pin.fill")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.tarotPositive)
                        }
                    }

                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .font(.caption2.weight(.semibold))
                            .foregroundColor(.tarotMystic)

                        Text(dateLabel)
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.white.opacity(0.55))

                        Spacer(minLength: 0)

                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                            .foregroundColor(.white.opacity(0.35))
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(.bottom, 14)

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [.tarotPositive.opacity(0.85), .tarotMystic.opacity(0.5), Color.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)
                .padding(.bottom, 14)

            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "quote.opening")
                    .font(.title3)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.tarotPositive.opacity(0.9), .tarotMystic],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 28, alignment: .top)

                Text(entry.reflection)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.82))
                    .lineSpacing(4)
                    .lineLimit(5)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.tarotBackground.opacity(0.55))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [.tarotPositive.opacity(0.25), .tarotMystic.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )

            if let mood = entry.mood, !mood.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: "heart.circle.fill")
                        .font(.title3)
                        .foregroundStyle(
                            LinearGradient(colors: [.tarotPositive, .tarotMystic], startPoint: .top, endPoint: .bottom)
                        )

                    Text(mood)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.tarotPositive)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.tarotPositive.opacity(0.12))
                                .overlay(
                                    Capsule()
                                        .strokeBorder(Color.tarotPositive.opacity(0.45), lineWidth: 1)
                                )
                        )
                }
                .padding(.top, 14)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.06),
                            Color.tarotMystic.opacity(0.38),
                            Color.tarotBackground.opacity(0.92)
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
                            Color.white.opacity(0.14),
                            Color.tarotPositive.opacity(0.35),
                            Color.tarotMystic.opacity(0.42)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.1
                )
        )
        .shadow(color: .black.opacity(0.38), radius: 16, y: 10)
        .shadow(color: .tarotPositive.opacity(0.12), radius: 24, y: 2)
    }
}
