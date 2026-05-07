//
//  OnboardingView.swift
//  MysticTarot
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var page = 0

    private let pages: [(icon: String, title: String, detail: String)] = [
        (
            "moon.stars.fill",
            "Your deck, one tap away",
            "Browse the full tarot, star favorites, filter by study progress, and open a daily card when you need a focal point."
        ),
        (
            "rectangle.stack.fill",
            "Spreads that stay with you",
            "Log layouts with positions and notes. Duplicate or export spreads when you want to revisit a reading."
        ),
        (
            "chart.bar.fill",
            "Journal, study, and see patterns",
            "Write reflections tied to draws, practice with flash cards and quizzes, then watch streaks and suit charts grow."
        )
    ]

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                TabView(selection: $page) {
                    ForEach(0 ..< pages.count, id: \.self) { index in
                        onboardingPage(index: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                bottomBar
            }

            Button("Skip") {
                completeOnboarding()
            }
            .font(.subheadline.weight(.semibold))
            .foregroundColor(.tarotMystic)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .tarotScreenBackground()
    }

    private func onboardingPage(index: Int) -> some View {
        let item = pages[index]
        return VStack(spacing: 22) {
            Spacer(minLength: 48)

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.tarotPositive.opacity(0.45),
                                Color.tarotMystic.opacity(0.35),
                                Color.tarotBackground.opacity(0.6)
                            ],
                            center: .center,
                            startRadius: 12,
                            endRadius: 72
                        )
                    )
                    .frame(width: 144, height: 144)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [.tarotPositive.opacity(0.65), .tarotMystic.opacity(0.45)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )

                Image(systemName: item.icon)
                    .font(.system(size: 56, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .tarotPositive.opacity(0.95)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .tarotPositive.opacity(0.45), radius: 16, y: 6)
            }

            Text(item.title)
                .font(.title.weight(.bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Color.white.opacity(0.88)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
                .shadow(color: .black.opacity(0.35), radius: 4, y: 2)

            Text(item.detail)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 32)

            Spacer(minLength: 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var bottomBar: some View {
        VStack(spacing: 20) {
            HStack(spacing: 8) {
                ForEach(0 ..< pages.count, id: \.self) { index in
                    Capsule()
                        .fill(index == page ? Color.tarotPositive : Color.white.opacity(0.22))
                        .frame(width: index == page ? 26 : 8, height: 8)
                        .animation(.easeInOut(duration: 0.22), value: page)
                }
            }

            HStack(spacing: 16) {
                if page > 0 {
                    Button("Back") {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            page -= 1
                        }
                    }
                    .foregroundColor(.tarotMystic)
                    .padding(.horizontal, 8)
                }

                Spacer(minLength: 0)

                Button(page == pages.count - 1 ? "Get started" : "Next") {
                    if page == pages.count - 1 {
                        completeOnboarding()
                    } else {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            page += 1
                        }
                    }
                }
                .font(.headline.weight(.semibold))
                .foregroundColor(.tarotBackground)
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.tarotPositive, .tarotPositive.opacity(0.82)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: .tarotPositive.opacity(0.35), radius: 14, y: 6)
            }
            .padding(.horizontal, 24)
        }
        .padding(.bottom, 36)
        .padding(.top, 8)
    }

    private func completeOnboarding() {
        hasCompletedOnboarding = true
    }
}

#Preview {
    OnboardingView()
        .preferredColorScheme(.dark)
}
