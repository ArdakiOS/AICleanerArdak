//
//  PremiumBanner.swift
//  AICleanerArdak
//
//  Created by Ardak Tursunbayev on 29.01.2025.
//

import SwiftUI

struct PremiumBanner: View {
    @State var finishDate : Date?
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var remainingTime = ""
    @State var timeInterval = 0.0
    @EnvironmentObject var subVM : SubscriptionsManager
    @State var openPayWall = false
    var body: some View {
        HStack{
            if finishDate == nil {
                VStack(alignment: .leading){
                    Text("Get Premium now")
                        .font(.custom(FontExt.semiBold.rawValue, size: 17))
                        .foregroundStyle(.white)
                    
                    Text("the best phone cleaning")
                        .font(.custom(FontExt.reg.rawValue, size: 14))
                        .foregroundStyle(.white.opacity(0.47))
                    
                }
                Spacer()
                
                Image(.bannerEmail)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 136)
            } else {
                VStack(alignment: .leading){
                    Text("Premuim Activated")
                        .font(.custom(FontExt.semiBold.rawValue, size: 18))
                        .foregroundStyle(.white)
                    Text(remainingTime)
                        .font(.custom(FontExt.reg.rawValue, size: 15))
                        .foregroundStyle(.white.opacity(0.47))
                }
                .onReceive(timer) { _ in
                    timeInterval -= 1
                    
                    let days = Int(timeInterval) / (60 * 60 * 24)
                    let hours = (Int(timeInterval) % (60 * 60 * 24)) / (60 * 60)
                    let minutes = (Int(timeInterval) % (60 * 60)) / 60
                    let seconds = Int(timeInterval) % 60

                    remainingTime = "\(days)d \(hours)h \(minutes)m \(seconds)s"
                }
                
                Spacer()
                
                ZStack{
                    Circle().fill(.white).frame(width: 36, height: 36)
                    Image(systemName: "checkmark")
                        .resizable()
                        .frame(width: 13, height: 9)
                        .foregroundStyle(Color(hex: "#7A2E9C"))
                        .bold()
                }
                .padding(.trailing)
            }
        }
        .padding([.leading, .vertical])
        .frame(height: 75)
        .background {
            LinearGradient(colors: [Color(hex: "2061BD"), Color(hex: "862898")], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        .clipShape(RoundedRectangle(cornerRadius: 19))
        .onTapGesture {
            if finishDate == nil {
                openPayWall = true
            }
        }
        .task {
            finishDate = await subVM.getRemainingTimeOfSub()
            if let finishDate = finishDate{
                let currentDate = Date()
                timeInterval = finishDate.timeIntervalSince(currentDate)
            }
        }
        .fullScreenCover(isPresented: $openPayWall) {
            InAppPayWall()
        }
        
        
    }
    
    
}
#Preview {
    PremiumBanner(finishDate: Date(timeIntervalSinceNow: 123121))
}
