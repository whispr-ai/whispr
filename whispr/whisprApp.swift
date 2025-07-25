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

    // Register the system and the component.
    init() {
        FollowSystem.registerSystem()
        FollowComponent.registerComponent()
    }

    var body: some Scene {
        ImmersiveSpace {
            ImmersiveView()
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)

    }
}
