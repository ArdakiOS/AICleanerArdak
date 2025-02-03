//
//  InAppPayWall.swift
//  AICleanerArdak
//
//  Created by Ardak Tursunbayev on 30.01.2025.
//

import SwiftUI

struct InAppPayWall: View {
    @EnvironmentObject var subVM : SubscriptionsManager
    @EnvironmentObject var entVM : EntitlementManager
    @Environment(\.dismiss) var dismiss
    let termsURLstr = "https://telegra.ph/Terms-of-Use-01-31-3"
    let privacyURLstr = "https://telegra.ph/Privacy-Policy-01-31-63"
    var body: some View {
        ZStack{
            Image(.payWall)
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 25){
                VStack(spacing: 0){
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .foregroundStyle(.white.opacity(0.12))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    
                    Text("Get Full Access")
                        .foregroundStyle(.white)
                        .font(.custom(FontExt.bold.rawValue, size: 26))
                    
                }
                VStack{
                    Text("Unlock all app features and get")
                        .foregroundColor(.white)
                    + Text("\nbetter cleaning")
                        .foregroundColor(Color(hex: "#0D65E0"))
                }
                .fixedSize()
                .multilineTextAlignment(.center)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 25){
                    Feature(text : "Unlimited Clearing")
                    
                    Feature(text : "Video Compress")
                    
                    Feature(text : "Unlimited Private")
                    
                    Feature(text : "Clearing Your Email")
                }
                
                Spacer()
                
                VStack(spacing: 10){
                    ForEach(subVM.products, id: \.self){ prod in
                        HStack{
                            if prod == subVM.selectedProduct {
                                ZStack{
                                    Circle().fill(Color(hex: "#0D65E0"))
                                        .frame(width: 23, height: 23)
                                    Image(systemName: "checkmark")
                                        .resizable()
                                        .frame(width: 9, height: 7)
                                        .bold()
                                }
                            } else {
                                Circle()
                                    .stroke(Color(hex: "#535353"), lineWidth: 1)
                                    .frame(width: 23, height: 23)
                            }
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
                        .background(Color(hex: "#181818"))
                        .clipShape(RoundedRectangle(cornerRadius: 19))
                        .onTapGesture {
                            subVM.selectedProduct = prod
                        }
                        .overlay {
                            if prod == subVM.selectedProduct {
                                RoundedRectangle(cornerRadius: 19).stroke(Color(hex: "#0D65E0"), lineWidth: 1)
                            }
                        }
                        .overlay(alignment: .topTrailing) {
                            if prod.id == "MonthPrem"{
                                Text("SAVE 96%")
                                    .font(.custom(FontExt.semiBold.rawValue, size: 13))
                                    .foregroundStyle(.white)
                                    .padding()
                                    .frame(height: 26)
                                    .background {
                                        Color(hex: "#4D8343")
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 100))
                                    .padding(.trailing, 25)
                                    .offset(y: -13)
                            }
                        }
                        
                        
                    }
                    Button{
                        if let prod = subVM.selectedProduct{
                            Task{
                                await subVM.buyProduct(prod)
                            }
                        }
                    } label: {
                        Text(subVM.selectedProduct == subVM.products.first(where: {$0.id == "MonthPrem"}) ? "Start Plan" : "Start Free Trial")
                            .foregroundStyle(.white)
                            .font(.custom(FontExt.bold.rawValue, size: 15))
                            .frame(height: 60)
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "#0D65E0"))
                            .clipShape(RoundedRectangle(cornerRadius: 100))
                    }
                    .onChange(of: entVM.hasPro) { _ in
                        if entVM.hasPro{
                            dismiss()
                        }
                    }
                }
                Text(subVM.selectedProduct == subVM.products.first(where: {$0.id == "MonthPrem"}) ? "Billed annualy at $29.99, Request a refund if you are not 100% satisfied" : "3-Day free trial, then billed $5.90/week, Request a refund if you are not 100% satisfied")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color(hex: "#4F5050"))
                    .font(.custom(FontExt.reg.rawValue, size: 10))
                
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
            .padding()
        }
    }
    
    struct Feature: View {
        let text : String
        var body: some View {
            HStack{
                ZStack{
                    Circle().fill(.white.opacity(0.05))
                    Image(systemName: "checkmark")
                        .resizable()
                        .frame(width: 16, height: 12)
                        .foregroundStyle(Color(hex: "#0D65E0"))
                        .bold()
                }
                .frame(width: 44, height: 44)
                
                Text(text)
                    .font(.custom(FontExt.med.rawValue, size: 16))
                    .foregroundStyle(.white)
            }
        }
    }
}



#Preview {
    InAppPayWall()
        .environmentObject(EntitlementManager())
        .environmentObject(SubscriptionsManager(entitlementManager: EntitlementManager()))
}
