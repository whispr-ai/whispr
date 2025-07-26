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
    @Environment(DashScopeTranscriptionManager.self)
    var dashscopeTranscriptionManager

    @State private var showPermissionModal = false
    @State private var suggestDifyManager = DifyManager(
        appKey: "app-CssxMUhsPHR1BDCClE6VsbYK"
    )

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
        }
        .onChange(of: audioRecorderManager.hasPermission) {
            oldValue,
            newValue in
            if !newValue {
                showPermissionModal = true
            } else {
                showPermissionModal = false
            }
        }.onChange(of: dashscopeTranscriptionManager.latestSentence) {
            oldValue,
            newValue in
            if oldValue != newValue && !newValue.isEmpty {
                print("New transcription: \(newValue)")
                // 建议提问
                suggestDifyManager.sendChatMessage(
                    query: newValue
                ) { result in
                    switch result {
                    case .success(let json):
                        let answer = json["answer"].stringValue
                        if !answer.contains("continue_listening") {
                            suggestionManager.pushSuggestion(
                                json["answer"].stringValue
                            )
                        }
                    case .failure(_):
                        print("Error sending chat message: \(result)")
                    }
                }
            }
        }
    }
}

#Preview(windowStyle: .plain) {
    ContentView()
}
