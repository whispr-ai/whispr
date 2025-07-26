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
    var searchs: [Search] = [
        Search(
            link:
                "https://zh.wikipedia.org/wiki/%E7%89%B9%E6%96%AF%E6%8B%89%E5%85%AC%E5%8F%B8",
            snippet:
                "特斯拉公司（英語：Tesla, Inc.），舊稱特斯拉汽車（英語：Tesla Motors），是美國最大的電動汽車及太陽能板公司，總部設於德克薩斯州奧斯汀，與Panasonic合作電池業務，產銷電動 ...",
            title: "特斯拉公司- 維基百科，自由的百科全書"
        ),
        Search(
            link:
                "https://baike.baidu.com/item/%E7%89%B9%E6%96%AF%E6%8B%89/2984315",
            snippet:
                "特斯拉（Tesla）是一家电动汽车及清洁能源行业跨国公司，总部位于美国得克萨斯州，产销电动汽车、太阳能板、及储能设备与系统解决方案。现任CEO为埃隆·马斯克。",
            title: "特斯拉_百度百科"
        ),
    ]
    // 添加新的关键词
    func setSearchs(_ searchs: [Search]) {
        DispatchQueue.main.async {
            self.searchs = searchs
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
