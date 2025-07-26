//
//  EmotionManager.swift
//  whispr
//
//  Created by 刘沛强 on 2025/7/26.
//

import SwiftUI

enum EmotionType: String, CaseIterable {
    case sadness = "悲伤"
    case doubt = "疑问"
    case satisfaction = "满意"
    case anger = "愤怒"
    case disappointment = "失望"
    case neutral = "中性"

    var icon: String {
        switch self {
        case .sadness: return "😢"
        case .doubt: return "🤔"
        case .satisfaction: return "😊"
        case .anger: return "😡"
        case .disappointment: return "😞"
        case .neutral: return "😐"
        }
    }

    var color: Color {
        switch self {
        case .sadness: return .blue
        case .doubt: return .gray
        case .satisfaction: return .green
        case .anger: return .red
        case .disappointment: return .purple
        case .neutral: return .orange
        }
    }
}

@Observable
class EmotionManager {

    var emotion: EmotionType = .neutral

    func setEmotionByText(text: String) {
        switch text {
        case "悲伤":
            self.emotion = .sadness
        case "疑问":
            self.emotion = .doubt
        case "满意":
            self.emotion = .satisfaction
        case "愤怒":
            self.emotion = .anger
        case "失望":
            self.emotion = .disappointment
        default:
            self.emotion = .neutral
        }
    }

}
