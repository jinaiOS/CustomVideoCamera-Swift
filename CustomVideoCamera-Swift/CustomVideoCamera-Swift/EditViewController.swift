//
//  EditViewController.swift
//  CustomVideoCamera-Swift
//
//  Created by 김지은 on 2023/11/18.
//

import UIKit
import AVFoundation

class EditViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    func editVideo(at videoURL: URL, startTime: Double, endTime: Double, completion: @escaping (URL?, Error?) -> Void) {
        let asset = AVURLAsset(url: videoURL)
        let composition = AVMutableComposition() // 비디오 및 오디오를 조합하고 편집할 수 있는 프레임워크 클래스

        guard let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
              let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            completion(nil, NSError(domain: "com.example", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create composition tracks"]))
            return
        }

        do {
            let timeRange = CMTimeRange(start: CMTime(seconds: startTime, preferredTimescale: 1000),
                                        end: CMTime(seconds: endTime, preferredTimescale: 1000))
            
            try videoTrack.insertTimeRange(timeRange, of: asset.tracks(withMediaType: .video)[0], at: .zero)
            try audioTrack.insertTimeRange(timeRange, of: asset.tracks(withMediaType: .audio)[0], at: .zero)
        } catch {
            completion(nil, error)
            return
        }

        let fileManager = FileManager.default
        let outputURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("editedVideo.mp4")

        if fileManager.fileExists(atPath: outputURL.path) {
            try? fileManager.removeItem(at: outputURL)
        }

        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            completion(nil, NSError(domain: "com.example", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to create export session"]))
            return
        }

        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4

        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                completion(outputURL, nil)
            case .failed, .cancelled, .unknown, .waiting, .exporting:
                if let error = exportSession.error {
                    completion(nil, error)
                }
            @unknown default:
                break
            }
        }
    }

    func removeAudioFromVideo(videoURL: URL, completion: @escaping (URL?, Error?) -> Void) {
        let asset = AVURLAsset(url: videoURL)
        let composition = AVMutableComposition()

        guard let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            completion(nil, NSError(domain: "com.example", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create video track"]))
            return
        }

        do {
            try videoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: asset.duration),
                                           of: asset.tracks(withMediaType: .video)[0],
                                           at: .zero)
        } catch {
            completion(nil, error)
            return
        }

        // 오디오 트랙 제거
        asset.tracks(withMediaType: .audio).forEach { audioTrack in
            let compositionAudioTrack = composition.addMutableTrack(withMediaType: .audio,
                                                                    preferredTrackID: kCMPersistentTrackID_Invalid)
            do {
                try compositionAudioTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: asset.duration),
                                                          of: audioTrack,
                                                          at: .zero)
                composition.removeTrack(compositionAudioTrack!) // 오디오 트랙 제거
            } catch {
                completion(nil, error)
                return
            }
        }

        let outputURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("videoWithoutAudio.mp4")
        let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)

        exporter?.outputURL = outputURL
        exporter?.outputFileType = .mp4

        exporter?.exportAsynchronously {
            if let url = exporter?.outputURL, exporter?.status == .completed {
                completion(url, nil)
            } else if let error = exporter?.error {
                completion(nil, error)
            }
        }
    }
}
