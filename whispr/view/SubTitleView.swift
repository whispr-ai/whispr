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

    @Environment(DashScopeTranscriptionManager.self) var transcriptionManager

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    Text(
                        transcriptionManager.isSentenceEnd
                            ? transcriptionManager.globalText
                            : transcriptionManager.globalText
                                + transcriptionManager.tempText
                    )
                    .font(.system(size: 17))
                    .kerning(1.5)
                    .lineSpacing(4)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.top, 8)

                    // 添加一个底部spacer，确保文本能真正滚动到最底部
                    Spacer()
                        .frame(height: 1)
                        .id("bottomText")

                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
            }
            .onChange(of: transcriptionManager.globalText) { _, _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo("bottomText", anchor: .top)
                }
            }
            .onChange(of: transcriptionManager.tempText) { _, _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo("bottomText", anchor: .top)
                }
            }
        }
        .frame(height: 260)
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
