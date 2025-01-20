//
//  GridView.swift
//  AICleanerArdak
//
//  Created by Ardak Tursunbayev on 16.01.2025.
//

import SwiftUI
import Photos

struct GridView: View {
    @Binding var assets : [PhotoDetails]
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(assets, id: \.self) { asset in
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
                    }
                }
            }
        }
    }
}

