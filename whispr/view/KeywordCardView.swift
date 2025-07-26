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

        if keywordManager.keywords.count > 0 {

            HStack(spacing: 2) {
                TipsIconView()
                TipsDetailView().hoverEffect {
                    effect,
                    isActive,
                    _ in
                    effect.opacity(isActive ? 1 : 0)
                }
            }

            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: .infinity)
                    .fill(.regularMaterial)
                    .background(.yellow)
                    .opacity(0.8)
            )
            .glassBackgroundEffect()
            .hoverEffect { effect, isActive, proxy in
                effect.clipShape(
                    RoundedRectangle(cornerRadius: .infinity)
                        .size(
                            width: isActive
                                ? proxy.size.width : 150,
                            height: proxy.size.height,
                            anchor: .leading
                        )
                )
                .offset(
                    x: isActive ? 0 : proxy.size.width / 2 - (150 / 2),
                    y: 0

                )
            }.hoverEffectGroup()
        }
    }

    struct TipsIconView: View {
        var body: some View {
            Text("💡 回答建议")
                .font(.title3)
        }
    }

    struct TipsDetailView: View {

        @Environment(KeywordManager.self) var keywordManager
        var body: some View {
            Text("：" + keywordManager.keywords.joined(separator: "，"))
                .font(.title3)
                .foregroundColor(.white)
                .bold()
        }
    }
}

#Preview {
    KeywordCardView()
}
