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

                    ForEach(
                        Array(suggestionManager.getLatestThree().enumerated()),
                        id: \.offset
                    ) { index, suggestion in
                        SuggestionCard(suggestion: suggestion)
                    }

                    Spacer()
                }
            }
            .padding(30)
            // 底部控制按钮
            BottomControlButtonsView(audioRecorder: audioRecorder)
                .padding(.bottom, 40)
        }
        .onAppear {
            audioRecorder.checkPermissionStatus()
            if !audioRecorder.hasPermission {
                showPermissionModal = true
            } else {
                audioRecorder.startRecording()
            }

            suggestionManager.pushSuggestion(
                "Welcome to whispr! Tap the button below to start listening."
            )
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

#Preview(windowStyle: .plain) {
    ContentView()
}
