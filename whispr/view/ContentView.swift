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
    @StateObject private var suggestionManager = SuggestionManager()
    @State private var showPermissionModal = false

    var body: some View {
        VStack {
            HStack(spacing: 20) {
                // 左侧面板
                VStack(spacing: 20) {
                    // Listening 状态条
                    ListeningStatusView(
                        status: audioRecorder.isRecording ? .listening : .stop
                    )
                    Spacer()
                }
                .frame(width: 300)

                Spacer()

                // 右侧建议卡片
                VStack {
                    Spacer()

                    ForEach(Array(suggestionManager.getLatestThree().enumerated()), id: \.offset) { index, suggestion in
                        SuggestionCard(suggestion: suggestion)
                    }

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
            } else {
                audioRecorder.startRecording()
            }
            
            // 添加一些示例建议来演示功能
            suggestionManager.pushSuggestion("尝试使用更清晰的语音")
            suggestionManager.pushSuggestion("靠近麦克风说话")
            suggestionManager.pushSuggestion("减少背景噪音")
            suggestionManager.pushSuggestion("说话速度可以稍微慢一些")
        }
        .onChange(of: audioRecorder.hasPermission) { oldValue, newValue in
            if !newValue {
                showPermissionModal = true
            } else {
                showPermissionModal = false
            }
        }
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
