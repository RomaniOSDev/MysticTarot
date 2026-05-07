//
//  AppExternalLink.swift
//  MysticTarot
//

import Foundation

/// Central place for outbound URLs (privacy, terms, etc.).
enum AppExternalLink {
    case privacyPolicy
    case termsOfUse

    var url: URL? {
        switch self {
        case .privacyPolicy:
            return URL(string: "https://www.termsfeed.com/live/fe71956d-b84b-445d-8671-64b8a6553c37")
        case .termsOfUse:
            return URL(string: "https://www.termsfeed.com/live/3958434e-792a-4872-b075-f3d813ef8a6f")
        }
    }
}
