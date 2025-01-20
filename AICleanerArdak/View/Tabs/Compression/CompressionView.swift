
import SwiftUI

struct CompressionView: View {
    @StateObject var vm = CompressionViewModel()
    @EnvironmentObject var photoVM : PhotoGalleryViewModel
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    var body: some View {
        ZStack{
            Color(hex: "#0E0F10").ignoresSafeArea()
            VStack{
                HStack{
                    Text("\(vm.savedVideos.count) video")
                        .font(.custom(FontExt.reg.rawValue, size: 14))
                    
                        .frame(height: 17)
                        .foregroundStyle(.white.opacity(0.47))
                        .padding()
                        .background(Color(hex: "#181818"))
                        .clipShape(RoundedRectangle(cornerRadius: 31))
                    
                    Spacer()
                    
                }
                if vm.savedVideos.isEmpty{
                    Spacer()
                    Image("NoVideo")
                        .resizable()
                        .frame(width: 124, height: 124)
                    Text("Video not found")
                        .font(.custom(FontExt.med.rawValue, size: 16))
                        .foregroundStyle(Color(hex: "#5E5E5E"))
                    
                    Button{
                        vm.photoLibIsOpen.toggle()
                    } label: {
                        HStack{
                            Image(systemName: "plus")
                            Text("Add new")
                        }
                        .foregroundStyle(.white)
                        .font(.custom(FontExt.bold.rawValue, size: 15))
                        .frame(width: 242, height: 54)
                        .background(Color(hex: "#0D65E0"))
                        .clipShape(RoundedRectangle(cornerRadius: 49))
                    }
                    .padding(.top, 20)
                    Spacer()
                } else {
                    if vm.isUploading {
                        UploadingView()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 10) {
                                ForEach(vm.savedVideos, id: \.self) { asset in
                                    VStack(alignment: .leading){
                                        Image(uiImage: asset.image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 168, height: 281)
                                            .clipped()
                                        
                                        Text(asset.name)
                                            .foregroundStyle(.white)
                                            .font(.custom(FontExt.med.rawValue, size: 15))
                                        Text("\(String(format: "%.1f", asset.sizeInMB)) MB")
                                            .foregroundStyle(Color(hex: "#7F8080"))
                                            .font(.custom(FontExt.reg.rawValue, size: 15))
                                    }
                                    .onTapGesture {
                                        vm.selectedVideoToEdit = asset
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .onAppear{
            vm.selectedVideos = Set(photoVM.videoAssets)
            vm.prepareAssetToDisplay()
        }
        .fullScreenCover(isPresented: $vm.openEditor, content: {
            EditingView(vm: vm)
        })
        .sheet(isPresented: $vm.photoLibIsOpen, onDismiss: {
            vm.prepareAssetToDisplay()
        }, content: {
            PhotoGalleryView(viewModel: photoVM, selectedPhotos: $vm.selectedVideos, displayOptions: .video)
                .presentationDetents([.fraction(0.9)])
                .presentationCornerRadius(20)
                .presentationDragIndicator(.visible)
        })
    }
}

#Preview {
    NavView(curPage: .compress)
}
