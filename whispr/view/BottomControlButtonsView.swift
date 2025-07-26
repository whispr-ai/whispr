//
//  BottomControlButtonsView.swift
//  whispr
//
//  Created by 刘沛强 on 2025/7/25.
//

import SwiftUI

struct BottomControlButtonsView: View {

    @Environment(AudioRecorderManager.self) var audioRecorderManager
    @Environment(SuggestionManager.self) var suggestionManager
    @Environment(KeywordManager.self) var keywordManager
    @Environment(EmotionManager.self) var emotionManager
    @Environment(SearchManager.self) var searchManager

    var body: some View {
        HStack(spacing: 18) {
            // 麦克风按钮
            Button(action: {
                audioRecorderManager.toggleRecording()
            }) {
                Image(systemName: "mic.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        (audioRecorderManager.isRecording
                            ? .green
                            : .clear)
                    )
                    .glassBackgroundEffect(in: .circle)
                    .clipShape(Circle())
            }.help(audioRecorderManager.isRecording ? "停止" : "开始聆听")
                .buttonStyle(.plain)

            // 清屏按钮 (类似开关)
            Button(action: {
                audioRecorderManager.transcriptionManager?.clear()
                suggestionManager.clear()
                keywordManager.clear()
                emotionManager.clear()
                searchManager.clear()
            }) {
                Image(systemName: "xmark.bin")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .glassBackgroundEffect(in: .circle)
                    .clipShape(Circle())
            }.help("清屏")
                .buttonStyle(.plain)

        }
    }
}
