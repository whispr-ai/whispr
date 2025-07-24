//
//  AudioRecorderManager.swift
//  whispr
//
//  Created by 刘沛强 on 2025/7/24.
//

import AVFoundation
import Foundation
import SwiftUI

class AudioRecorderManager: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var hasPermission = false
    @Published var permissionStatus: String = "未知"

    private var audioRecorder: AVAudioRecorder?
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    private let audioSession = AVAudioSession.sharedInstance()

    // Deepgram WebSocket 管理器 - 公开访问
    let transcriptionManager = DeepgramTranscriptionManager()

    override init() {
        super.init()
        checkPermissionStatus()
        setupAudioEngine()
    }

    // MARK: - Audio Engine Setup

    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        inputNode = audioEngine?.inputNode
    }

    func checkPermissionStatus() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            hasPermission = true
            permissionStatus = "已授权"
        case .denied:
            hasPermission = false
            permissionStatus = "已拒绝"
        case .undetermined:
            hasPermission = false
            permissionStatus = "未确定"
        @unknown default:
            hasPermission = false
            permissionStatus = "未知"
        }
    }

    func requestPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                self?.hasPermission = granted
                self?.permissionStatus = granted ? "已授权" : "已拒绝"
                // 权限变更后重新检查状态
                self?.checkPermissionStatus()
            }
        }
    }

    func startRecording() {
        guard hasPermission else {
            requestPermission()
            return
        }

        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement)
            try audioSession.setActive(
                true,
                options: .notifyOthersOnDeactivation
            )

            // 连接到 OpenAI WebSocket
            transcriptionManager.connectToDeepgram()

            // 启动音频引擎进行实时流传输
            try startAudioStreaming()

            // 同时启动文件录音（可选）
            try startFileRecording()

            isRecording = true
            print("✅ 开始录音和实时转录")

        } catch {
            print("❌ 录音失败: \(error.localizedDescription)")
        }
    }

    private func startAudioStreaming() throws {
        guard let audioEngine = audioEngine,
            let inputNode = inputNode
        else {
            throw NSError(
                domain: "AudioEngine",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "音频引擎未初始化"]
            )
        }

        // 获取输入格式，但要检查有效性
        let inputFormat = inputNode.outputFormat(forBus: 0)
        print(
            "🎤 输入格式: 采样率=\(inputFormat.sampleRate), 声道数=\(inputFormat.channelCount)"
        )

        // 创建一个有效的输入格式（如果原始格式无效）
        let validInputFormat: AVAudioFormat
        if inputFormat.sampleRate == 0 || inputFormat.channelCount == 0 {
            guard
                let defaultFormat = AVAudioFormat(
                    commonFormat: .pcmFormatFloat32,
                    sampleRate: 48000,
                    channels: 1,
                    interleaved: false
                )
            else {
                throw NSError(
                    domain: "AudioFormat",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "无法创建默认输入音频格式"]
                )
            }
            validInputFormat = defaultFormat
            print(
                "⚠️ 使用默认输入格式: 采样率=\(validInputFormat.sampleRate), 声道数=\(validInputFormat.channelCount)"
            )
        } else {
            validInputFormat = inputFormat
        }

        // 创建中间格式 - 与输入格式兼容，用于 tap
        guard
            let intermediateFormat = AVAudioFormat(
                commonFormat: .pcmFormatFloat32,
                sampleRate: validInputFormat.sampleRate, // 保持输入采样率
                channels: validInputFormat.channelCount,  // 保持输入声道数
                interleaved: false
            )
        else {
            throw NSError(
                domain: "AudioFormat",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "无法创建中间音频格式"]
            )
        }

        print(
            "🎵 中间格式: 采样率=\(intermediateFormat.sampleRate), 声道数=\(intermediateFormat.channelCount)"
        )

        let converterNode = AVAudioMixerNode()
        let sinkNode = AVAudioMixerNode()

        audioEngine.attach(converterNode)
        audioEngine.attach(sinkNode)

        // 在 converterNode 上安装 tap，使用兼容的中间格式
        converterNode.installTap(
            onBus: 0,
            bufferSize: 1024,
            format: intermediateFormat // 使用与输入兼容的格式
        ) { [weak self] buffer, time in
            // 在这里进行格式转换到 Deepgram 要求的格式
            if let convertedData = self?.convertBufferToDeepgramFormat(buffer) {
                self?.transcriptionManager.sendAudioData(convertedData)
            }
        }

        // 连接音频节点
        audioEngine.connect(
            inputNode,
            to: converterNode,
            format: validInputFormat
        )
        audioEngine.connect(converterNode, to: sinkNode, format: intermediateFormat)

        print("🔗 音频节点连接完成")
        audioEngine.prepare()

        // 启动音频引擎
        try audioEngine.start()
        print("🎙️ Deepgram 音频流传输已开始")
    }

    // 新增：将音频缓冲区转换为 Deepgram 要求的格式
    private func convertBufferToDeepgramFormat(_ inputBuffer: AVAudioPCMBuffer) -> Data? {
        // 创建 Deepgram 要求的输出格式
        guard let outputFormat = AVAudioFormat(
            commonFormat: .pcmFormatInt16,
            sampleRate: 16000,
            channels: 1,
            interleaved: true
        ) else {
            print("❌ 无法创建 Deepgram 输出格式")
            return nil
        }

        // 创建音频转换器
        guard let converter = AVAudioConverter(from: inputBuffer.format, to: outputFormat) else {
            print("❌ 无法创建音频转换器")
            return nil
        }

        // 计算输出缓冲区大小
        let outputCapacity = AVAudioFrameCount(
            Double(inputBuffer.frameLength) * (outputFormat.sampleRate / inputBuffer.format.sampleRate)
        )

        guard let outputBuffer = AVAudioPCMBuffer(pcmFormat: outputFormat, frameCapacity: outputCapacity) else {
            print("❌ 无法创建输出缓冲区")
            return nil
        }

        var error: NSError?
        let status = converter.convert(to: outputBuffer, error: &error) { _, outStatus in
            outStatus.pointee = .haveData
            return inputBuffer
        }

        if status == .error {
            print("❌ 音频转换失败: \(error?.localizedDescription ?? "未知错误")")
            return nil
        }

        // 转换为 Data
        return toNSData(buffer: outputBuffer)
    }

    // 参考 UIKit 代码的数据转换方法
    private func toNSData(buffer: AVAudioPCMBuffer) -> Data? {
        let audioBuffer = buffer.audioBufferList.pointee.mBuffers
        return Data(
            bytes: audioBuffer.mData!,
            count: Int(audioBuffer.mDataByteSize)
        )
    }

    private func startFileRecording() throws {
        let documentsPath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        let audioFilename = documentsPath.appendingPathComponent(
            "recording_\(Date().timeIntervalSince1970).m4a"
        )

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]

        audioRecorder = try AVAudioRecorder(
            url: audioFilename,
            settings: settings
        )
        audioRecorder?.record()

        print("📁 文件录音已开始: \(audioFilename)")
    }

    func stopRecording() {
        // 停止音频引擎
        audioEngine?.stop()
        inputNode?.removeTap(onBus: 0)

        // 停止文件录音
        audioRecorder?.stop()

        // 断开 WebSocket 连接
        transcriptionManager.disconnect()

        isRecording = false

        do {
            try audioSession.setActive(false)
            print("✅ 录音和转录已停止")
        } catch {
            print("❌ 停止录音时出错: \(error.localizedDescription)")
        }
    }

    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
}
