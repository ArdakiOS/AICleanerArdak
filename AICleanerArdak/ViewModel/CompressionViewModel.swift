//
//  File.swift
//  AICleanerArdak
//
//  Created by Ardak Tursunbayev on 16.01.2025.
//

import SwiftUI
import Photos

enum Qualities : CaseIterable{
    case low, medium, high
    
    func displayName() -> String{
        switch self {
        case .low:
            "Low"
        case .medium:
            "Medium"
        case .high:
            "High"
        }
    }
    
    func preset() -> String{
        switch self {
        case .low:
            return "AVAssetExportPresetLowQuality"
        case .medium:
            return "AVAssetExportPresetMediumQuality"
        case .high:
            return "AVAssetExportPreset960x540"
            
        }
    }
}

enum CompressionStates {
    case config, inProgress, finished
}

struct CompressionModel : Hashable {
    let asset : PHAsset
    let assetImg : UIImage
    let name : String
    let fileSize : Int64
}

class CompressionViewModel : ObservableObject {
    @Published var assets : [CompressionModel] = []
    @Published var totalVideosSize : Int64 = 0
    
    @Published var estimatedSizeReduction : Int64 = 0
    @Published var actualNewSize : Int64 = 0
    @Published var selectedVideoToEdit : CompressionModel? {
        didSet {
            if selectedVideoToEdit != nil {
                openEditor = true
            }
        }
    }
    @Published var disableQualitySelection = false
    @Published var openEditor = false
    
    @Published var compressionState = CompressionStates.config
    
    
    func prepareAssetToDisplay(videoAssets : [PHAsset]) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            for i in videoAssets {
                if self.assets.contains(where: {$0.asset.localIdentifier == i.localIdentifier}){
                    continue
                }
                if let img = i.toUIImage() {
                    let resources = PHAssetResource.assetResources(for: i)
                    if let resource = resources.first {
                        let size = i.fileSize()
                        let originalFilename = resource.originalFilename
                        
                        // Get filename without extension
                        let filenameWithoutExtension = (originalFilename as NSString).deletingPathExtension
                        
                        let newEntry = CompressionModel(asset: i, assetImg: img, name: filenameWithoutExtension, fileSize: size)
                        DispatchQueue.main.async {
                            self.assets.append(newEntry)
                            self.totalVideosSize += size
                        }
                    }
                }
            }
            
        }
    }
    
    func compressVideo(quality : Qualities) {
        compressionState = .inProgress
        guard let video = selectedVideoToEdit else { return }

        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true

        PHImageManager.default().requestAVAsset(forVideo: video.asset, options: options) { avAsset, _, _ in
            guard let asset = avAsset else {
                print("Failed to get AVAsset")
                return
            }

            guard let videoTrack = asset.tracks(withMediaType: .video).first else {
                print("Could not retrieve video track")
                return
            }

            var preset = quality.preset()

            let exportSession = AVAssetExportSession(asset: asset, presetName: preset)

            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let compressedVideoURL = documentsPath.appendingPathComponent("compressedVideo.mp4")

            if FileManager.default.fileExists(atPath: compressedVideoURL.path) {
                try? FileManager.default.removeItem(at: compressedVideoURL)
            }

            exportSession?.outputURL = compressedVideoURL
            exportSession?.outputFileType = .mov // or kUTTypeMPEG4 if you want .mp4
            exportSession?.shouldOptimizeForNetworkUse = true

            exportSession?.exportAsynchronously {
                guard exportSession?.status == .completed else {
                    print("Failed to export video: \(exportSession?.error?.localizedDescription ?? "Unknown error")")
                    return
                }
                DispatchQueue.main.async {
                    self.actualNewSize = self.getFileSize(url: compressedVideoURL)
                }
                
                // Save the compressed video to the Photos library
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: compressedVideoURL)
                } completionHandler: { success, error in
                    if success {
                        print("Compressed video saved to Photos library.")
                        DispatchQueue.main.async {
                            self.compressionState = .finished
                        }
                        
                    } else {
                        print("Failed to save video to Photos library: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
        }
    }

    func estimateCompressedFileSize(quality : Qualities) {
        
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        guard let selectedVideoToEdit = selectedVideoToEdit else {return}
        
        PHImageManager.default().requestAVAsset(forVideo: selectedVideoToEdit.asset, options: options) { avAsset, _, _ in
            guard let asset = avAsset else {
                print("Failed to get AVAsset")
                return
            }
            let duration = CMTimeGetSeconds(asset.duration) // Get video duration in seconds
            var bitrate: Double = 0 // Bitrate in bits per second
            guard let asset = avAsset else {
                print("Failed to get AVAsset")
                return
            }
            
            guard let videoTrack = asset.tracks(withMediaType: .video).first else {
                print("Could not retrieve video track")
                return
            }
            
            
            
            let preset = quality.preset()

            switch preset {
            case AVAssetExportPresetLowQuality:
                bitrate = 500_000 // 500 kbps
            case AVAssetExportPresetMediumQuality:
                bitrate = 2_000_000 // 2 Mbps
            case AVAssetExportPreset960x540:
                bitrate = 5_000_000 // 8 Mbps
            default:
                bitrate = 2_000_000 // Default to 2 Mbps
            }

            DispatchQueue.main.async {
                self.estimatedSizeReduction = Int64((bitrate * duration) / 8)
            }
            
            
        }
        
        
    }
    
    private func getFileSize(url: URL) -> Int64 {
        do {
            let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey])
            if let fileSize = resourceValues.fileSize {
                return Int64(fileSize)
            }
        } catch {
            print("Error retrieving file size: \(error.localizedDescription)")
        }
        return Int64(0.0)
    }
}
