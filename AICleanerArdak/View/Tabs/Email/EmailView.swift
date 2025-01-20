
import SwiftUI
import GoogleSignInSwift
import GoogleSignIn

struct EmailView: View {
    @State private var userName: String = ""
    @StateObject var vm = EmailViewModel()
    var body: some View {
        ZStack{
            Color(hex: "#0E0F10").ignoresSafeArea()
            if vm.gAccount == nil {
                VStack{
                    Button{
                        vm.handleSignInButton()
                    } label: {
                        HStack(spacing: 20){
                            Image("EmailIcon")
                                .resizable()
                                .frame(width: 46, height: 46)
                            
                            Text("Sing in with Google")
                                .font(.custom(FontExt.bold.rawValue, size: 15))
                                .foregroundStyle(.white)
                        }
                        .padding(.trailing)
                        .padding(.horizontal, 5)
                        .frame(height: 54)
                        .background(Color(hex: "#0D65E0"))
                        .clipShape(RoundedRectangle(cornerRadius: 49))
                    }
                }
            } else {
                VStack{
                    Button{
                        vm.loadMessages()
                    } label: {
                        HStack(spacing: 20){
                            Image("EmailIcon")
                                .resizable()
                                .frame(width: 46, height: 46)
                            
                            Text("Load")
                                .font(.custom(FontExt.bold.rawValue, size: 15))
                                .foregroundStyle(.white)
                        }
                        .padding(.trailing)
                        .padding(.horizontal, 5)
                        .frame(height: 54)
                        .background(Color(hex: "#0D65E0"))
                        .clipShape(RoundedRectangle(cornerRadius: 49))
                    }
                }
            }
        }
        .onOpenURL { url in
            GIDSignIn.sharedInstance.handle(url)
        }
    }
    
}





#Preview {
    EmailView()
}
