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
            return URL(string: "https://example.com/privacy-policy")
        case .termsOfUse:
            return URL(string: "https://example.com/terms")
        }
    }
}
