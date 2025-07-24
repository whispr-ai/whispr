//
//  ContentView.swift
//  whispr
//
//  Created by 刘沛强 on 2025/7/22.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct ContentView: View {
    @StateObject private var audioRecorder = AudioRecorderManager()
    @State private var showPermissionModal = false
    @State private var isListening = true
    @State private var pulseAnimation = false

    var body: some View {
        VStack {
            HStack(spacing: 20) {
                // 左侧面板
                VStack(spacing: 20) {
                    // Listening 状态条
                    ListeningStatusView(
                        isListening: $isListening,
                        pulseAnimation: $pulseAnimation
                    )
                    Spacer()
                }
                .frame(width: 300)

                Spacer()

                // 右侧建议卡片
                VStack {
                    Spacer()

                    SuggestionCard()

                    Spacer()
                }
            }
            .padding(30)
            // 底部控制按钮
            BottomControlButtons()
                .padding(.bottom, 40)
        }
        .onAppear {
            audioRecorder.checkPermissionStatus()
            if !audioRecorder.hasPermission {
                showPermissionModal = true
            }

            // 启动脉冲动画
            withAnimation(
                Animation.easeInOut(duration: 2.0).repeatForever(
                    autoreverses: true
                )
            ) {
                pulseAnimation = true
            }
        }
        .onChange(of: audioRecorder.hasPermission) { hasPermission in
            if !hasPermission {
                showPermissionModal = true
            } else {
                showPermissionModal = false
            }
        }
    }
}

// Listening 状态视图
struct ListeningStatusView: View {
    @Binding var isListening: Bool
    @Binding var pulseAnimation: Bool

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Color.primary)
                .frame(width: 12, height: 12)
                .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                .opacity(pulseAnimation ? 0.7 : 1.0)

            Text("Listening...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.regularMaterial)
                .background(Color.black.opacity(0.3))
        )
        .clipShape(RoundedRectangle(cornerRadius: 25))
        // 边框渐变并且圆角
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 2
                )
        )

        Spacer()

    }
}

// 建议卡片
struct SuggestionCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Suggestion")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))

            Text("Senior software engineer at Bananazon for 8 years")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
        }
        .padding(25)
        .frame(maxWidth: 350)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.regularMaterial)
                .background(Color.black.opacity(0.3))
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// 底部控制按钮
struct BottomControlButtons: View {
    var body: some View {
        HStack(spacing: 18) {
            // 麦克风按钮
            Button(action: {}) {
                Image(systemName: "mic.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Circle().fill(.regularMaterial))
                    .background(Color.black.opacity(0.8))
                    .clipShape(Circle())
            }.buttonStyle(.plain)

            // 中心按钮 (类似开关)
            Button(action: {}) {
                Image(systemName: "power")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Circle().fill(.regularMaterial))
                    .background(Color.black.opacity(0.8))
                    .clipShape(Circle())
            }.buttonStyle(.plain)

            // 摄像头按钮
            Button(action: {}) {
                Image(systemName: "video.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Circle().fill(.regularMaterial))
                    .background(Color.black.opacity(0.8))
                    .clipShape(Circle())
            }.buttonStyle(.plain)
        }
    }
}

#Preview(windowStyle: .plain) {
    ContentView()
}
