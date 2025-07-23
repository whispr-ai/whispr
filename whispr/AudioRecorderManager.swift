//
//  AudioRecorderManager.swift
//  whispr
//
//  Created by 刘沛强 on 2025/7/24.
//

import AVFoundation
import Foundation
import SwiftUI

class AudioRecorderManager: ObservableObject {
    @Published var isRecording = false
    @Published var hasPermission = false
    @Published var permissionStatus: String = "未知"

    private var audioRecorder: AVAudioRecorder?
    private let audioSession = AVAudioSession.sharedInstance()

    init() {
        checkPermissionStatus()
    }

    func checkPermissionStatus() {
        switch AVAudioApplication.shared.recordPermission {
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
        AVAudioApplication.requestRecordPermission(completionHandler: {
            [weak self] granted in
            DispatchQueue.main.async {
                self?.hasPermission = granted
                self?.permissionStatus = granted ? "已授权" : "已拒绝"
                // 权限变更后重新检查状态
                self?.checkPermissionStatus()
            }
        })
    }

    func startRecording() {
        guard hasPermission else {
            requestPermission()
            return
        }

        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)

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

            isRecording = true
            print("开始录音，文件路径: \(audioFilename)")

        } catch {
            print("录音失败: \(error.localizedDescription)")
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false

        do {
            try audioSession.setActive(false)
            print("录音已停止")
        } catch {
            print("停止录音时出错: \(error.localizedDescription)")
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
