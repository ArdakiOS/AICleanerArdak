//
//  SettingsView.swift
//  AICleanerArdak
//
//  Created by Ardak Tursunbayev on 03.02.2025.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @AppStorage("usePin") var toggle = true
    @Environment(\.dismiss) var dismiss
    let privacyUrlString = "https://telegra.ph/Privacy-Policy-01-31-63"
    var body: some View {
        ZStack{
            Color(hex: "#0E0F10").ignoresSafeArea()
            VStack(alignment: .leading, spacing: 25){
                HStack{
                    Button{
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .bold()
                            .foregroundStyle(.white)
                            .frame(width: 6, height: 11)
                            .padding()
                            .frame(width: 33, height: 33)
                            .background(Color(hex: "#282828"))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Settings")
                        .font(.custom(FontExt.semiBold.rawValue, size: 18))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.left")
                        .frame(width: 33, height: 33)
                        .opacity(0)
                }
                PremiumBanner()
                
                Text("General")
                    .foregroundStyle(.white)
                    .font(.custom(FontExt.med.rawValue, size: 15))
                
                VStack(spacing: 25){
                    SettingsRow(text: "Language")
                    SettingsRowToggler(toggle: $toggle)
                }
                .padding()
                .background(Color(hex: "#181818"))
                .clipShape(RoundedRectangle(cornerRadius: 19))
                
                Text("Support")
                    .foregroundStyle(.white)
                    .font(.custom(FontExt.med.rawValue, size: 15))
                
                VStack(spacing: 25){
                    SettingsRow(text: "Share app")
                    Button{
                        requestReview()
                    } label: {
                        SettingsRow(text: "Rate us")
                    }
                    Button{
                        if let url = URL(string: privacyUrlString) {
                            if UIApplication.shared.canOpenURL(url){
                                UIApplication.shared.open(url)
                            }
                        }
                    } label: {
                        SettingsRow(text: "Privacy Policy")
                    }
                    
                }
                .padding()
                .background(Color(hex: "#181818"))
                .clipShape(RoundedRectangle(cornerRadius: 19))
                    
                
                Spacer()
            }
            .padding()
        }
    }
}

struct SettingsRow : View {
    let text : String
    var body: some View {
        HStack{
            Text(text)
                .foregroundStyle(.white)
                .font(.custom(FontExt.med.rawValue, size: 15))
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.white.opacity(0.17))
        }
        
        
    }
}

struct SettingsRowToggler : View {
    @Binding var toggle : Bool
    var body: some View {
        HStack{
            Text("Use PIN")
                .foregroundStyle(.white)
                .font(.custom(FontExt.med.rawValue, size: 15))
            
            Spacer()
            
            Toggle("", isOn: $toggle)
                .frame(width: 48, height: 26)
                .tint(Color(hex: "#0D65E0"))
        }
        
        
    }
}

func requestReview() {
    if let windowScene = UIApplication.shared.connectedScenes
        .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
        SKStoreReviewController.requestReview(in: windowScene)
    }
}

#Preview {
    SettingsView()
        .environmentObject(EntitlementManager())
        .environmentObject(SubscriptionsManager(entitlementManager: EntitlementManager()))
}
