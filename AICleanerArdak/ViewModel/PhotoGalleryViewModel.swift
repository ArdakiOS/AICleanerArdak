

import SwiftUI
import Photos
import UIKit

class PhotoGalleryViewModel: ObservableObject {
    @Published var photoAssets: [PHAsset] = []
    @Published var selectedPhotos: Set<PHAsset> = []
    @Published var videoAssets: [PHAsset] = []
    @Published var allAssets : [PHAsset] = []

    init() {
        fetchPhotos()
    }

    func fetchPhotos() {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                let allVideos = PHAsset.fetchAssets(with: .video, options: fetchOptions)
                
                
                var photoAssets: [PHAsset] = []
                allPhotos.enumerateObjects { asset, _, _ in
                    photoAssets.append(asset)
                }
                
                var videoAssets: [PHAsset] = []
                allVideos.enumerateObjects { asset, _, _ in
                    videoAssets.append(asset)
                }

                DispatchQueue.main.async {
                    self.photoAssets = photoAssets
                    self.videoAssets = videoAssets
                    self.allAssets = photoAssets + videoAssets
                }
            }
        }
    }

    func toggleSelection(for asset: PHAsset) {
        if selectedPhotos.contains(asset) {
            selectedPhotos.remove(asset)
        } else {
            selectedPhotos.insert(asset)
        }
    }

    func selectAll() {
        selectedPhotos = Set(photoAssets)
    }

    func deselectAll() {
        selectedPhotos.removeAll()
    }
}


extension PHAsset {
    func toUIImage(targetSize: CGSize = CGSize(width: 150, height: 150)) -> UIImage? {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat

        var thumbnail: UIImage?
        PHImageManager.default().requestImage(
            for: self,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            thumbnail = image
        }
        return thumbnail
    }
}
