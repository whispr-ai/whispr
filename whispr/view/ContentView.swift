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

    @Environment(AudioRecorderManager.self) var audioRecorderManager
    @Environment(SuggestionManager.self) var suggestionManager

    @State private var showPermissionModal = false

    var body: some View {
        VStack {
            HStack(spacing: 20) {
                // 左侧面板
                VStack(spacing: 20) {

                    ListeningStatusView(
                        status: audioRecorderManager.isRecording
                            ? .listening : .stop,
                    )

                    Spacer()

                    SubTitleView()

                }
                .frame(width: 300)

                Spacer()

                // 右侧建议卡片
                VStack {
                    Spacer()

                    ForEach(
                        Array(
                            suggestionManager.getLatestThree()
                                .enumerated()
                        ),
                        id: \.offset
                    ) { index, suggestion in
                        SuggestionCard(suggestion: suggestion)
                    }

                    Spacer()
                }
            }
            .padding(30)
            // 底部控制按钮
            BottomControlButtonsView()
                .padding(.bottom, 40)
        }
        .onAppear {
            audioRecorderManager.checkPermissionStatus()
            if !audioRecorderManager.hasPermission {
                showPermissionModal = true
            } else {
                //                appModel.audioRecorderManager.startRecording()
            }

            suggestionManager.pushSuggestion("123123")
        }
        .onChange(of: audioRecorderManager.hasPermission) {
            oldValue,
            newValue in
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
