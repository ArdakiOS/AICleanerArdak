
import SwiftUI

enum NavBarPages: CaseIterable {
    case allFiles, email, calendar, compress, privacy
    
    func displayName() -> String {
        switch self {
        case .allFiles:
            "All files"
        case .email:
            "Email"
        case .calendar:
            "Calendar"
        case .compress:
            "Compress"
        case .privacy:
            "Privacy"
        }
    }
    
    func imgName() -> String {
        switch self {
        case .allFiles:
            "AllFiles"
        case .email:
            "Email"
        case .calendar:
            "Calendar"
        case .compress:
            "Compress"
        case .privacy:
            "Privacy"
        }
    }
}

struct NavBar: View {
    @Binding var curPage : NavBarPages
    var body: some View {
        ZStack{
            Color(hex: "#131313").ignoresSafeArea()
            HStack{
                Spacer()
                ForEach(NavBarPages.allCases, id: \.self){tab in
                    Button{
                        curPage = tab
                    } label: {
                        VStack(spacing: 10){
                            Rectangle()
                                .fill(Color(hex: "#0D65E0"))
                                .frame(width: 43, height: 5)
                                .clipShape(.rect(bottomLeadingRadius: 100, bottomTrailingRadius: 100))
                                .opacity(curPage == tab ? 1 : 0)
                            
                            Image(tab.imgName())
                                .resizable()
                                .frame(width: 48, height: 48)
                            
                            Text(tab.displayName())
                                .font(.custom(FontExt.reg.rawValue, size: 11))
                                .foregroundColor(curPage == tab ? .white : .white.opacity(0.48))
                        }
                    }
                    
                    Spacer()
                }
            }
        }
            
        
    }
}

#Preview {
    @State var curPage = NavBarPages.allFiles
    ZStack{
        
        NavBar(curPage: $curPage)
    }
}
