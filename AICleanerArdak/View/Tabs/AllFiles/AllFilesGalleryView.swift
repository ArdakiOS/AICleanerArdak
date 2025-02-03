//
//  AllFilesGalleryView.swift
//  AICleanerArdak
//
//  Created by Ardak Tursunbayev on 29.01.2025.
//

import SwiftUI

struct AllFilesGalleryView: View {
    let columns = [
        GridItem(.flexible(),spacing: 20),
        GridItem(.flexible(),spacing: 20)
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
                    Text(vm.selectedAlbum?.name ?? "Unknown")
                        .font(.custom(FontExt.semiBold.rawValue, size: 18))
                        .foregroundStyle(.white)
                    
                    Text("\(selectedImgs.count)")
                        .font(.custom(FontExt.bold.rawValue, size: 14))
                        .foregroundStyle(.white)
                        .frame(height: 26)
                        .padding(.horizontal, 10)
                        .background(.white.opacity(0.31))
                        .clipShape(RoundedRectangle(cornerRadius: 100))
                    
                    Spacer()
                    
                    Button{
                        selectedImgs = vm.selectedAlbum?.assets ?? []
                        totalSize = vm.selectedAlbum?.size ?? 0
                    } label: {
                        Text("Select all")
                            .font(.custom(FontExt.reg.rawValue, size: 15))
                            .foregroundStyle(Color(hex: "#0D65E0"))
                    }
                    
                }
                
                ScrollView(.vertical) {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(vm.selectedAlbum?.assets ?? [], id: \.self){album in
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
                                                    .frame(width: 8, height: 6)
                                                    .bold()
                                                    .foregroundStyle(.white)
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
            .padding(.top, 20)
            
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
                                vm.deleteImgs(imgs: selectedImgs)
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

struct SuccessView : View {
    let count : Int
    let size : Int64
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack{
            Color(hex: "#0E0F10").ignoresSafeArea()
            
            VStack(spacing: 10){
                Spacer()
                ZStack{
                    Circle().fill(Color(hex: "#0D65E0").opacity(0.09))
                        .frame(width: 149, height: 149)
                    Circle().fill(Color(hex: "#0D65E0"))
                        .frame(width: 113, height: 113)
                    
                    Image(systemName: "checkmark")
                        .resizable()
                        .frame(width: 40, height: 30)
                        .foregroundStyle(.white)
                        .bold()
                    
                }
                
                Text("Congratulate!")
                    .font(.custom(FontExt.bold.rawValue, size: 25))
                    .foregroundStyle(.white)
                
                Text("The files were successfully deleted")
                    .font(.custom(FontExt.reg.rawValue, size: 14))
                    .foregroundStyle(.white.opacity(0.47))
                
                HStack{
                    Text("Delete \(count) items")
                        .font(.custom(FontExt.med.rawValue, size: 15))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Text("\(formatBytes(size))")
                        .font(.custom(FontExt.bold.rawValue, size: 14))
                        .foregroundStyle(.white)
                        .frame(height: 26)
                        .padding(.horizontal, 10)
                        .background(Color(hex: "#4D8343"))
                        .clipShape(RoundedRectangle(cornerRadius: 100))
                }
                .padding()
                .frame(height: 60)
                .background(RoundedRectangle(cornerRadius: 19).stroke(Color(hex: "#282828"), lineWidth: 1))
                
                Spacer()
                
                Button{
                    dismiss()
                } label: {
                    Text("Close")
                        .font(.custom(FontExt.bold.rawValue, size: 15))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color(hex: "#0D65E0"))
                        .clipShape(RoundedRectangle(cornerRadius: 100))
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
//    AllFilesGalleryView(vm: PhotoGalleryViewModel())
    SuccessView(count: 2, size: 1024 * 1500)
}
