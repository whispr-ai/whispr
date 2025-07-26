//
//  SuggestionManager.swift
//  whispr
//
//  Created by 刘沛强 on 2025/7/25.
//

import Foundation
import SwiftUI

@Observable
class SuggestionManager {
    var suggestions: [String] = []

    // 添加新的建议
    func pushSuggestion(_ suggestion: String) {
        DispatchQueue.main.async {
            self.suggestions.append(suggestion)
        }
    }

    // 获取最新的三个建议
    func getLatestThree() -> [String] {
        let count = suggestions.count
        if count <= 3 {
            return suggestions
        } else {
            return Array(suggestions.suffix(3))
        }
    }

    // 清空所有建议
    func clear() {
        DispatchQueue.main.async {
            self.suggestions.removeAll()
        }
    }

    // 删除特定建议
    func removeSuggestion(at index: Int) {
        DispatchQueue.main.async {
            if index < self.suggestions.count {
                self.suggestions.remove(at: index)
            }
        }
    }
}
