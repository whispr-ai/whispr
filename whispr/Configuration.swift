//
//  Configuration.swift
//  whispr
//
//  Created by 刘沛强 on 2025/7/24.
//

import Foundation

struct Configuration {
    
    // MARK: - API Keys
    
    static var deepgramAPIKey: String {
        // 方案1: 从 Info.plist 读取
        if let key = Bundle.main.object(forInfoDictionaryKey: "DeepgramAPIKey") as? String,
           !key.isEmpty && !key.hasPrefix("$(") {
            return "Token \(key)"
        }
        
        // 方案2: 从环境变量读取
        if let key = ProcessInfo.processInfo.environment["DEEPGRAM_API_KEY"], !key.isEmpty {
            return "Token \(key)"
        }
        
        // 方案3: 从用户默认设置读取
        if let key = UserDefaults.standard.string(forKey: "DeepgramAPIKey"), !key.isEmpty {
            return "Token \(key)"
        }
        
        // 开发环境默认值（仅用于开发）
        #if DEBUG
        print("⚠️ 警告: 使用硬编码的 API Key，请设置环境变量 DEEPGRAM_API_KEY")
        return "Token xxxx"
        #else
        fatalError("❌ 未找到 Deepgram API Key。请设置环境变量 DEEPGRAM_API_KEY")
        #endif
    }
    
    // MARK: - Helper Methods
    
    /// 设置 API Key 到 UserDefaults（用于运行时配置）
    static func setDeepgramAPIKey(_ key: String) {
        UserDefaults.standard.set(key, forKey: "DeepgramAPIKey")
    }
    
    /// 检查 API Key 是否已配置
    static var hasValidAPIKey: Bool {
        // 检查各种配置源
        if let plistKey = Bundle.main.object(forInfoDictionaryKey: "DeepgramAPIKey") as? String,
           !plistKey.isEmpty && !plistKey.hasPrefix("$(") {
            return true
        }
        
        if let envKey = ProcessInfo.processInfo.environment["DEEPGRAM_API_KEY"], !envKey.isEmpty {
            return true
        }
        
        if let userKey = UserDefaults.standard.string(forKey: "DeepgramAPIKey"), !userKey.isEmpty {
            return true
        }
        
        #if DEBUG
        return true // 开发环境使用默认值
        #else
        return false
        #endif
    }
    
    /// 获取 API Key 来源信息
    static var apiKeySource: String {
        if let _ = Bundle.main.object(forInfoDictionaryKey: "DeepgramAPIKey") as? String {
            return "Info.plist"
        } else if let _ = ProcessInfo.processInfo.environment["DEEPGRAM_API_KEY"] {
            return "环境变量"
        } else if let _ = UserDefaults.standard.string(forKey: "DeepgramAPIKey") {
            return "用户设置"
        } else {
            return "硬编码（开发环境）"
        }
    }
}
