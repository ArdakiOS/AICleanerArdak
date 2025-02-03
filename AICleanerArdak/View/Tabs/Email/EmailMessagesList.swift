//
//  EmailMessagesList.swift
//  AICleanerArdak
//
//  Created by Ardak Tursunbayev on 22.01.2025.
//

import SwiftUI

struct EmailMessagesList: View {
    @ObservedObject var vm : EmailViewModel
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack(alignment: .bottom){
            Color(hex: "#0E0F10").ignoresSafeArea()
            VStack{
                HStack{
                    Button{
                        vm.nextPageToken = ""
                        dismiss()
                    } label: {
                        ZStack{
                            Circle().fill(Color(hex: "#282828"))
                                .frame(width: 30, height: 30)
                            Image(systemName: "chevron.left")
                                .resizable()
                                .frame(width: 7, height: 13)
                                .foregroundStyle(.white)
                                .bold()
                        }
                    }
                    
                    Spacer()
                    
                    Text(vm.selectedFolder?.name.lowercased().capitalized.replacingOccurrences(of: "Category_", with: "") ?? "Unknown")
                        .font(.custom(FontExt.semiBold.rawValue, size: 18))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    ZStack{
                        Circle().fill(Color(hex: "#282828"))
                            .frame(width: 30, height: 30)
                        Image(systemName: "chevron.left")
                            .resizable()
                            .frame(width: 7, height: 13)
                            .foregroundStyle(.white)
                            .bold()
                    }
                    .opacity(0)
                }
                ScrollView(.vertical) {
                    LazyVStack {
                        ForEach(vm.messagesToDisplay, id: \.self) { msg in
                            MessageView(message: msg, selectedMsg: $vm.selectedMesagesToDelete)
                        }
                        
                        // This spacer triggers the detection of the scroll position
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    // Check if the user has reached the end
                                    if geometry.frame(in: .global).maxY < UIScreen.main.bounds.height {
                                        vm.getFolderMessages()
                                    }
                                }
                        }
                        .frame(height: 1) // Ensure it's very small and unobtrusive
                    }
                }
            }
            .padding(.horizontal)
            
            Button{
                vm.deleteMessages()
            } label: {
                HStack{
                    Text("Delete selected")
                }
                .foregroundStyle(.white)
                .font(.custom(FontExt.bold.rawValue, size: 15))
                .frame(width: 352, height: 60)
                .background(Color(hex: "#0D65E0"))
                .clipShape(RoundedRectangle(cornerRadius: 100))
                .offset(y: vm.selectedMesagesToDelete.isEmpty ? 150 : 0)
            }
            .animation(.easeInOut(duration: 0.5), value: vm.selectedMesagesToDelete)
            .animation(.easeInOut(duration: 0.5), value: vm.messagesToDisplay)
            .padding(.bottom)
        }
    }
}

#Preview {
    EmailMessagesList(vm : EmailViewModel())
}
