//
//  DifyManager.swift
//  whispr
//
//  Created by 刘沛强 on 2025/7/26.
//

import Foundation
import SwiftUI
import SwiftyJSON

// MARK: - Data Models (Simplified for SwiftyJSON)
struct DifyFileInput {
    let type: String
    let transferMethod: String
    let url: String

    func toDictionary() -> [String: Any] {
        return [
            "type": type,
            "transfer_method": transferMethod,
            "url": url,
        ]
    }
}

class DifyManager: NSObject, ObservableObject {
    @Published var response: String = ""
    @Published var isLoading = false
    @Published var connectionError: String?
    @Published var conversationId: String = ""
    @Published var currentUsage: [String: Any] = [:]
    @Published var retrieverResources: [[String: Any]] = []
    @Published var lastResponseJSON: JSON = JSON.null

    private let baseURL = "https://api.dify.ai/v1"
    private let userId = "whispr-user-\(UUID().uuidString)"

    // MARK: - Public Methods

    /// 发送聊天消息到Dify
    /// - Parameters:
    ///   - query: 用户的查询内容
    ///   - files: 可选的文件列表
    ///   - completion: 完成回调
    func sendChatMessage(
        appKey: String,
        query: String,
        files: [DifyFileInput]? = nil,
        completion: @escaping (Result<JSON, Error>) -> Void
    ) {
        DispatchQueue.main.async {
            self.isLoading = true
            self.connectionError = nil
        }

        // 构建请求参数
        var requestParams: [String: Any] = [
            "inputs": [:],
            "query": query,
            "response_mode": "blocking",
            "conversation_id": conversationId,
            "user": userId,
        ]

        // 添加文件参数
        if let files = files {
            requestParams["files"] = files.map { $0.toDictionary() }
        }

        sendRequest(
            appKey: appKey,
            params: requestParams,
            completion: completion
        )
    }

    /// 重置对话
    func resetConversation() {
        DispatchQueue.main.async {
            self.conversationId = ""
            self.response = ""
            self.currentUsage = [:]
            self.retrieverResources = []
            self.connectionError = nil
            self.lastResponseJSON = JSON.null
        }
    }

    // MARK: - Convenience Methods for SwiftyJSON

    /// 获取回答文本
    func getAnswer() -> String {
        return lastResponseJSON["answer"].stringValue
    }

    /// 获取使用情况统计
    func getUsage() -> JSON {
        return lastResponseJSON["metadata"]["usage"]
    }

    /// 获取检索资源
    func getRetrieverResources() -> JSON {
        return lastResponseJSON["metadata"]["retriever_resources"]
    }

    /// 获取token使用量
    func getTotalTokens() -> Int {
        return lastResponseJSON["metadata"]["usage"]["total_tokens"].intValue
    }

    /// 获取总价格
    func getTotalPrice() -> String {
        return lastResponseJSON["metadata"]["usage"]["total_price"].stringValue
    }

    /// 获取延迟时间
    func getLatency() -> Double {
        return lastResponseJSON["metadata"]["usage"]["latency"].doubleValue
    }

    // MARK: - Private Methods

    private func sendRequest(
        appKey: String,
        params: [String: Any],
        completion: @escaping (Result<JSON, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/chat-messages") else {
            completion(.failure(DifyError.invalidURL))
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue(
            "Bearer \(appKey)",
            forHTTPHeaderField: "Authorization"
        )
        urlRequest.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        do {
            urlRequest.httpBody = try JSONSerialization.data(
                withJSONObject: params
            )
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.connectionError = "请求编码失败: \(error.localizedDescription)"
            }
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: urlRequest) {
            [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    self?.connectionError =
                        "网络错误: \(error.localizedDescription)"
                }
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                let error = DifyError.invalidResponse
                DispatchQueue.main.async {
                    self?.connectionError = "无效的响应"
                }
                completion(.failure(error))
                return
            }

            guard 200...299 ~= httpResponse.statusCode else {
                let error = DifyError.httpError(httpResponse.statusCode)
                DispatchQueue.main.async {
                    self?.connectionError = "HTTP错误: \(httpResponse.statusCode)"
                }
                completion(.failure(error))
                return
            }

            guard let data = data else {
                let error = DifyError.noData
                DispatchQueue.main.async {
                    self?.connectionError = "无响应数据"
                }
                completion(.failure(error))
                return
            }

            // 使用SwiftyJSON解析响应
            self?.processJSONResponse(data: data, completion: completion)

        }.resume()
    }

    private func processJSONResponse(
        data: Data,
        completion: @escaping (Result<JSON, Error>) -> Void
    ) {
        do {
            // 使用SwiftyJSON解析
            let json = try JSON(data: data)

            DispatchQueue.main.async {
                // 更新UI状态
                self.lastResponseJSON = json
                self.response = json["answer"].stringValue
                self.conversationId = json["conversation_id"].stringValue

                // 提取使用统计信息
                let usage = json["metadata"]["usage"]
                self.currentUsage = [
                    "prompt_tokens": usage["prompt_tokens"].intValue,
                    "completion_tokens": usage["completion_tokens"].intValue,
                    "total_tokens": usage["total_tokens"].intValue,
                    "total_price": usage["total_price"].stringValue,
                    "currency": usage["currency"].stringValue,
                    "latency": usage["latency"].doubleValue,
                ]

                // 提取检索资源
                if let resources = json["metadata"]["retriever_resources"].array
                {
                    self.retrieverResources = resources.map { resource in
                        return [
                            "position": resource["position"].intValue,
                            "dataset_name": resource["dataset_name"]
                                .stringValue,
                            "document_name": resource["document_name"]
                                .stringValue,
                            "score": resource["score"].doubleValue,
                            "content": resource["content"].stringValue,
                        ]
                    }
                }

                print("✅ Dify 响应解析成功")
                print("📝 回答: \(self.response)")
                print("💰 使用情况: \(self.currentUsage)")
            }

            completion(.success(json))

        } catch {
            DispatchQueue.main.async {
                self.connectionError = "JSON解析失败: \(error.localizedDescription)"
            }
            completion(.failure(error))
        }
    }
}

// MARK: - Error Types
enum DifyError: LocalizedError {
    case invalidAPIKey
    case invalidURL
    case invalidResponse
    case invalidData
    case noData
    case httpError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "无效的API密钥"
        case .invalidURL:
            return "无效的URL"
        case .invalidResponse:
            return "无效的响应"
        case .invalidData:
            return "无效的数据格式"
        case .noData:
            return "无响应数据"
        case .httpError(let code):
            return "HTTP错误，状态码: \(code)"
        }
    }
}
