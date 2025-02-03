
struct AssetImagePair : Hashable {
    let duplicates : PHAsset
    let duplicatesImg : UIImage
}

struct Album : Hashable {
    let name : String
    var assets : [AssetImagePair]
    let count : Int
    let size : Int64
}

import SwiftUI
import Photos
import UIKit

class PhotoGalleryViewModel: ObservableObject {
    var photoAssets: [PHAsset] = []
    @Published var selectedPhotos: Set<PHAsset> = []
    var videoAssets: [PHAsset] = []
    var allAssets : [PHAsset] = []
    @Published var shouldRequestAccess = false
    
    @Published var assetsByAlbums : [Album] = []
    
    @Published var duplicatePhotos : [AssetImagePair] = []
    @Published var duplicateVideos : [AssetImagePair] = []
    
    @Published var totalSizeOfDuplicatePhotos : Int64 = 0
    @Published var totalSizeOfDuplicateVideos : Int64 = 0
    
    var uniqueAssetIdentifiers: Set<String> = []
    @Published var finishedLoadingAlbums = false
    
    @Published var selectedAlbum : Album?
    
    @Published var deletionSuccessful = false
    
    
    init() {
        checkPhotoLibraryAuthorization()
    }
    
    func checkPhotoLibraryAuthorization() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            // Access already granted
            shouldRequestAccess = false
            Task{
                await fetchAlbumNames()
            }
            
        case .denied, .restricted, .notDetermined:
            // Show the button to request access
            shouldRequestAccess = true
        @unknown default:
            shouldRequestAccess = true
        }
    }
    
    @MainActor
    func fetchAlbumNames() async {
        // Fetch all albums (user-created albums + system albums)
        let allAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        
        var combinedAlbums: [PHAssetCollection] = [] // Change Set to Array

        allAlbums.enumerateObjects { collection, _, _ in
            combinedAlbums.append(collection)
        }

        smartAlbums.enumerateObjects { collection, _, _ in
            combinedAlbums.append(collection)
        }

        combinedAlbums.sort { (album1, album2) -> Bool in
            if album1.assetCollectionSubtype == .smartAlbumUserLibrary {
                return false // Ensure "Recents" stays last
            } else if album2.assetCollectionSubtype == .smartAlbumUserLibrary {
                return true  // Move other albums before "Recents"
            }
            return album1.localizedTitle ?? "" < album2.localizedTitle ?? "" // Sort alphabetically
        }

        
        for album in combinedAlbums {
            await fetchAssets(from: album)
        }
        
        print(self.photoAssets.count)
        
        await self.findPhotoDuplicates()
        await self.findVideoDuplicates()
        
        
        
    }
    
    func requestPermission() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async { [weak self] in
                if status == .authorized || status == .limited {
                    self?.shouldRequestAccess = false
                    Task{
                        await self?.fetchAlbumNames()
                    }
                } else {
                    self?.shouldRequestAccess = true
                }
            }
        }
    }
    
    func fetchAssets(from album : PHAssetCollection) async {
        print("fetchPhotos: \(album.localizedTitle ?? "1")")
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let assets = PHAsset.fetchAssets(in: album, options: fetchOptions)
        var assetsInAlbum: [AssetImagePair] = []
        var count = 0
        var size : Int64 = 0
        
        assets.enumerateObjects { asset, _, _ in
            
            // Check if the asset is unique
            if self.uniqueAssetIdentifiers.insert(asset.localIdentifier).inserted {
                // Add to the album's asset list
                if let img = asset.toUIImage(){
                    let pair = AssetImagePair(duplicates: asset, duplicatesImg:img)
                    assetsInAlbum.append(pair)
                }
                
                // Separate into photo and video arrays
                if asset.mediaType == .image {
                    self.photoAssets.append(asset)
                } else if asset.mediaType == .video {
                    self.videoAssets.append(asset)
                }
                
                self.allAssets.append(asset)
                count += 1
                size += asset.fileSize()
            }
        }
        
        // Add the album and its assets to the dictionary
        if !assetsInAlbum.isEmpty {
            DispatchQueue.main.async {[weak self] in
                let album = Album(name: album.localizedTitle ?? "Unknown", assets: assetsInAlbum, count: count, size: size)
                self?.assetsByAlbums.append(album)
            }
            
        }
        
        
    }
    
    func findPhotoDuplicates() async {
        print("Started duplicates")
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                
                var lastAsset: PHAsset? = nil
                var lastAssetMetadata: (fileSize: Int64, dimensions: CGSize, creationTime: Date, location: CLLocation?)? = nil
                var duplicatesForLastAsset: [PHAsset] = []
                var duplicates: [AssetImagePair] = [] // Temporary storage
                
                
                var totalSize : Int64 = 0
                for asset in self.photoAssets {

                    // Skip non-user-library assets
                    guard asset.sourceType.contains(.typeUserLibrary) else { continue }
                    guard asset.mediaType == .image else {continue}
                    // Extract metadata
                    let fileSize = asset.fileSize()
                    let dimensions = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
                    let creationTime = asset.creationDate ?? Date.distantPast
                    let location = asset.location
                    
                    // Compare with the last asset
                    if let lastAsset = lastAsset, let lastMetadata = lastAssetMetadata {
                        let timeDifference = abs(creationTime.timeIntervalSince(lastMetadata.creationTime))
                        let sizeDifference = abs(fileSize - lastMetadata.fileSize)
                        
                        if timeDifference <= 2.0,  // Creation time within 2 seconds
                           sizeDifference <= 500_000,  // File size difference <= 0.5 MB
                           dimensions == lastMetadata.dimensions,  // Dimensions are identical
                           (location == nil && lastMetadata.location == nil || location?.distance(from: lastMetadata.location ?? CLLocation()) ?? 0 <= 10) { // Same location within 10 meters
                            
                            duplicatesForLastAsset.append(asset) // Add to duplicates
                            totalSize += fileSize
                            continue
                        }
                    }
                    
                    // Save duplicates if any
                    if !duplicatesForLastAsset.isEmpty, let lastAsset = lastAsset {
                        for i in duplicatesForLastAsset {
                            if let img = i.toUIImage(){
                                duplicates.append(AssetImagePair(duplicates: i, duplicatesImg: img))
                            }
                        }
                        if let orig = lastAsset.toUIImage(){
                            duplicates.append(AssetImagePair(duplicates: lastAsset, duplicatesImg: orig))
                            totalSize += lastAsset.fileSize()
                        }
                        duplicatesForLastAsset = [] // Reset duplicates
                    }
                    
                    // Update last asset and metadata
                    lastAsset = asset
                    lastAssetMetadata = (fileSize, dimensions, creationTime, location)
                }
                
                // Add remaining duplicates
                if let lastAsset = lastAsset, !duplicatesForLastAsset.isEmpty {
                    for i in duplicatesForLastAsset {
                        if let img = i.toUIImage(){
                            duplicates.append(AssetImagePair(duplicates: i, duplicatesImg: img))
                        }
                    }
                    
                    if let orig = lastAsset.toUIImage(){
                        duplicates.append(AssetImagePair(duplicates: lastAsset, duplicatesImg: orig))
                        totalSize += lastAsset.fileSize()
                    }
                    
                }
                
                // Update the main thread with results
                DispatchQueue.main.async {
                    self.duplicatePhotos = duplicates
                    self.totalSizeOfDuplicatePhotos = totalSize
                    continuation.resume() // Signal completion
                }
            }
        }
    }
    
    func findVideoDuplicates() async {
        print("Started finding video duplicates")
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }

                var lastAsset: PHAsset? = nil
                var lastAssetMetadata: (fileSize: Int64, duration: TimeInterval, creationTime: Date, location: CLLocation?)? = nil
                var duplicatesForLastAsset: [PHAsset] = []
                var duplicates: [AssetImagePair] = [] // Temporary storage
                var totalSize : Int64 = 0
                for asset in self.videoAssets {
                    // Skip non-user-library assets
                    guard asset.sourceType.contains(.typeUserLibrary) else { continue }
                    guard asset.mediaType == .video else { continue }

                    // Extract metadata
                    let fileSize = asset.fileSize()
                    let duration = asset.duration
                    let creationTime = asset.creationDate ?? Date.distantPast
                    let location = asset.location

                    // Compare with the last asset
                    if lastAsset != nil, let lastMetadata = lastAssetMetadata {
                        let timeDifference = abs(creationTime.timeIntervalSince(lastMetadata.creationTime))
                        let sizeDifference = abs(fileSize - lastMetadata.fileSize)
                        let durationDifference = abs(duration - lastMetadata.duration)

                        if timeDifference <= 2.0,  // Creation time within 2 seconds
                           sizeDifference <= 1_000_000,  // File size difference <= 1 MB
                           durationDifference <= 1.0,  // Duration difference within 1 second
                           (location == nil && lastMetadata.location == nil || location?.distance(from: lastMetadata.location ?? CLLocation()) ?? 0 <= 10) { // Same location within 10 meters

                            duplicatesForLastAsset.append(asset) // Add to duplicates
                            totalSize += fileSize
                            continue
                        }
                    }

                    // Save duplicates if any
                    if !duplicatesForLastAsset.isEmpty, let lastAsset = lastAsset {
                        for duplicate in duplicatesForLastAsset {
                            if let img = duplicate.toUIImage() { // Generate preview
                                duplicates.append(AssetImagePair(duplicates: duplicate, duplicatesImg: img))
                            }
                        }
                        if let orig = lastAsset.toUIImage(){
                            duplicates.append(AssetImagePair(duplicates: lastAsset, duplicatesImg: orig))
                            totalSize += lastAsset.fileSize()
                        }
                        duplicatesForLastAsset = [] // Reset duplicates
                    }

                    // Update last asset and metadata
                    lastAsset = asset
                    lastAssetMetadata = (fileSize, duration, creationTime, location)
                }

                // Add remaining duplicates
                if let lastAsset = lastAsset, !duplicatesForLastAsset.isEmpty {
                    for duplicate in duplicatesForLastAsset {
                        if let img = duplicate.toUIImage() {
                            duplicates.append(AssetImagePair(duplicates: duplicate, duplicatesImg: img))
                        }
                    }
                    if let orig = lastAsset.toUIImage(){
                        duplicates.append(AssetImagePair(duplicates: lastAsset, duplicatesImg: orig))
                        totalSize += lastAsset.fileSize()
                    }
                }

                // Update the main thread with results
                DispatchQueue.main.async {
                    self.duplicateVideos = duplicates
                    self.totalSizeOfDuplicateVideos = totalSize
                    continuation.resume() // Signal completion
                }
            }
        }
    }

    func deleteImgs(imgs : [AssetImagePair]) {
        guard let selectedAlbum = selectedAlbum else {return}
        guard let idOfAlbum = assetsByAlbums.firstIndex(of: selectedAlbum) else {return}
        var idsOfImgs : [Int] = []
        for i in imgs {
            if let idx = assetsByAlbums[idOfAlbum].assets.firstIndex(of: i){
                idsOfImgs.append(idx)
            }
        }
        let phAssetsArray = imgs.map{$0.duplicates}
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets(phAssetsArray as NSArray)
        } completionHandler: { suc, error in
            if suc {
                print("suc")
                DispatchQueue.main.async {
                    self.deletionSuccessful = true
                }
                for i in idsOfImgs {
                    DispatchQueue.main.async {
                        self.assetsByAlbums[idOfAlbum].assets.remove(at: i)
                    }
                }
            } else {
                print(error ?? "Unknown error")
            }
        }
    }
    
    func deleteDuplicates(assets : [AssetImagePair], from : String){
        var ids : [Int] = []
        if from == "photo"{
            guard !duplicatePhotos.isEmpty else {return}
            for i in assets{
                if let idx = duplicatePhotos.firstIndex(of: i){
                    ids.append(idx)
                }
            }
        } else {
            guard !duplicateVideos.isEmpty else {return}
            for i in assets{
                if let idx = duplicateVideos.firstIndex(of: i){
                    ids.append(idx)
                }
            }
        }
        let phAssetsArray = assets.map{$0.duplicates}
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets(phAssetsArray as NSArray)
        } completionHandler: { suc, error in
            if suc {
                print("suc")
                self.deletionSuccessful = true
                if from == "photo"{
                    for i in ids {
                        self.duplicatePhotos.remove(at: i)
                    }
                } else {
                    for i in ids {
                        self.duplicateVideos.remove(at: i)
                    }
                }
            } else {
                print(error ?? "Unknown error")
            }
        }
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
    
    func fileSize() -> Int64 {
        let resource = PHAssetResource.assetResources(for: self).first
        return resource?.value(forKey: "fileSize") as? Int64 ?? 0
    }
}
