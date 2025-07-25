//
//  SubTitleView.swift
//  whispr
//
//  Created by 刘沛强 on 2025/7/25.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct SubTitleView: View {

    @ObservedObject var transcriptionManager: DeepgramTranscriptionManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                if !transcriptionManager.globalText.isEmpty {
                    Text(transcriptionManager.globalText)
                        .font(.system(size: 17))
                        .foregroundColor(.white.opacity(0.4))
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 100)
        .mask(
            // 创建渐变遮罩，中间完全显示，上下边缘淡出
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .black, location: 0.2),
                    .init(color: .black, location: 0.8),
                    .init(color: .clear, location: 1),
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        ).hoverEffect { effect, isActive, _ in
            effect.scaleEffect(isActive ? 1.2 : 1)
        }.hoverEffect { effect, isActive, _ in
            effect.opacity(isActive ? 1 : 0.4)
        }
    }
}
