//
//  EmotionCardView.swift
//  whispr
//
//  Created by 刘沛强 on 2025/7/26.
//
import Foundation
import SwiftUI
import SwiftyJSON

struct EmotionCardView: View {

    @Environment(EmotionManager.self) var emotionManager

    var body: some View {

        if emotionManager.emotion != .neutral {
            HStack(spacing: 8) {
                Text(emotionManager.emotion.icon)
                    .font(.largeTitle)

                Text(emotionManager.emotion.rawValue)
                    .font(.title2)
                    .foregroundColor(.white)
                    .bold()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: .infinity)
                    .fill(.regularMaterial)
                    .background(emotionManager.emotion.color)
                    .opacity(0.8)
            )
            .clipShape(RoundedRectangle(cornerRadius: .infinity))
            .glassBackgroundEffect()
        }
    }
}

#Preview {
    EmotionCardView()
}
