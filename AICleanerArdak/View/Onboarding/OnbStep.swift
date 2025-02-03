//
//  OnbStep.swift
//  AICleanerArdak
//
//  Created by Ardak Tursunbayev on 30.01.2025.
//

import SwiftUI

struct OnbStep: View {
    let imgName : String
    let text1 : String
    let text2 : String
    let buttonText : String
    let nextPage : OnbSteps
    @Binding var curPage : OnbSteps
    var body: some View {
        ZStack{
            Image(imgName)
                .resizable()
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20){
                Spacer()
                Text(text1)
                    .font(.custom(FontExt.extBold.rawValue, size: 32))
                Text(text2)
                    .font(.custom(FontExt.med.rawValue, size: 15))
                Button{
                    curPage = nextPage
                } label: {
                    Text(buttonText)
                        .font(.custom(FontExt.bold.rawValue, size: 15))
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "#0D65E0"))
                        .clipShape(RoundedRectangle(cornerRadius: 100))
                }
            }
            .padding()
            .foregroundStyle(.white)
        }
    }
}

#Preview {
    OnbStep(imgName: "Onb1", text1: "Clear memory", text2: "convenient interface and many useful functions in our application", buttonText: "Continue", nextPage: .two, curPage: .constant(.one))
}
