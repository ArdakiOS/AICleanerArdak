//
//  OnbPaywall.swift
//  AICleanerArdak
//
//  Created by Ardak Tursunbayev on 30.01.2025.
//

import SwiftUI

struct OnbPaywall: View {
    let imgName : String
    let text1 : String
    let text2 : String
    @Binding var closeOnb : Bool
    @EnvironmentObject var subVM : SubscriptionsManager
    @EnvironmentObject var entVM : EntitlementManager
    let termsURLstr = "https://telegra.ph/Terms-of-Use-01-31-3"
    let privacyURLstr = "https://telegra.ph/Privacy-Policy-01-31-63"
    var body: some View {
        ZStack{
            Image(imgName)
                .resizable()
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20){
                Button{
                    closeOnb = true
                } label: {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 30, height: 30)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                    
                Spacer()
                Text(text1)
                    .font(.custom(FontExt.extBold.rawValue, size: 32))
                Text(text2)
                    .font(.custom(FontExt.med.rawValue, size: 15))
                
                ForEach(subVM.products, id: \.self){ prod in
                    if prod.id == "MonthPrem"{
                        HStack{
                            VStack(alignment: .leading, spacing: 10){
                                Text(prod.displayName)
                                    .font(.custom(FontExt.semiBold.rawValue, size: 15))
                                    .foregroundStyle(.white)
                                Text(prod.description)
                                    .font(.custom(FontExt.reg.rawValue, size: 14))
                                    .foregroundStyle(.white.opacity(0.47))
                            }
                            Spacer()
                            
                            Text(prod.displayPrice)
                                .font(.custom(FontExt.med.rawValue, size: 18))
                                .foregroundStyle(.white)
                        }
                        .onAppear{
                            subVM.selectedProduct = prod
                        }
                        .padding()
                        .frame(height: 70)
                        .background(Color.white.opacity(0.13))
                        .clipShape(RoundedRectangle(cornerRadius: 19))
                    }
                    
                }
                Button{
                    if let prod = subVM.selectedProduct{
                        Task{
                            await subVM.buyProduct(prod)
                        }
                    }
                } label: {
                    Text("Continue")
                        .foregroundStyle(.white)
                        .font(.custom(FontExt.bold.rawValue, size: 15))
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "#0D65E0"))
                        .clipShape(RoundedRectangle(cornerRadius: 100))
                }
                .onChange(of: entVM.hasPro) { _ in
                    if entVM.hasPro{
                        closeOnb = true
                    }
                }
                
                HStack{
                    Spacer()
                    
                    Button{
                        Task{
                            await subVM.restorePurchases()
                        }
                    } label: {
                        Text("Restore")
                            .font(.custom(FontExt.reg.rawValue, size: 14))
                            .foregroundStyle(.white.opacity(0.27))
                    }
                    
                    Spacer()
                    
                    Button{
                        if let url = URL(string: termsURLstr) {
                            if UIApplication.shared.canOpenURL(url){
                                UIApplication.shared.open(url)
                            }
                        }
                    } label: {
                        Text("Terms")
                            .font(.custom(FontExt.reg.rawValue, size: 14))
                            .foregroundStyle(.white.opacity(0.27))
                    }
                    
                    Spacer()
                    
                    Button{
                        if let url = URL(string: privacyURLstr) {
                            if UIApplication.shared.canOpenURL(url){
                                UIApplication.shared.open(url)
                            }
                        }
                    } label: {
                        Text("Privacy")
                            .font(.custom(FontExt.reg.rawValue, size: 14))
                            .foregroundStyle(.white.opacity(0.27))
                    }
                    
                    Spacer()
                }
            }
            .padding([.horizontal, .bottom])
            .foregroundStyle(.white)
        }
    }
}

#Preview {
    OnbPaywall(imgName: "Onb4", text1: "Get Full Plan", text2: "clean your device as efficiently as possible with full access", closeOnb: .constant(false))
        .environmentObject(EntitlementManager())
        .environmentObject(SubscriptionsManager(entitlementManager: EntitlementManager()))
}
