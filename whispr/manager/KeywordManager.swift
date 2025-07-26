//
//  KeywordManager.swift
//  whispr
//
//  Created by 刘沛强 on 2025/7/26.
//

import Foundation
import SwiftUI

@Observable
class KeywordManager {
    var keywords: [String] = ["企业家", "创业", "创新", "领导力", "市场营销"]

    // 添加新的关键词
    func setKeywords(_ keywords: [String]) {
        DispatchQueue.main.async {
            self.keywords = keywords
        }
    }

    // 获取最新的五个关键词
    func getLatestFive() -> [String] {
        let count = keywords.count
        if count <= 5 {
            return keywords
        } else {
            return Array(keywords.suffix(5))
        }
    }

    // 清空所有建议
    func clear() {
        DispatchQueue.main.async {
            self.keywords.removeAll()
        }
    }
}
