//
//  EditingView.swift
//  AICleanerArdak
//
//  Created by Ardak Tursunbayev on 16.01.2025.
//

import SwiftUI
enum Qualities : CaseIterable{
    case low, medium, high
    
    func displayName() -> String{
        switch self {
        case .low:
            "Low"
        case .medium:
            "Medium"
        case .high:
            "High"
        }
    }
}

struct EditingView: View {
    @Environment(\.dismiss) var dismiss
    @State var selectedQuality = Qualities.low
    @ObservedObject var vm : CompressionViewModel
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
                    if let img = vm.selectedVideoToEdit?.image{
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                    }
                }
                .frame(maxHeight: 343)
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
                
                Spacer()
                
                Button{
                    vm.compressVideo(quality: selectedQuality)
                } label: {
                    Text("COMPRESS")
                        .foregroundStyle(.red)
                        .font(.largeTitle)
                        
                }
            }
            
        }
        .animation(.easeInOut(duration: 0.5), value: selectedQuality)
    }
}

#Preview {
    EditingView(vm : CompressionViewModel())
}
