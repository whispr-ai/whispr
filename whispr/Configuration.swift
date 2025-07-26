//
//  Configuration.swift
//  whispr
//
//  Created by 刘沛强 on 2025/7/24.
//

import Foundation

class Configuration {
    // MARK: - Deepgram Configuration
    static var deepgramAPIKey: String {
        // 首先尝试从环境变量获取
        if let envKey = ProcessInfo.processInfo.environment["DEEPGRAM_API_KEY"],
            !envKey.isEmpty
        {
            return envKey
        }

        // 如果环境变量不存在，返回默认值（在生产环境中应该使用安全的配置方式）
        return "cf02bee37485040c4fd06428294218b005bf301e"
    }

    // MARK: - DashScope Configuration
    static var dashScopeAPIKey: String {
        // 首先尝试从环境变量获取
        if let envKey = ProcessInfo.processInfo.environment[
            "DASHSCOPE_API_KEY"
        ],
            !envKey.isEmpty
        {
            return envKey
        }

        // 如果环境变量不存在，返回默认值（在生产环境中应该使用安全的配置方式）
        return "sk-7bb3329ec06b4da08982b62fc9f885a3"
    }

    // MARK: - Dify Configuration
    static var difyAPIKey: String {
        // 首先尝试从环境变量获取
        if let envKey = ProcessInfo.processInfo.environment["DIFY_API_KEY"],
            !envKey.isEmpty
        {
            return envKey
        }

        // 如果环境变量不存在，返回默认值（在生产环境中应该使用安全的配置方式）
        return "your_dify_api_key_here"
    }

    // MARK: - Validation
    static var hasValidDeepgramAPIKey: Bool {
        let key = deepgramAPIKey
        return !key.isEmpty && key != "your_deepgram_api_key_here"
    }

    static var hasValidDashScopeAPIKey: Bool {
        let key = dashScopeAPIKey
        return !key.isEmpty && key != "your_dashscope_api_key_here"
    }

    static var hasValidDifyAPIKey: Bool {
        let key = difyAPIKey
        return !key.isEmpty && key != "your_dify_api_key_here"
    }

    static var hasValidAPIKey: Bool {
        return hasValidDeepgramAPIKey
    }

    static var apiKeySource: String {
        if ProcessInfo.processInfo.environment["DEEPGRAM_API_KEY"] != nil {
            return "环境变量"
        } else {
            return "配置文件"
        }
    }

    static var dashScopeAPIKeySource: String {
        if ProcessInfo.processInfo.environment["DASHSCOPE_API_KEY"] != nil {
            return "环境变量"
        } else {
            return "配置文件"
        }
    }

    static var difyAPIKeySource: String {
        if ProcessInfo.processInfo.environment["DIFY_API_KEY"] != nil {
            return "环境变量"
        } else {
            return "配置文件"
        }
    }
}
