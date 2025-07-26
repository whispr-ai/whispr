//
//  KeywordCardView.swift
//  whispr
//
//  Created by 刘沛强 on 2025/7/26.
//

import Foundation
import SwiftUI
import SwiftyJSON

struct KeywordCardView: View {

    @Environment(KeywordManager.self) var keywordManager

    var body: some View {

        HStack(spacing: 8) {

            Text("💡")
                .font(.title2)

            Text("Tips：" + keywordManager.keywords.joined(separator: "，"))
                .font(.title3)
                .foregroundColor(.white)
                .bold()

        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: .infinity)
                .fill(.regularMaterial)
                .background(.yellow)
                .opacity(0.8)
        )
        .clipShape(RoundedRectangle(cornerRadius: .infinity))
        .glassBackgroundEffect()
    }
}

#Preview {
    KeywordCardView()
}
