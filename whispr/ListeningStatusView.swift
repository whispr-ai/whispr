//
//  ListeningStatusView.swift
//  whispr
//
//  Created by 刘沛强 on 2025/7/24.
//
import RealityKit
import RealityKitContent
import SwiftUI

struct ListeningStatusView: View {
    let isListening: Bool
    @State private var pulseAnimation: Bool = false

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(isListening ? Color.green : Color.gray)
                .frame(width: 12, height: 12)
                .scaleEffect(isListening && pulseAnimation ? 1.2 : 1.0)
                .opacity(isListening && pulseAnimation ? 0.7 : 1.0)

            Text(isListening ? "Listening..." : "Ready to listen")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.regularMaterial)
                .background(Color.black.opacity(0.3))
        )
        .clipShape(RoundedRectangle(cornerRadius: 25))
        // 边框渐变并且圆角
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(
                            colors: isListening
                                ? [.blue, .purple]
                                : [.gray, .gray.opacity(0.5)]
                        ),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 2
                )
        )
        .onAppear {
            if isListening {
                withAnimation(
                    Animation.easeInOut(duration: 2.0).repeatForever(
                        autoreverses: true
                    )
                ) {
                    pulseAnimation = true
                }
            }
        }
        .onChange(of: isListening) { newValue in
            if newValue {
                withAnimation(
                    Animation.easeInOut(duration: 2.0).repeatForever(
                        autoreverses: true
                    )
                ) {
                    pulseAnimation = true
                }
            } else {
                withAnimation(.easeOut(duration: 0.3)) {
                    pulseAnimation = false
                }
            }
        }

        Spacer()

    }
}
