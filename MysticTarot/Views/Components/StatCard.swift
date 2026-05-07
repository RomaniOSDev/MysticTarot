//
//  StatCard.swift
//  MysticTarot
//

import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [color.opacity(0.45), color.opacity(0.1)],
                                center: .topLeading,
                                startRadius: 2,
                                endRadius: 22
                            )
                        )
                        .frame(width: 36, height: 36)
                        .overlay(
                            Circle()
                                .strokeBorder(color.opacity(0.5), lineWidth: 1)
                        )
                    Image(systemName: icon)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [color, .white.opacity(0.9)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .font(.body.weight(.semibold))
                }
                Text(title)
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            Text(value)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Color.white.opacity(0.88)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .font(.title2)
                .bold()
                .shadow(color: .black.opacity(0.35), radius: 2, x: 0, y: 1)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .tarotPanel(cornerRadius: 16, depth: 0.95)
    }
}
