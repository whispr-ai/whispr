//
//  SearchManager.swift
//  whispr
//
//  Created by 刘沛强 on 2025/7/27.
//

import Foundation
import SwiftUI

struct Search {
    var link: String
    var snippet: String
    var title: String
}

@Observable
class SearchManager {
    var searchs: [Search] = []
    // 添加新的关键词
    func setSearchs(_ searchs: [Search]) {
        DispatchQueue.main.async {
            self.searchs = searchs
        }
    }

    func pushSearchs(_ search: [Search]) {
        DispatchQueue.main.async {
            self.searchs.append(contentsOf: search)
        }
    }

    // 获取最新的五个关键词
    func getLatestThree() -> [Search] {
        let count = searchs.count
        if count <= 3 {
            return searchs
        } else {
            return Array(searchs.suffix(3))
        }
    }

    // 清空所有建议
    func clear() {
        DispatchQueue.main.async {
            self.searchs.removeAll()
        }
    }
}
