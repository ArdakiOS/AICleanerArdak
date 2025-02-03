
import SwiftUI
import Photos

enum PrivacyStates {
    case firstCreatePin, firstRepeatPin, secondRepeatPin, secondCreatePin, enterExistingPin, view
}

class PrivacyViewModel: ObservableObject {
    @Published var pin: [String] = ["", "", "", ""]
    
    @Published var confirmPin: [String] = ["", "", "", ""]
    
    @Published var secondRepeatPin : [String] = ["", "", "", ""]
    
    @Published var pageState = PrivacyStates.firstCreatePin
    
    @Published var repeatPinWrong = false
    @Published var photoLibPresented = false
    
    @Published var selectedPhotos: [PHAsset] = []
    @Published var savedPhotos: [PhotoDetails] = []
    @Published var savedVideos : [PhotoDetails] = []
    @Published var uploading = false
    
    @AppStorage("photoCount") var photoCount = 0
    @AppStorage("videoCount") var videoCount = 0
    

    init() {
        if UserDefaults.standard.bool(forKey: "usePin"){
            if let savedPin = UserDefaults.standard.string(forKey: "privacyPin") {
                self.pin = Array(savedPin).map { String($0) }
                pageState = .enterExistingPin
                self.loadSavedPhotosFromLocalStorage()
            }
        } else {
            pageState = .view
            self.loadSavedPhotosFromLocalStorage()
        }
    }
    
    func savePin() {
        let pinString = pin.joined()
        UserDefaults.standard.set(pinString, forKey: "privacyPin")
    }
    
    func isPinSet() {
        let joinedPin = pin.joined()
        if joinedPin.count == 4 {
            pageState = .firstRepeatPin
        }
    }
    
    func isPinTheSame(){
        if confirmPin.joined().count == 4 && pin.joined() == confirmPin.joined(){
            savePin()
            pageState = .view
        }
    }
    
    func copySelectedPhotosToLocalStorage() {
        guard !selectedPhotos.isEmpty else { return }
        uploading = true

        let options = PHImageRequestOptions()
        options.isSynchronous = false  // ✅ Use async requests to avoid blocking the UI
        options.isNetworkAccessAllowed = true  // ✅ Allows downloading from iCloud if needed
        options.deliveryMode = .highQualityFormat  // ✅ Ensures full-quality images

        for asset in selectedPhotos {
            switch asset.mediaType {
            case .unknown:
                continue
            case .image:
                photoCount += 1
            case .video:
                videoCount += 1
            case .audio:
                continue
            }
            
            PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { data, _, _, error in
                if let data = data {
                    self.saveImageDataToDocuments(data: data, asset: asset)
                } else {
                    DispatchQueue.main.async {
                        self.uploading = false
                    }
                }
            }
        }
    }

    
    private func saveImageDataToDocuments(data: Data, asset: PHAsset) {
        let fileManager = FileManager.default
        
        // Create a filename based on asset creation date or fallback
        let filename = (asset.creationDate?.description ?? UUID().uuidString) + ".jpg"
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
            print("Photo saved to: \(fileURL.path)")
            loadSavedPhotosFromLocalStorage()
        } catch {
            print("Error saving photo: \(error)")
        }
    }

    func loadSavedPhotosFromLocalStorage() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!

        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)

            // Filter for image files (optional, based on file extension)
            let imageURLs = fileURLs.filter { $0.pathExtension.lowercased() == "jpg" || $0.pathExtension.lowercased() == "png" }

            
            // Load image details
            savedPhotos = imageURLs.compactMap { url in
                guard let data = try? Data(contentsOf: url),
                      let image = UIImage(data: data) else { return nil }

                var name = url.lastPathComponent
                let filenameWithoutExtension = (name as NSString).deletingPathExtension
                let sizeInBytes = Double(data.count)
                let sizeInMB = sizeInBytes / (1024.0 * 1024.0)

                return PhotoDetails(image: image, sizeInMB: sizeInMB, name: filenameWithoutExtension)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                self.uploading = false
            }
        } catch {
            print("Error loading photos: \(error)")
        }
        
    }


}
