
import SwiftUI

struct NavView: View {
    @StateObject var photoVM = PhotoGalleryViewModel()
    @State var curPage = NavBarPages.allFiles
    var body: some View {
        ZStack{
            Color(hex: "#0E0F10").ignoresSafeArea()
            VStack(spacing: 0){
                HStack{
                    Text("AI Cleaner")
                        .font(.custom(FontExt.bold.rawValue, size: 23))
                        .foregroundStyle(.white)
                    Spacer()
                    
                    Button{
                        // OPEN SETTINGS
                    } label: {
                        Image("Settings")
                            .resizable()
                            .frame(width: 27, height: 27)
                    }
                }
                .padding([.horizontal, .bottom], 20)
                TabView(selection: $curPage) {
                    AllFilesView()
                        .tag(NavBarPages.allFiles)
                    EmailView()
                        .tag(NavBarPages.email)
                    CalendarView()
                        .tag(NavBarPages.calendar)
                    CompressionView()
                        .tag(NavBarPages.compress)
                    PrivacyView()
                        .tag(NavBarPages.privacy)
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

#Preview {
    NavView()
}
