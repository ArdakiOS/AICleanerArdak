
import SwiftUI

struct NavView: View {
    @StateObject var photoVM = PhotoGalleryViewModel()
    @State var curPage = NavBarPages.allFiles
    @EnvironmentObject var subVM : SubscriptionsManager
    @EnvironmentObject var entVM : EntitlementManager
    var body: some View {
        NavigationStack{
            ZStack{
                Color(hex: "#0E0F10").ignoresSafeArea()
                VStack(spacing: 0){
                    HStack{
                        Text("AI Cleaner")
                            .font(.custom(FontExt.bold.rawValue, size: 23))
                            .foregroundStyle(.white)
                        Spacer()
                        
                        NavigationLink{
                            SettingsView()
                                .navigationBarBackButtonHidden()
                                .environmentObject(subVM)
                                .environmentObject(entVM)
                        } label: {
                            Image("Settings")
                                .resizable()
                                .frame(width: 27, height: 27)
                        }
                    }
                    .padding([.horizontal, .bottom], 20)
                    TabView(selection: $curPage) {
                        switch curPage {
                        case .allFiles:
                            
                            AllFilesView()
                                .tag(NavBarPages.allFiles)
                        case .email:
                            
                            EmailView()
                                .tag(NavBarPages.email)
                        case .calendar:
                            
                            CalendarView()
                                .tag(NavBarPages.calendar)
                        case .compress:
                            
                            CompressionView()
                                .tag(NavBarPages.compress)
                        case .privacy:
                            
                            PrivacyView()
                                .tag(NavBarPages.privacy)
                        }
                    }
                    
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    
                    NavBar(curPage: $curPage)
                        .frame(height: 103)
                        .ignoresSafeArea()
                }
            }
            .environmentObject(photoVM)
            .ignoresSafeArea(.keyboard)
            .animation(.easeInOut(duration: 0.2), value: curPage)
        }
    }
}

#Preview {
    NavView()
        .environmentObject(EntitlementManager())
        .environmentObject(SubscriptionsManager(entitlementManager: EntitlementManager()))
}
