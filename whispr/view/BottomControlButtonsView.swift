//
//  BottomControlButtonsView.swift
//  whispr
//
//  Created by 刘沛强 on 2025/7/25.
//

import SwiftUI

struct BottomControlButtonsView: View {
    @ObservedObject var audioRecorder: AudioRecorderManager
    @ObservedObject var suggestion: SuggestionManager

    var body: some View {
        HStack(spacing: 18) {
            // 麦克风按钮
            Button(action: {
                audioRecorder.toggleRecording()
            }) {
                Image(systemName: "mic.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Circle().fill(.regularMaterial))
                    .background(
                        Circle().fill(
                            audioRecorder.isRecording
                                ? Color.green.opacity(1)
                                : Color.black.opacity(1)
                        )
                    )
                    .clipShape(Circle())
            }.help(audioRecorder.isRecording ? "停止" : "开始聆听")
                .buttonStyle(.plain)

            // 清屏按钮 (类似开关)
            Button(action: {
                audioRecorder.transcriptionManager.clear()
                suggestion.clear()
            }) {
                Image(systemName: "xmark.bin")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Circle().fill(.regularMaterial))
                    .background(Circle().fill(Color.black.opacity(1)))
                    .clipShape(Circle())
            }.help("清屏")
                .buttonStyle(.plain)

        }
    }
}

#Preview {
    BottomControlButtonsView(
        audioRecorder: AudioRecorderManager(),
        suggestion: SuggestionManager()
    )
}
