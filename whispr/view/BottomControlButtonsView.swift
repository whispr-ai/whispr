//
//  BottomControlButtonsView.swift
//  whispr
//
//  Created by 刘沛强 on 2025/7/25.
//

import SwiftUI

struct BottomControlButtonsView: View {
    @ObservedObject var audioRecorder: AudioRecorderManager

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
                                ? Color.green.opacity(0.8)
                                : Color.black.opacity(0.8)
                        )
                    )
                    .clipShape(Circle())
            }.buttonStyle(.plain)

            // 中心按钮 (类似开关)
            Button(action: {
            }) {
                Image(systemName: "power")
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

#Preview {
    BottomControlButtonsView(audioRecorder: AudioRecorderManager())
}
