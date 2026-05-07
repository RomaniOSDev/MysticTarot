//
//  SettingsView.swift
//  MysticTarot
//

import StoreKit
import SwiftUI
import UIKit

struct SettingsView: View {
    var body: some View {
        List {
            Section {
                Button {
                    rateApp()
                } label: {
                    Label("Rate us", systemImage: "star.fill")
                        .foregroundColor(.white)
                }

                Button {
                    openLink(.privacyPolicy)
                } label: {
                    Label("Privacy Policy", systemImage: "hand.raised.fill")
                        .foregroundColor(.white)
                }

                Button {
                    openLink(.termsOfUse)
                } label: {
                    Label("Terms of Use", systemImage: "doc.text.fill")
                        .foregroundColor(.white)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .listStyle(.insetGrouped)
        .tarotScreenBackground()
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.tarotPositive)
    }

    private func openLink(_ link: AppExternalLink) {
        if let url = link.url {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .preferredColorScheme(.dark)
}
