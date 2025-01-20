//
//  File.swift
//  AICleanerArdak
//
//  Created by Ardak Tursunbayev on 16.01.2025.
//

import Foundation
import Photos



class CompressionViewModel : ObservableObject {
    @Published var photoLibIsOpen = false
    @Published var selectedVideos : Set<PHAsset> = []
    @Published var savedVideos: [PhotoDetails] = []
    @Published var videoToAsset : [PhotoDetails : PHAsset] = [:]
    @Published var isUploading = false
    @Published var isCompressing = false
    
    @Published var estimatedSizeReduction = 0.0
    @Published var selectedVideoToEdit : PhotoDetails? {
        didSet {
            if selectedVideoToEdit != nil {
                openEditor = true
            }
        }
    }
    @Published var disableQualitySelection = false
    @Published var openEditor = false
    func prepareAssetToDisplay() {
        isUploading = true
        for i in selectedVideos {
            getAssetDetails(asset: i) { name, size in
                if let name = name, let size = size {
                    let newEntry = PhotoDetails(image: i.toUIImage()!, sizeInMB: size, name: name)
                    DispatchQueue.main.async {
                        self.savedVideos.append(newEntry)
                        self.videoToAsset[newEntry] = i
                    }
                }
            }
        }
        isUploading = false
    }
    
    func getAssetDetails(asset: PHAsset, completion: @escaping (String?, Double?) -> Void) {
        if let resource = PHAssetResource.assetResources(for: asset).first {
            let fileName = resource.originalFilename
            let options = PHAssetResourceRequestOptions()
            options.isNetworkAccessAllowed = true
            
            let fileManager = FileManager.default
            let tempURL = fileManager.temporaryDirectory.appendingPathComponent(fileName)
            
            PHAssetResourceManager.default().writeData(for: resource, toFile: tempURL, options: options) { error in
                if error == nil {
                    var fileSizeMB: Double?
                    if let attributes = try? fileManager.attributesOfItem(atPath: tempURL.path),
                       let size = attributes[.size] as? Int64 {
                        fileSizeMB = Double(size) / 1_048_576.0 // Convert bytes to MB
                    }
                    try? fileManager.removeItem(at: tempURL) // Clean up temp file
                    completion(fileName, fileSizeMB)
                } else {
                    completion(fileName, nil) // Return file name but no size if error occurs
                }
            }
        } else {
            completion(nil, nil) // No resource found
        }
    }
    
    func compressVideo(quality : Qualities) {
        guard let video = selectedVideoToEdit else { return }
        guard let asset = videoToAsset[video] else { return }

        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true

        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { avAsset, _, _ in
            guard let asset = avAsset else {
                print("Failed to get AVAsset")
                return
            }

            guard let videoTrack = asset.tracks(withMediaType: .video).first else {
                print("Could not retrieve video track")
                return
            }

            let videoSize = videoTrack.naturalSize // This is the original size
            var preset = ""
            switch quality {
            case .low:
                preset = "AVAssetExportPresetLowQuality"
            case .medium:
                preset = "AVAssetExportPresetMediumQuality"
            case .high:
                let size = videoSize.width * videoSize.height
                if size <= 640 * 480{
                    preset = "AVAssetExportPresetPassthrough"
                }
                else if size <= 960 * 540 {
                    preset = "AVAssetExportPreset640x480"
                }
                else if size <= 1280 * 720 {
                    preset = "AVAssetExportPreset960x540"
                }
                else if size <= 1920 * 1080 {
                    preset = "AVAssetExportPreset1280x720"
                }
                else if size <= 3840 * 2160 {
                    preset = "AVAssetExportPreset640x480"
                }
            }
            print("Original Video Size: \(videoSize)") // Print the size

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

                // Save the compressed video to the Photos library
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: compressedVideoURL)
                } completionHandler: { success, error in
                    if success {
                        print("Compressed video saved to Photos library.")
                    } else {
                        print("Failed to save video to Photos library: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
        }
    }

    
}
