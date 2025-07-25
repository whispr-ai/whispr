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
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.regularMaterial)
                .background(Color.black.opacity(0.5))
        )
        .clipShape(RoundedRectangle(cornerRadius: 25))
        // 边框渐变并且圆角
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: borderColors),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 2
                )
        )
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
            return "Listening..."
        case .pause:
            return "You are looking suggestions"
        case .stop:
            return "Ready to listen"
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
