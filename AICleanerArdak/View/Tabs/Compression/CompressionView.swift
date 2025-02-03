
import SwiftUI

struct CompressionView: View {
    @StateObject var vm = CompressionViewModel()
    @EnvironmentObject var photoVM : PhotoGalleryViewModel
    let columns = [GridItem(.flexible(), spacing: 20),
                   GridItem(.flexible(), spacing: 20)
    ]
    @State var showPopUp = false
    var body: some View {
        ZStack{
            Color(hex: "#0E0F10").ignoresSafeArea()
            VStack(spacing: 20){
                HStack{
                    Text("\(vm.assets.count) video")
                        .font(.custom(FontExt.reg.rawValue, size: 14))
                        .foregroundStyle(.white.opacity(0.47))
                    
                    Rectangle().fill(.white.opacity(0.47)).frame(width: 1, height: 19)
                    
                    Text("\(formatBytes(vm.totalVideosSize))")
                        .font(.custom(FontExt.med.rawValue, size: 14))
                        .foregroundStyle(.white)
                }
                .padding()
                .frame(height: 44)
                .background(Color(hex: "#181818"))
                .clipShape(RoundedRectangle(cornerRadius: 31))
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if vm.assets.isEmpty{
                    Spacer()
                    Image("NoVideo")
                        .resizable()
                        .frame(width: 124, height: 124)
                    Text("Video not found")
                        .font(.custom(FontExt.med.rawValue, size: 16))
                        .foregroundStyle(Color(hex: "#5E5E5E"))
                    
                    Button{
                        photoVM.requestPermission()
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
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(vm.assets, id: \.self) { asset in
                                VStack(alignment: .leading){
                                    Image(uiImage: asset.assetImg)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 168, height: 281)
                                        .clipped()
                                    
                                    Text(asset.name)
                                        .foregroundStyle(.white)
                                        .font(.custom(FontExt.med.rawValue, size: 15))
                                        .lineLimit(1)
                                    Text("\(formatBytes(asset.fileSize))")
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
            .padding(.horizontal, 20)
            
            if showPopUp{
                HStack{
                    Text("Compess videos to save up ")
                        .font(.custom(FontExt.med.rawValue, size: 14))
                        .foregroundColor(.white.opacity(0.43))
                    + Text("\(formatBytes(vm.totalVideosSize / 2))")
                        .font(.custom(FontExt.semiBold.rawValue, size: 14))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button{
                        showPopUp.toggle()
                    } label: {
                        ZStack{
                            Circle()
                                .fill(Color(hex: "#282828"))
                                .frame(width: 29, height: 29)
                            Image(systemName: "xmark")
                                .resizable()
                                .frame(width: 11, height: 11)
                        }
                    }
                }
                .padding()
                .frame(height: 57)
                .background(Color(hex: "#181818"))
                .clipShape(RoundedRectangle(cornerRadius: 38))
                .padding(.horizontal)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom)
                
            }
        }
        .animation(.easeInOut(duration: 0.5), value: showPopUp)
        .onAppear{
            if photoVM.videoAssets.count > vm.assets.count {
                vm.prepareAssetToDisplay(videoAssets: photoVM.videoAssets)
            }
            
            if !vm.assets.isEmpty {
                showPopUp = true
            }
        }
        .fullScreenCover(isPresented: $vm.openEditor, content: {
            EditingView(vm: vm)
        })
    }
}

#Preview {
    NavView(curPage: .compress)
}
