

import SwiftUI

struct DuplicateVideoFullView: View {
    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    @ObservedObject var vm : PhotoGalleryViewModel
    @State var selectedImgs : [AssetImagePair] = []
    @Environment(\.dismiss) var dismiss
    @State var showDeletePrompt = false
    @State var totalSize : Int64 = 0
    var body: some View {
        ZStack{
            Color(hex: "#0E0F10").ignoresSafeArea()
            VStack(spacing: 20){
                HStack{
                    Button{
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .frame(width: 6, height: 11)
                            .foregroundStyle(.white)
                            .bold()
                            .frame(width: 33, height: 33)
                            .background(Color(hex: "#282828"))
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text("Duplicate video")
                        .foregroundStyle(.white)
                        .font(.custom(FontExt.semiBold.rawValue, size: 18))
                    Spacer()
                    
                    Image(systemName: "chevron.left")
                        .frame(width: 33, height: 33)
                        
                        .opacity(0)
                }
                
                HStack{
                    Text("\(selectedImgs.count) videos")
                        .font(.custom(FontExt.bold.rawValue, size: 14))
                        .foregroundStyle(.white)
                        .frame(height: 26)
                        .padding(.horizontal, 10)
                    
                    Spacer()
                    
                    Button{
                        selectedImgs = vm.duplicateVideos
                        totalSize = vm.totalSizeOfDuplicatePhotos
                    } label: {
                        Text("Select all")
                            .font(.custom(FontExt.reg.rawValue, size: 15))
                            .foregroundStyle(Color(hex: "#0D65E0"))
                    }
                    
                }
                
                ScrollView(.vertical) {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(vm.duplicateVideos, id: \.self){album in
                            Image(uiImage: album.duplicatesImg)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 168, height: 281)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .contentShape(Rectangle())
                                .overlay(alignment: .topTrailing) {
                                    ZStack{
                                        if selectedImgs.contains(album){
                                            ZStack{
                                                Circle().fill(Color(hex: "#0D65E0"))
                                                Image(systemName: "checkmark")
                                                    .resizable()
                                                    .frame(width: 9, height: 7)
                                            }
                                        }
                                        Circle()
                                            .stroke(.white, lineWidth: 2)
                                    }
                                    .frame(width: 23, height: 23)
                                    .padding([.top, .trailing], 5)
                                }
                                .onTapGesture{
                                    if selectedImgs.contains(album){
                                        if let id = selectedImgs.firstIndex(of: album){
                                            selectedImgs.remove(at: id)
                                            totalSize -= album.duplicates.fileSize()
                                        }
                                    } else {
                                        selectedImgs.append(album)
                                        totalSize += album.duplicates.fileSize()
                                    }
                                }
                        }
                    }
                }
                
                .ignoresSafeArea()
            }
            .padding(.horizontal, 20)
            VStack{
                Spacer()
                Button{
                    showDeletePrompt = true
                } label: {
                    HStack{
                        Text("Delete selected")
                    }
                    .foregroundStyle(.white)
                    .font(.custom(FontExt.bold.rawValue, size: 15))
                    .frame(width: 299, height: 60)
                    .background(Color(hex: "#0D65E0"))
                    .clipShape(RoundedRectangle(cornerRadius: 100))
                    .offset(y: selectedImgs.isEmpty ? 150 : 0)
                }
                .animation(.easeInOut(duration: 0.5), value: selectedImgs)
                .padding(.bottom)
            }
            
            if showDeletePrompt{
                ZStack{
                    Color.black.opacity(0.47).ignoresSafeArea()
                    VStack(spacing: 15){
                        Text("Delete exactly?")
                            .font(.custom(FontExt.bold.rawValue, size: 19))
                            .foregroundStyle(.white)
                        Text("This action cannot be undone")
                            .font(.custom(FontExt.reg.rawValue, size: 14))
                            .foregroundStyle(.white.opacity(0.47))
                        HStack{
                            Text("\(selectedImgs.count)")
                                .font(.custom(FontExt.bold.rawValue, size: 14))
                                .foregroundStyle(.white)
                                .frame(height: 26)
                                .padding(.horizontal, 10)
                                .background(Color.white.opacity(0.31))
                                .clipShape(RoundedRectangle(cornerRadius: 100))
                            
                            Text("\(formatBytes(totalSize))")
                                .font(.custom(FontExt.bold.rawValue, size: 14))
                                .foregroundStyle(.white)
                                .frame(height: 26)
                                .padding(.horizontal, 10)
                                .background(Color(hex: "#4D8343"))
                                .clipShape(RoundedRectangle(cornerRadius: 100))
                            
                            
                        }
                        
                        HStack{
                            Button{
                                showDeletePrompt.toggle()
                            } label: {
                                Text("Cancel")
                                    .font(.custom(FontExt.semiBold.rawValue, size: 15))
                                    .foregroundStyle(.white)
                                    .frame(height: 49)
                                    .frame(maxWidth: .infinity)
                                    .background(Color(hex: "#343434"))
                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                            }
                            
                            Button{
                                vm.deleteDuplicates(assets: selectedImgs, from: "video")
                                showDeletePrompt.toggle()
                            } label: {
                                Text("Delete")
                                    .font(.custom(FontExt.semiBold.rawValue, size: 15))
                                    .foregroundStyle(.white)
                                    .frame(height: 49)
                                    .frame(maxWidth: .infinity)
                                    .background(Color(hex: "#0D65E0"))
                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                            }
                        }
                    }
                    .padding(.horizontal)
                    .frame(width: 352, height: 193)
                    .background(Color(hex: "#181818"))
                    .clipShape(RoundedRectangle(cornerRadius: 19))
                }
            }
        }
        .fullScreenCover(isPresented: $vm.deletionSuccessful, onDismiss: {
            dismiss()
        }, content: {
            SuccessView(count: selectedImgs.count, size: totalSize)
        })
    }
}

#Preview {
    DuplicateVideoFullView(vm: PhotoGalleryViewModel())
}
