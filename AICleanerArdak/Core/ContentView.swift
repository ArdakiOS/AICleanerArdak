//
//  ContentView.swift
//  AICleanerArdak
//
//  Created by Ardak Tursunbayev on 15.01.2025.
//

import SwiftUI

struct ContentView: View {
    @State var didOnb = UserDefaults.standard.bool(forKey: "didOnb")
    @EnvironmentObject var subVM : SubscriptionsManager
    var body: some View {
        ZStack{
            if didOnb {
                NavView(curPage: .allFiles)
                    .onAppear{
                        UserDefaults.standard.set(true, forKey: "didOnb")
                    }
            }
            else {
                OnbView(closeOnb: $didOnb)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: didOnb)
        .task{
            await subVM.loadProducts()
        }
    }
}

#Preview {
    ContentView()
}
