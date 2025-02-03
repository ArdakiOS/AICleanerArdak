//
//  EditingView.swift
//  AICleanerArdak
//
//  Created by Ardak Tursunbayev on 16.01.2025.
//

import SwiftUI


struct EditingView: View {
    @Environment(\.dismiss) var dismiss
    @State var selectedQuality = Qualities.low
    @ObservedObject var vm : CompressionViewModel
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State var progress = 0.0
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
                            .frame(width: 33, height: 33)
                            .background(Color(hex: "#282828"))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Video Compress")
                        .font(.custom(FontExt.semiBold.rawValue, size: 18))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.left")
                        .resizable()
                        .frame(width: 33, height: 33)
                        .clipShape(Circle())
                        .opacity(0)
                    
                }
                .padding(.horizontal)
                ZStack{
                    Color(hex: "#181818")
                    if let img = vm.selectedVideoToEdit?.assetImg{
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                    }
                    
                    if vm.compressionState == .inProgress{
                        LineProgress(progress: $progress)
                    }
                    
                }
                .frame(maxHeight: 343)
                
                switch vm.compressionState {
                case .config :
                    VStack(spacing: 20) {
                        HStack{
                            Spacer()
                            ForEach(Qualities.allCases, id: \.self) { qual in
                                Button{
                                    selectedQuality = qual
                                } label: {
                                    Text(qual.displayName())
                                        .font(.custom(qual == selectedQuality ? FontExt.bold.rawValue : FontExt.semiBold.rawValue, size: 14.5))
                                        .foregroundStyle(qual == selectedQuality ? .black : Color(hex: "#535353"))
                                        .padding()
                                        .frame(maxWidth: .infinity, maxHeight: 38)
                                        .background {
                                            if qual == selectedQuality {
                                                Color.white
                                            } else {
                                                Color(hex: "#181818")
                                            }
                                        }
                                        .clipShape(RoundedRectangle(cornerRadius: 29))
                                    
                                }
                                
                                Spacer()
                            }
                            
                        }
                        .padding(.horizontal)
                        .onChange(of: selectedQuality) { _ in
                            vm.estimateCompressedFileSize(quality: selectedQuality)
                        }
                        
                        Spacer()
                        if vm.selectedVideoToEdit != nil {
                            Text("\(formatBytes(vm.estimatedSizeReduction))")
                                .font(.custom(FontExt.bold.rawValue, size: 56))
                                .foregroundStyle(.white)
                            
                            Text("After compressions the video size will be")
                                .font(.custom(FontExt.med.rawValue, size: 14))
                                .foregroundStyle(.white.opacity(0.43))
                        }
                        
                        Spacer()
                        
                        Button{
                            vm.compressVideo(quality: selectedQuality)
                        } label: {
                            Text("Start compress")
                                .foregroundStyle(.white)
                                .font(.custom(FontExt.bold.rawValue, size: 15))
                                .frame(height: 60)
                                .frame(maxWidth: .infinity)
                                .background(Color(hex: "#0D65E0"))
                                .clipShape(RoundedRectangle(cornerRadius: 100))
                                .padding(.horizontal)
                        }
                    }
                        
                case .inProgress :
                    VStack{
                        Spacer()
                        CircleProgress(progress: $progress)
                        Spacer()
                    }
                    
                case .finished :
                    VStack(spacing: 15) {
                        Spacer()
                        if vm.selectedVideoToEdit != nil {
                            Text("-\(formatBytes(vm.selectedVideoToEdit!.fileSize - vm.actualNewSize))")
                                .font(.custom(FontExt.bold.rawValue, size: 14))
                                .foregroundStyle(.white)
                                .padding()
                                .frame(height: 26)
                                .background(Color(hex: "#4D8343"))
                                .clipShape(RoundedRectangle(cornerRadius: 100))
                            
                            Text("\(formatBytes(vm.actualNewSize))")
                                .font(.custom(FontExt.bold.rawValue, size: 56))
                                .foregroundStyle(.white)
                            
                            Text("Now the compressed video weighs")
                                .font(.custom(FontExt.med.rawValue, size: 14))
                                .foregroundStyle(.white.opacity(0.43))
                        }
                        
                        Spacer()
                        
                        Button{
                            dismiss()
                            vm.compressionState = .config
                        } label: {
                            Text("Great")
                                .foregroundStyle(.white)
                                .font(.custom(FontExt.bold.rawValue, size: 15))
                                .frame(height: 60)
                                .frame(maxWidth: .infinity)
                                .background(Color(hex: "#0D65E0"))
                                .clipShape(RoundedRectangle(cornerRadius: 100))
                                .padding(.horizontal)
                        }
                    }
                }
                
            }
            
        }
        .onReceive(timer, perform: { _ in
            if vm.compressionState == .inProgress{
                if progress < 0.99 {
                    progress += 0.005
                }
            }
        })
        .onAppear{
            vm.estimateCompressedFileSize(quality: selectedQuality)
        }
        .animation(.easeInOut(duration: 0.5), value: selectedQuality)
        .animation(.easeInOut(duration: 0.15), value: progress)
        .animation(.easeInOut(duration: 0.5), value: vm.compressionState)
        
    }
}

#Preview {
    EditingView(vm : CompressionViewModel())
}

struct LineProgress : View {
    @Binding var progress : Double
    var body: some View {
        ZStack {
            Color.black.opacity(0.47).ignoresSafeArea()
            ZStack(alignment: .leading){
                RoundedRectangle(cornerRadius: 36).fill(.white.opacity(0.36))
                    .frame(width: 145, height: 5)
                RoundedRectangle(cornerRadius: 36).fill(Color(hex: "#0D65E0"))
                    .frame(width: 145 * progress , height: 5)
            }
            
        }
    }
}

struct CircleProgress : View {
    @Binding var progress : Double
    var body: some View {
        HStack{
            Image(.compressing)
                .resizable()
                .frame(width: 25, height: 25)
                .rotationEffect(.degrees(720 * progress))
            
            Text("Loading..")
                .font(.custom(FontExt.med.rawValue, size: 23))
                .foregroundStyle(.white)
        }
    }
}
