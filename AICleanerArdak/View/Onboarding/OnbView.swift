//
//  OnbView.swift
//  AICleanerArdak
//
//  Created by Ardak Tursunbayev on 30.01.2025.
//

import SwiftUI

enum OnbSteps {
    case one, two, three, paywall
}

struct OnbView: View {
    @State var curPage = OnbSteps.one
    @Binding var closeOnb : Bool
    var body: some View {
        ZStack{
            switch curPage {
            case .one:
                OnbStep(imgName: "Onb1", text1: "Clear memory", text2: "convenient interface and many useful functions in our application", buttonText: "Continue", nextPage: .two, curPage: $curPage)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case .two:
                OnbStep(imgName: "Onb2", text1: "Easy removal", text2: "easily and quickly delete unnecessary files from your device", buttonText: "Continue", nextPage: .three, curPage: $curPage)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case .three:
                OnbStep(imgName: "Onb3", text1: "Clear e-mail", text2: "clear not only your memory, but also much more, you have many possibilities here", buttonText: "Continue", nextPage: .paywall, curPage: $curPage)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case .paywall:
                OnbPaywall(imgName: "Onb4", text1: "Get Full Plan", text2: "clean your device as efficiently as possible with full access", closeOnb: $closeOnb)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
        }
        .onAppear{
            UserDefaults.standard.setValue(true, forKey: "usePin")
        }
        .animation(.easeInOut(duration: 0.3), value: curPage)
    }
}

#Preview {
    OnbView(closeOnb: .constant(false))
}
