//
//  TarotScreenBackground.swift
//  MysticTarot
//

import SwiftUI

/// Layered mystical backdrop: deep base, violet / mint glows, subtle stars, soft vignette.
struct TarotScreenBackground: View {
    private static let starSpecs: [(x: CGFloat, y: CGFloat, size: CGFloat, opacity: CGFloat)] = [
        (0.06, 0.11, 2.2, 0.42), (0.14, 0.22, 1.6, 0.28), (0.22, 0.08, 1.4, 0.35),
        (0.31, 0.16, 2.0, 0.31), (0.42, 0.06, 1.3, 0.38), (0.55, 0.12, 1.8, 0.26),
        (0.68, 0.09, 1.5, 0.33), (0.78, 0.18, 2.4, 0.29), (0.91, 0.14, 1.6, 0.36),
        (0.88, 0.28, 1.2, 0.24), (0.72, 0.31, 1.7, 0.30), (0.58, 0.26, 1.4, 0.27),
        (0.44, 0.34, 2.1, 0.22), (0.28, 0.38, 1.5, 0.34), (0.12, 0.42, 1.8, 0.25),
        (0.09, 0.58, 1.3, 0.40), (0.21, 0.52, 2.0, 0.28), (0.37, 0.62, 1.6, 0.32),
        (0.52, 0.48, 1.4, 0.35), (0.66, 0.55, 2.2, 0.26), (0.81, 0.48, 1.5, 0.31),
        (0.93, 0.62, 1.9, 0.33), (0.76, 0.72, 1.3, 0.38), (0.48, 0.78, 2.1, 0.24),
        (0.24, 0.85, 1.6, 0.30), (0.08, 0.76, 1.4, 0.36), (0.15, 0.92, 1.8, 0.28),
        (0.42, 0.91, 1.5, 0.34), (0.62, 0.88, 2.0, 0.27), (0.85, 0.90, 1.7, 0.32),
        (0.95, 0.38, 1.2, 0.29), (0.50, 0.20, 1.1, 0.33), (0.33, 0.72, 1.9, 0.25)
    ]

    var body: some View {
        ZStack {
            Color.tarotBackground

            RadialGradient(
                colors: [
                    Color.tarotMystic.opacity(0.48),
                    Color.tarotMystic.opacity(0.12),
                    Color.clear
                ],
                center: UnitPoint(x: 0.88, y: 0.08),
                startRadius: 20,
                endRadius: 340
            )

            RadialGradient(
                colors: [
                    Color.tarotPositive.opacity(0.26),
                    Color.tarotPositive.opacity(0.06),
                    Color.clear
                ],
                center: UnitPoint(x: 0.12, y: 0.88),
                startRadius: 15,
                endRadius: 320
            )

            RadialGradient(
                colors: [
                    Color(red: 0.35, green: 0.15, blue: 0.45).opacity(0.35),
                    Color.clear
                ],
                center: .center,
                startRadius: 60,
                endRadius: 420
            )

            LinearGradient(
                colors: [
                    Color.white.opacity(0.045),
                    Color.clear,
                    Color.tarotMystic.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Canvas { context, size in
                for spec in Self.starSpecs {
                    let rect = CGRect(
                        x: spec.x * size.width - spec.size * 0.5,
                        y: spec.y * size.height - spec.size * 0.5,
                        width: spec.size,
                        height: spec.size
                    )
                    context.fill(
                        Path(ellipseIn: rect),
                        with: .color(Color.white.opacity(spec.opacity))
                    )
                }
            }
            .allowsHitTesting(false)

            LinearGradient(
                colors: [
                    Color.black.opacity(0.05),
                    Color.clear,
                    Color.black.opacity(0.42)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}
