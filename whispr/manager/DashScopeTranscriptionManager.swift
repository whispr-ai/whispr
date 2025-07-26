//
//  DashScopeTranscriptionManager.swift
//  whispr
//
//  Created by 刘沛强 on 2025/7/25.
//

import AVFoundation
import Foundation
import SwiftyJSON

@Observable
class DashScopeTranscriptionManager: NSObject {
    var tempText: String = ""
    var globalText: String = ""
    var isConnected = false
    var connectionError: String?
    var isSentenceEnd: Bool = false

    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?
    private let apiKey = Configuration.dashScopeAPIKey
    private var currentTaskId: String?
    private var taskStarted = false

    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    override init() {
        super.init()
        setupURLSession()

        // 打印 API Key 来源信息
        print("🔑 DashScope API Key 来源: \(Configuration.dashScopeAPIKeySource)")

        // 验证 API Key 是否可用
        if !Configuration.hasValidDashScopeAPIKey {
            print("⚠️ 警告: 未配置有效的 DashScope API Key")
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
        guard
            let url = URL(
                string: "wss://dashscope.aliyuncs.com/api-ws/v1/inference"
            )
        else {
            print("❌ 无效的 WebSocket URL")
            return
        }

        var request = URLRequest(url: url)
        request.setValue(
            "bearer \(apiKey)",
            forHTTPHeaderField: "Authorization"
        )
        request.setValue("whispr-ios-client", forHTTPHeaderField: "user-agent")
        request.setValue(
            "enable",
            forHTTPHeaderField: "X-DashScope-DataInspection"
        )

        webSocketTask = urlSession?.webSocketTask(with: request)
        webSocketTask?.resume()

        // 开始监听消息
        receiveMessage()

        print("🔗 正在连接到 DashScope 实时语音识别...")
    }

    func disconnect() {
        // 如果任务正在运行，先发送结束任务指令
        if taskStarted {
            sendFinishTask()
        }

        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        taskStarted = false
        currentTaskId = nil

        DispatchQueue.main.async {
            self.isConnected = false
        }

        print("🔌 已断开 DashScope WebSocket 连接")
    }

    // MARK: - Task Management

    private func sendRunTask() {
        let taskId = generateTaskId()
        currentTaskId = taskId

        let runTaskMessage = RunTaskMessage(
            header: TaskHeader(
                action: "run-task",
                taskId: taskId,
                streaming: "duplex"
            ),
            payload: RunTaskPayload(
                taskGroup: "audio",
                task: "asr",
                function: "recognition",
                model: "paraformer-realtime-v2",
                parameters: TaskParameters(
                    format: "pcm",
                    sampleRate: 16000,
                    languageHints: ["zh", "en"],
                    disfluencyRemovalEnabled: true,
                    semanticPunctuationEnabled: true,
                    punctuationPredictionEnabled: true,
                    inverseTextNormalizationEnabled: true,
                    heartbeat: true,
                ),
                input: [:]
            )
        )

        do {
            let jsonData = try JSONEncoder().encode(runTaskMessage)
            let message = URLSessionWebSocketTask.Message.string(
                String(data: jsonData, encoding: .utf8)!
            )

            webSocketTask?.send(message) { error in
                if let error = error {
                    print("❌ 发送 run-task 指令失败: \(error.localizedDescription)")
                } else {
                    print("📤 已发送 run-task 指令")
                }
            }
        } catch {
            print("❌ 编码 run-task 指令失败: \(error.localizedDescription)")
        }
    }

    private func sendFinishTask() {
        guard let taskId = currentTaskId else { return }

        let finishTaskMessage = FinishTaskMessage(
            header: TaskHeader(
                action: "finish-task",
                taskId: taskId,
                streaming: "duplex"
            ),
            payload: FinishTaskPayload(input: [:])
        )

        do {
            let jsonData = try JSONEncoder().encode(finishTaskMessage)
            let message = URLSessionWebSocketTask.Message.string(
                String(data: jsonData, encoding: .utf8)!
            )

            webSocketTask?.send(message) { error in
                if let error = error {
                    print(
                        "❌ 发送 finish-task 指令失败: \(error.localizedDescription)"
                    )
                } else {
                    print("📤 已发送 finish-task 指令")
                }
            }
        } catch {
            print("❌ 编码 finish-task 指令失败: \(error.localizedDescription)")
        }
    }

    private func generateTaskId() -> String {
        return UUID().uuidString.replacingOccurrences(of: "-", with: "")
    }

    // MARK: - Audio Streaming

    func sendAudioData(_ audioData: Data) {
        guard isConnected && taskStarted else { return }

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
        print("📨 收到 DashScope 消息: \(text)")

        guard let jsonData = text.data(using: .utf8) else {
            print("❌ 无法将文本转换为 Data")
            return
        }

        let json = JSON(jsonData)

        // 检查是否解析成功
        if json == JSON.null {
            print("❌ JSON 解析失败")
            return
        }

        let event = json["header"]["event"].stringValue

        switch event {
        case "task-started":
            print("✅ 任务已开始")
            taskStarted = true

        case "result-generated":
            let sentence = json["payload"]["output"]["sentence"]

            if sentence.exists() {
                let transcript = sentence["text"].stringValue
                let sentenceEnd = sentence["sentence_end"].boolValue

                if !transcript.isEmpty {
                    DispatchQueue.main.async {
                        if sentenceEnd {
                            // 最终结果
                            self.tempText = ""
                            self.globalText += transcript + " "

                            // 检查是否有 stash 数据
                            let stash = sentence["stash"]
                            if stash.exists() {
                                let stashText = stash["text"].stringValue
                                if !stashText.isEmpty {
                                    self.tempText = stashText
                                    print(
                                        "✅ 最终结果: \(transcript) | 🔄 中间结果: \(stashText)"
                                    )
                                } else {
                                    print("✅ 最终结果: \(transcript)")
                                }
                            } else {
                                print("✅ 最终结果: \(transcript)")
                            }
                        } else {
                            // 中间结果
                            self.tempText = transcript
                            print("🔄 中间结果: \(transcript)")
                        }
                        self.isSentenceEnd = sentenceEnd
                    }
                }
            }

        case "task-finished":
            print("✅ 任务已完成")
            taskStarted = false
            currentTaskId = nil

        case "task-failed":
            print("❌ 任务失败")
            let errorCode = json["header"]["error_code"].stringValue
            let errorMessage = json["header"]["error_message"].stringValue

            if !errorCode.isEmpty && !errorMessage.isEmpty {
                print("错误码: \(errorCode), 错误信息: \(errorMessage)")
                DispatchQueue.main.async {
                    self.connectionError = errorMessage
                }
            }
            taskStarted = false
            currentTaskId = nil
            DispatchQueue.main.async {
                self.isConnected = false
            }

        default:
            print("🔍 未知事件类型: \(event)")
        }
    }

    // MARK: - Clean Method

    func clear() {
        // 断开连接
        disconnect()

        // 重置所有状态到初始值
        DispatchQueue.main.async {
            self.tempText = ""
            self.globalText = ""
            self.isConnected = false
            self.connectionError = nil
            self.isSentenceEnd = false
        }

        // 重置内部状态
        self.currentTaskId = nil
        self.taskStarted = false

        print("🧹 DashScopeTranscriptionManager 已清空并重置到初始状态")
    }
}

// MARK: - URLSessionWebSocketDelegate

extension DashScopeTranscriptionManager: URLSessionWebSocketDelegate {
    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        print("🔗 DashScope WebSocket 连接已建立")
        DispatchQueue.main.async {
            self.isConnected = true
        }

        // 连接建立后立即发送 run-task 指令
        sendRunTask()
    }

    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        print("🔌 DashScope WebSocket 连接已关闭: \(closeCode)")
        if let reason = reason,
            let reasonString = String(data: reason, encoding: .utf8)
        {
            print("关闭原因: \(reasonString)")
        }
        DispatchQueue.main.async {
            self.isConnected = false
        }
        taskStarted = false
        currentTaskId = nil
    }
}

// MARK: - Data Structures

// Request Messages
struct RunTaskMessage: Codable {
    let header: TaskHeader
    let payload: RunTaskPayload
}

struct FinishTaskMessage: Codable {
    let header: TaskHeader
    let payload: FinishTaskPayload
}

struct TaskHeader: Codable {
    let action: String
    let taskId: String
    let streaming: String

    enum CodingKeys: String, CodingKey {
        case action
        case taskId = "task_id"
        case streaming
    }
}

struct RunTaskPayload: Codable {
    let taskGroup: String
    let task: String
    let function: String
    let model: String
    let parameters: TaskParameters
    let input: [String: String]

    enum CodingKeys: String, CodingKey {
        case taskGroup = "task_group"
        case task
        case function
        case model
        case parameters
        case input
    }
}

struct FinishTaskPayload: Codable {
    let input: [String: String]
}

struct TaskParameters: Codable {
    let format: String
    let sampleRate: Int
    let languageHints: [String]?
    let disfluencyRemovalEnabled: Bool?
    let semanticPunctuationEnabled: Bool?
    let punctuationPredictionEnabled: Bool?
    let inverseTextNormalizationEnabled: Bool?
    let heartbeat: Bool?

    enum CodingKeys: String, CodingKey {
        case format
        case sampleRate = "sample_rate"
        case languageHints = "language_hints"
        case disfluencyRemovalEnabled = "disfluency_removal_enabled"
        case semanticPunctuationEnabled = "semantic_punctuation_enabled"
        case punctuationPredictionEnabled = "punctuation_prediction_enabled"
        case inverseTextNormalizationEnabled =
            "inverse_text_normalization_enabled"
        case heartbeat
    }
}
