
import SwiftUI

struct AllFilesView: View {
    @EnvironmentObject var photoVM : PhotoGalleryViewModel
    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    @State var openCategory = false
    @EnvironmentObject var subVM : SubscriptionsManager
    var body: some View {
        ZStack{
            Color(hex: "#0E0F10").ignoresSafeArea()
            VStack(spacing: 20){
                PremiumBanner()
                
                HStack{
                    Text("\(photoVM.allAssets.count) files")
                        .foregroundStyle(.white.opacity(0.47))
                        .font(.custom(FontExt.reg.rawValue, size: 14))
                    
                    Rectangle().frame(width: 1, height: 19)
                        .foregroundStyle(.white.opacity(0.47))
                    
                    Text("\(formatBytes(photoVM.totalSizeOfDuplicatePhotos + photoVM.totalSizeOfDuplicateVideos)) to clean up")
                        .foregroundStyle(.white)
                        .font(.custom(FontExt.med.rawValue, size: 14))
                }
                .padding()
                .frame(height: 44)
                .background(Color(hex: "#181818"))
                .clipShape(RoundedRectangle(cornerRadius: 31))
                .frame(maxWidth: .infinity, alignment: .leading)
                
                
                VStack{
                    if photoVM.shouldRequestAccess {
                        VStack{
                            Spacer()
                            Button{
                                photoVM.requestPermission()
                            } label: {
                                HStack{
                                    Text("Allow's gallery")
                                }
                                .foregroundStyle(.white)
                                .font(.custom(FontExt.bold.rawValue, size: 15))
                                .frame(width: 242, height: 54)
                                .background(Color(hex: "#0D65E0"))
                                .clipShape(RoundedRectangle(cornerRadius: 100))
                            }
                            Spacer()
                        }
                    } else {
                        if !photoVM.assetsByAlbums.isEmpty{
                            VStack(alignment: .leading){
                                if !photoVM.duplicateVideos.isEmpty || !photoVM.duplicatePhotos.isEmpty{
                                    VStack(alignment: .leading){
                                        Text("AI sorting")
                                            .font(.custom(FontExt.semiBold.rawValue, size: 18))
                                            .foregroundStyle(.white)
                                        ScrollView(.horizontal) {
                                            HStack{
                                                if !photoVM.duplicatePhotos.isEmpty{
                                                    NavigationLink {
                                                        DuplicatePhotosFullView(vm : photoVM)
                                                            .navigationBarBackButtonHidden()
                                                    } label: {
                                                        DuplicateButton(name: "Duplicate Photo", count: photoVM.duplicatePhotos.count, photoVideo: "photos")
                                                    }
                                                }
                                                
                                                if !photoVM.duplicateVideos.isEmpty{
                                                    NavigationLink {
                                                        DuplicateVideoFullView(vm : photoVM)
                                                            .navigationBarBackButtonHidden()
                                                    } label: {
                                                        DuplicateButton(name: "Duplicate Video", count: photoVM.duplicateVideos.count, photoVideo: "videos")
                                                    }
                                                }
                                            }
                                        }
                                        
                                    }
                                }
                                VStack(alignment: .leading){
                                    Text("All files")
                                        .font(.custom(FontExt.semiBold.rawValue, size: 18))
                                        .foregroundStyle(.white)
                                        
                                    ScrollView(.vertical) {
                                        LazyVGrid(columns: columns, spacing: 20) {
                                            ForEach(Array(photoVM.assetsByAlbums), id: \.self){album in
                                                PhotoCategoryView(album: album)
                                                    .onTapGesture{
                                                        photoVM.selectedAlbum = album
                                                        openCategory = true
                                                    }
                                                    .sheet(isPresented: $openCategory) {
                                                        AllFilesGalleryView(vm: photoVM)
                                                            .presentationCornerRadius(20)
                                                            .presentationDetents([.fraction(0.9), .fraction(1.0)])
                                                            .presentationDragIndicator(.visible)
                                                    }
                                            }
                                        }
                                    }
                                }
                                
                            }
                        } else {
                            VStack{
                                Spacer()
                                ProgressView()
                                    .frame(width: 120, height: 120)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    NavView(curPage: .allFiles)
        .environmentObject(EntitlementManager())
        .environmentObject(SubscriptionsManager(entitlementManager: EntitlementManager()))
//    DuplicateButton(name: "Duplicate photos", count: 132, photoVideo: "photos")
}

struct DuplicateButton : View {
    let name : String
    let count : Int
    let photoVideo : String
    var body: some View {
            HStack{
                VStack(alignment: .leading, spacing: 10){
                    Text(name)
                        .font(.custom(FontExt.semiBold.rawValue, size: 14))
                        .foregroundStyle(.white)
                    Text("\(count) \(photoVideo)")
                        .font(.custom(FontExt.reg.rawValue, size: 14))
                        .foregroundStyle(.white.opacity(0.47))
                }
                Spacer()
                ZStack{
                    RoundedRectangle(cornerRadius: 30).fill(.white)
                        .frame(width: 46, height: 32)
                    Image(systemName: "chevron.right")
                        .resizable()
                        .frame(width: 8, height: 12)
                        .bold()
                        .foregroundStyle(.black)
                }
            }
            .padding()
            .frame(width: 218, height: 70)
            .background(Color(hex: "#181818"))
            .clipShape(RoundedRectangle(cornerRadius: 19))
    }
}

struct PhotoCategoryView : View {
    @State var album : Album
    var body: some View {
        ZStack{
            Color(hex: "#181818")
            VStack{
                ZStack{
                    if album.assets.count > 2{
                        Image(uiImage: album.assets[0].duplicatesImg)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 57, height: 90)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        
                        Image(uiImage: album.assets[1].duplicatesImg)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 57, height: 90)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    VisualEffectView(effect: UIBlurEffect(style: .regular))
                        .frame(width: 47, height: 26)
                        .cornerRadius(100)
                        .opacity(0.7)
                    Text("+\(abs(album.assets.count - 2))")
                        .font(.custom(FontExt.bold.rawValue, size: 13))
                        .foregroundStyle(.white)
                        .frame(width: 47, height: 26)
                        .clipShape(RoundedRectangle(cornerRadius: 100))
                }
                .frame(width: 90, height: 90)
                .padding(.bottom, 5)
                
                Text(album.name)
                    .font(.custom(FontExt.semiBold.rawValue, size: 14))
                    .foregroundStyle(.white)
                
                Text("\(album.assets.count) photos")
                    .font(.custom(FontExt.reg.rawValue, size: 14))
                    .foregroundStyle(.white.opacity(0.47))
                    .padding(.bottom, 5)
                
                HStack{
                    Text(formatBytes(album.size))
                        .font(.custom(FontExt.bold.rawValue, size: 15))
                    Image(systemName: "chevron.right")
                        .resizable()
                        .frame(width: 8, height: 12)
                        .bold()
                }
                .frame(width: 132, height: 39)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .foregroundStyle(.black)
                
            }
        }
        .frame(width: 167, height: 221)
        .clipShape(RoundedRectangle(cornerRadius: 19))
    }
    
    
}

func formatBytes(_ bytes: Int64) -> String {
    if bytes == 0{
        return "0 KB"
    }
    let formatter = ByteCountFormatter()
    formatter.allowedUnits = [.useKB, .useMB, .useGB] // Limit to KB, MB, and GB
    formatter.countStyle = .file // Use file size formatting
    formatter.includesUnit = true // Include the unit (e.g., "MB")
    return formatter.string(fromByteCount: bytes)
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: effect)
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = effect
    }
}
