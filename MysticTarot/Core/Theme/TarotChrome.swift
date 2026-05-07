//
//  TarotChrome.swift
//  MysticTarot
//

import SwiftUI

// MARK: - Panel (gradient fill + rim + stacked shadows)

struct TarotPanelStyle: ViewModifier {
    var cornerRadius: CGFloat = 18
    /// 0...1 — overall shadow strength
    var depth: CGFloat = 1

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.09),
                                Color.tarotMystic.opacity(0.32),
                                Color.tarotBackground.opacity(0.96)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.2),
                                Color.tarotPositive.opacity(0.32),
                                Color.tarotMystic.opacity(0.45)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.15
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.white.opacity(0.35), Color.clear],
                            startPoint: .top,
                            endPoint: .center
                        ),
                        lineWidth: 0.8
                    )
                    .padding(1)
                    .opacity(0.55)
            )
            .shadow(color: Color.black.opacity(0.48 * depth), radius: 20 * depth, x: 0, y: 14 * depth)
            .shadow(color: Color.tarotMystic.opacity(0.32 * depth), radius: 28 * depth, x: 0, y: 8 * depth)
            .shadow(color: Color.tarotPositive.opacity(0.14 * depth), radius: 12 * depth, x: 0, y: 0)
    }
}

// MARK: - Compact card face (miniatures, chips)

struct TarotLiftedCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 14

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.tarotMystic.opacity(0.45),
                                Color.tarotBackground.opacity(0.92),
                                Color.tarotMystic.opacity(0.28)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.tarotPositive.opacity(0.45), Color.tarotMystic.opacity(0.35)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
            .shadow(color: Color.black.opacity(0.55), radius: 12, x: 0, y: 8)
            .shadow(color: Color.tarotMystic.opacity(0.35), radius: 18, x: 0, y: 4)
    }
}

extension View {
    /// Primary elevated panel — use after `.padding()` on content.
    func tarotPanel(cornerRadius: CGFloat = 18, depth: CGFloat = 1) -> some View {
        modifier(TarotPanelStyle(cornerRadius: cornerRadius, depth: depth))
    }

    /// Smaller raised surfaces (miniatures, thumbnails).
    func tarotLiftedSurface(cornerRadius: CGFloat = 14) -> some View {
        modifier(TarotLiftedCardModifier(cornerRadius: cornerRadius))
    }

    /// Extra floating shadow stack without changing background (for rows that already have art).
    func tarotFloatingShadow(depth: CGFloat = 1) -> some View {
        self
            .shadow(color: Color.black.opacity(0.42 * depth), radius: 16 * depth, x: 0, y: 11 * depth)
            .shadow(color: Color.tarotMystic.opacity(0.28 * depth), radius: 22 * depth, x: 0, y: 6 * depth)
            .shadow(color: Color.tarotPositive.opacity(0.12 * depth), radius: 10, x: 0, y: 0)
    }

    /// Section titles: gradient text + soft glow.
    func tarotSectionTitleGradient(accent: Color) -> some View {
        self
            .foregroundStyle(
                LinearGradient(
                    colors: [accent, accent.opacity(0.75), Color.white.opacity(0.92)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .shadow(color: accent.opacity(0.45), radius: 8, x: 0, y: 2)
    }
}
