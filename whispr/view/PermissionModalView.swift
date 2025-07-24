//
//  PermissionModalView.swift
//  whispr
//
//  Created by 刘沛强 on 2025/7/24.
//

import AVFoundation
import SwiftUI

struct PermissionModalView: View {
    @ObservedObject var audioRecorder: AudioRecorderManager

    var body: some View {
        ZStack {
            // visionOS 背景材质
            Color.clear
                .background(
                    .regularMaterial,
                    in: RoundedRectangle(cornerRadius: 24)
                )

            VStack(spacing: 40) {
                // 应用标识区域 - 使用 visionOS 风格的容器
                VStack(spacing: 24) {
                    // 麦克风图标 - 使用 visionOS 的深度效果
                    ZStack {
                        Circle()
                            .fill(.blue.gradient)
                            .frame(width: 80, height: 80)
                            .shadow(
                                color: .blue.opacity(0.3),
                                radius: 15,
                                x: 0,
                                y: 8
                            )

                        Image(systemName: "mic.fill")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundStyle(.white)
                    }

                    // 标题
                    Text("Whispr 授权")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }

                // 权限说明
                VStack(spacing: 16) {
                    Text("需要访问您的麦克风来提供录音功能")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }

                // 操作按钮
                Button(action: {
                    audioRecorder.requestPermission()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: getButtonIcon())
                            .font(.system(size: 16, weight: .medium))

                        Text(getButtonText())
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(
                        getButtonColor().gradient,
                        in: Capsule()
                    )
                    .shadow(
                        color: getButtonColor().opacity(0.4),
                        radius: 12,
                        x: 0,
                        y: 6
                    )
                }
                .buttonStyle(.plain)
                .scaleEffect(
                    audioRecorder.permissionStatus == "已授权" ? 1.05 : 1.0
                )
                .animation(
                    .spring(response: 0.6, dampingFraction: 0.8),
                    value: audioRecorder.permissionStatus
                )

                // 底部说明文字
                if audioRecorder.permissionStatus == "已拒绝" {
                    Text("权限被拒绝后，请手动前往设置重新打开权限")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(32)
        }
        .onAppear {
            audioRecorder.checkPermissionStatus()
        }
    }

    private func getStatusIcon() -> String {
        switch audioRecorder.permissionStatus {
        case "已授权":
            return "checkmark.circle.fill"
        case "已拒绝":
            return "xmark.circle.fill"
        case "未确定", "未知":
            return "questionmark.circle.fill"
        default:
            return "questionmark.circle.fill"
        }
    }

    private func getStatusColor() -> Color {
        switch audioRecorder.permissionStatus {
        case "已授权":
            return .green
        case "已拒绝":
            return .red
        case "未确定", "未知":
            return .orange
        default:
            return .gray
        }
    }

    private func getButtonIcon() -> String {
        switch audioRecorder.permissionStatus {
        case "已授权":
            return "checkmark.circle.fill"
        default:
            return "mic.badge.plus"
        }
    }

    private func getButtonText() -> String {
        switch audioRecorder.permissionStatus {
        case "已授权":
            return "权限已获取"
        default:
            return "授权麦克风访问"
        }
    }

    private func getButtonColor() -> Color {
        switch audioRecorder.permissionStatus {
        case "已授权":
            return .green
        default:
            return .blue
        }
    }
}

#Preview {
    PermissionModalView(audioRecorder: AudioRecorderManager())
        .frame(width: 400, height: 500)
}
