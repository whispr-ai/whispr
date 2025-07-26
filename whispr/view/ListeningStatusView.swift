//
//  ListeningStatusView.swift
//  whispr
//
//  Created by 刘沛强 on 2025/7/24.
//
import RealityKit
import RealityKitContent
import SwiftUI

enum ListeningStatus {
    case listening
    case pause
    case stop
}

struct ListeningStatusView: View {

    let status: ListeningStatus
    @State private var pulseAnimation: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Circle()
                    .fill(circleColor)
                    .frame(width: 12, height: 12)
                    .scaleEffect(shouldPulse ? 1.2 : 1.0)
                    .opacity(shouldPulse ? 0.7 : 1.0)

                Text(statusText)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: borderColors),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 2
                    )
            )
            .glassBackgroundEffect()
        }
        .onAppear {
            updateAnimation()
        }
        .onChange(of: status) {
            updateAnimation()
        }

        Spacer()
    }

    // MARK: - Computed Properties

    private var circleColor: Color {
        switch status {
        case .listening:
            return .green
        case .pause:
            return .orange
        case .stop:
            return .gray
        }
    }

    private var statusText: String {
        switch status {
        case .listening:
            return "正在聆听..."
        case .pause:
            return "你正在查看建议"
        case .stop:
            return "随时准备好开始聆听！"
        }
    }

    private var borderColors: [Color] {
        switch status {
        case .listening:
            return [.blue, .purple]
        case .pause:
            return [.orange, .yellow]
        case .stop:
            return [.gray, .gray.opacity(0.5)]
        }
    }

    private var shouldPulse: Bool {
        return status == .listening && pulseAnimation
    }

    // MARK: - Animation Control

    private func updateAnimation() {
        switch status {
        case .listening:
            withAnimation(
                Animation.easeInOut(duration: 2.0).repeatForever(
                    autoreverses: true
                )
            ) {
                pulseAnimation = true
            }
        case .pause, .stop:
            withAnimation(.easeOut(duration: 0.3)) {
                pulseAnimation = false
            }
        }
    }
}

#Preview {
    ListeningStatusView(
        status: .listening
    )
}
