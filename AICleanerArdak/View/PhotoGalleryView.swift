
import SwiftUI
import Photos

struct PhotoGalleryView: View {
    @ObservedObject var viewModel : PhotoGalleryViewModel
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    @Binding var selectedPhotos : Set<PHAsset>
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack(alignment: .bottom){
            Color(hex: "#0E0F10").ignoresSafeArea()
            VStack {
                // Header with "Select All" and "Deselect All"
                HStack {
                    Text("Gallery")
                        .font(.custom(FontExt.semiBold.rawValue, size: 18))
                        
                    Text("\(selectedPhotos.count)")
                        .font(.custom(FontExt.bold.rawValue, size: 14))
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.31))
                        .clipShape(Capsule())
                    Spacer()
                    Button {
                        if selectedPhotos.isEmpty{
                            selectedPhotos = Set(viewModel.photoAssets)
                        } else {
                            selectedPhotos = []
                        }
                    } label: {
                        Text(selectedPhotos.isEmpty ? "Select all" : "Deselect all")
                            .font(.custom(FontExt.reg.rawValue, size: 15))
                            .foregroundStyle(Color(hex: "#0D65E0"))
                    }
                }
                .foregroundStyle(.white)
                .padding(.vertical)
                // Photo Gallery
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(viewModel.photoAssets, id: \.self) { asset in
                            PhotoGridItem(asset: asset, isSelected: selectedPhotos.contains(asset))
                                .onTapGesture {
                                    if selectedPhotos.contains(asset) {
                                        selectedPhotos.remove(asset)
                                    } else {
                                        selectedPhotos.insert(asset)
                                    }
                                }
                        }
                    }
                }
            }
            .padding()
            
            Button{
                dismiss()
            } label: {
                HStack{
                    Text("Add to private")
                }
                .foregroundStyle(.white)
                .font(.custom(FontExt.bold.rawValue, size: 15))
                .frame(width: 299, height: 60)
                .background(Color(hex: "#0D65E0"))
                .clipShape(RoundedRectangle(cornerRadius: 100))
                .offset(y: selectedPhotos.isEmpty ? 300 : 0)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: selectedPhotos)
        
    }
}

struct PhotoGridItem: View {
    let asset: PHAsset
    let isSelected: Bool
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let image = asset.toUIImage() {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 168, height: 281)
                    .clipped()
            } else {
                Color.gray
                    .frame(width: 168, height: 281)
            }
            ZStack{
                if isSelected {
                    Circle().fill(Color(hex: "#0D65E0"))
                    Image(systemName: "checkmark")
                        .resizable()
                        .frame(width: 13, height: 13)
                        .foregroundStyle(.white)
                } else {
                    Circle().stroke(Color.white, lineWidth: 2)
                }
            }
            .frame(width: 23, height: 23)
            .padding([.trailing, .top])
        }
    }
}


#Preview {
    PhotoGalleryView(viewModel: PhotoGalleryViewModel(), selectedPhotos: .constant([]))
}
