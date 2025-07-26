//
//  whisprApp.swift
//  whispr
//
//  Created by 刘沛强 on 2025/7/22.
//

import ARKit
import SwiftUI

@main
struct whisprApp: App {

    @State private var dashscopeTranscriptionManager:
        DashScopeTranscriptionManager = DashScopeTranscriptionManager()
    @State private var audioRecorderManager: AudioRecorderManager =
        AudioRecorderManager()
    @State private var suggestionManager: SuggestionManager =
        SuggestionManager()
    @State private var emotionManager: EmotionManager =
        EmotionManager()
    @State private var keywordManager: KeywordManager = KeywordManager()

    // Register the system and the component.
    init() {
        FollowSystem.registerSystem()
        FollowComponent.registerComponent()
    }

    var body: some Scene {
        ImmersiveSpace {
            ImmersiveView()
                .environment(dashscopeTranscriptionManager)
                .environment(audioRecorderManager)
                .environment(suggestionManager)
                .environment(emotionManager)
                .environment(keywordManager)
                .onAppear {
                    self.audioRecorderManager.transcriptionManager =
                        dashscopeTranscriptionManager
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)

    }
}
