//
//  whisprApp.swift
//  whispr
//
//  Created by 刘沛强 on 2025/7/22.
//

import SwiftUI

@main
struct whisprApp: App {
    var body: some Scene {
        // 主窗口 - 1000x1000
        WindowGroup {
            ContentView()
        }
        .defaultSize(width: 1000, height: 800)
        .windowStyle(.plain)
    }
}
