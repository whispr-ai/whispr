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

    var body: some View {
        VStack(spacing: 30) {
            //            Model3D(named: "Scene", bundle: realityKitContentBundle)
            //                .padding(.bottom, 50)

            Text("Hello, world!123123")
                .font(.title)

            VStack(spacing: 20) {
                Text("麦克风权限状态: \(audioRecorder.permissionStatus)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Button(action: {
                    if audioRecorder.hasPermission {
                        audioRecorder.toggleRecording()
                    } else {
                        showPermissionModal = true
                    }
                }) {
                    HStack {
                        Image(
                            systemName: audioRecorder.isRecording
                                ? "stop.circle.fill" : "mic.circle.fill"
                        )
                        .font(.title2)

                        Text(
                            audioRecorder.isRecording
                                ? "停止录音"
                                : audioRecorder.hasPermission
                                    ? "开始录音" : "申请麦克风权限"
                        )
                    }
                    .padding()
                    .foregroundColor(.white)
                }

                if audioRecorder.isRecording {
                    HStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                            .scaleEffect(audioRecorder.isRecording ? 1.0 : 0.5)
                            .animation(
                                Animation.easeInOut(duration: 1.0)
                                    .repeatForever(),
                                value: audioRecorder.isRecording
                            )

                        Text("正在录音...")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .padding()
        .onAppear {
            audioRecorder.checkPermissionStatus()
            // 如果没有权限，自动显示权限弹窗
            if !audioRecorder.hasPermission {
                showPermissionModal = true
            }
        }
        .onChange(of: audioRecorder.hasPermission) { hasPermission in
            if !hasPermission {
                showPermissionModal = true
            } else {
                showPermissionModal = false
            }
        }
        .sheet(isPresented: $showPermissionModal) {
            PermissionModalView(audioRecorder: audioRecorder)
                .frame(width: 400, height: 500)
                .interactiveDismissDisabled(true) // 防止用户手动关闭弹窗
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
