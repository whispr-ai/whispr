//
//  DeepgramTranscriptionManager.swift
//  whispr
//
//  Created by 刘沛强 on 2025/7/24.
//

import AVFoundation
import Foundation

class DeepgramTranscriptionManager: NSObject, ObservableObject {
    @Published var tempText: String = ""
    @Published var globalText: String = ""
    @Published var isConnected = false
    @Published var connectionError: String?

    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?
    private let apiKey = Configuration.deepgramAPIKey  // 使用配置管理器

    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    override init() {
        super.init()
        setupURLSession()

        // 打印 API Key 来源信息
        print("🔑 Deepgram API Key 来源: \(Configuration.apiKeySource)")

        // 验证 API Key 是否可用
        if !Configuration.hasValidAPIKey {
            print("⚠️ 警告: 未配置有效的 Deepgram API Key")
        }
    }

    private func setupURLSession() {
        let config = URLSessionConfiguration.default
        urlSession = URLSession(
            configuration: config,
            delegate: self,
            delegateQueue: nil
        )
    }

    // MARK: - WebSocket Connection

    func connect() {
        // 参考 UIKit 代码的 URL 和参数设置
        let urlString =
            "wss://api.deepgram.com/v1/listen?encoding=linear16&sample_rate=16000&channels=1&model=nova-3&smart_format=true&punctuate=true&filler_words=true&language=en&interim_results=true"

        guard let url = URL(string: urlString) else {
            print("❌ 无效的 WebSocket URL")
            return
        }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")

        webSocketTask = urlSession?.webSocketTask(with: request)
        webSocketTask?.resume()

        // 开始监听消息
        receiveMessage()

        print("🔗 正在连接到 Deepgram 实时语音识别...")
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil

        DispatchQueue.main.async {
            self.isConnected = false
        }

        print("🔌 已断开 Deepgram WebSocket 连接")
    }

    // MARK: - Audio Streaming

    func sendAudioData(_ audioData: Data) {
        guard isConnected else { return }

        let message = URLSessionWebSocketTask.Message.data(audioData)
        webSocketTask?.send(message) { error in
            if let error = error {
                print("❌ 发送音频数据失败: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Message Handling

    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.handleReceivedMessage(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        self?.handleReceivedMessage(text)
                    }
                @unknown default:
                    break
                }

                // 继续监听下一条消息
                self?.receiveMessage()

            case .failure(let error):
                print("❌ 接收消息失败: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.connectionError = error.localizedDescription
                    self?.isConnected = false
                }
            }
        }
    }

    private func handleReceivedMessage(_ text: String) {
        print("📨 收到 Deepgram 消息: \(text)")

        // 参考 UIKit 代码的消息解析方式
        let jsonData = Data(text.utf8)
        do {
            let response = try jsonDecoder.decode(
                DeepgramResponse.self,
                from: jsonData
            )
            let transcript =
                response.channel.alternatives.first?.transcript ?? ""

            if !transcript.isEmpty {
                if response.isFinal {
                    DispatchQueue.main.async {
                        self.tempText = transcript
                        self.globalText = self.globalText + transcript + " "
                    }
                    print("✅ 最终 globalText: \(self.globalText)")
                }
                print("过程转录：\(self.tempText)")
            }
        } catch {
            print("❌ 解析 Deepgram 消息失败: \(error.localizedDescription)")
        }
    }
}

// MARK: - URLSessionWebSocketDelegate

extension DeepgramTranscriptionManager: URLSessionWebSocketDelegate {
    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        print("🔗 Deepgram WebSocket 连接已建立")
        DispatchQueue.main.async {
            self.isConnected = true
        }
    }

    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        print("🔌 Deepgram WebSocket 连接已关闭: \(closeCode)")
        if let reason = reason,
            let reasonString = String(data: reason, encoding: .utf8)
        {
            print("关闭原因: \(reasonString)")
        }
        DispatchQueue.main.async {
            self.isConnected = false
        }
    }
}

// MARK: - 参考 UIKit 代码的数据结构

struct DeepgramResponse: Codable {
    let isFinal: Bool
    let channel: Channel

    struct Channel: Codable {
        let alternatives: [Alternatives]
    }

    struct Alternatives: Codable {
        let transcript: String
    }
}
