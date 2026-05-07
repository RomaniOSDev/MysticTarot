//
//  SpreadPositionPresets.swift
//  MysticTarot
//

import Foundation

enum SpreadPositionPresets {
    static func labels(for type: SpreadType) -> [String] {
        switch type {
        case .oneCard:
            return ["Focus"]
        case .threeCard:
            return ["Past", "Present", "Future"]
        case .celticCross:
            return [
                "Present situation",
                "Challenge",
                "Distant past",
                "Recent past",
                "Possible outcome",
                "Near future",
                "Your approach",
                "External influences",
                "Hopes & fears",
                "Final outcome"
            ]
        case .relationship:
            return ["You", "Partner", "Connection", "Challenge", "Outlook"]
        case .career:
            return ["Current role", "Obstacle", "Strength", "Opportunity", "Outcome"]
        case .custom:
            return ["Position 1", "Position 2", "Position 3"]
        }
    }
}
