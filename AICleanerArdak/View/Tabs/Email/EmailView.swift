
import SwiftUI
import GoogleSignInSwift
import GoogleSignIn

struct EmailView: View {
    @StateObject var vm = EmailViewModel()
    @State var openFolder = false
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
                    HStack(alignment: .center){
                        AsyncImage(url:  vm.gAccount?.profile?.imageURL(withDimension: 42)) { img in
                            img
                                .resizable()
                                .frame(width: 42, height: 42)
                                .scaledToFit()
                                .clipShape(Circle())
                        } placeholder: {
                            ZStack{
                                Circle().fill(Color(hex: "#181818"))
                                Image(systemName: "person")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            }
                            .frame(width: 42, height: 42)
                        }
                        
                        VStack(alignment: .leading){
                            Text(vm.gAccount?.profile?.name ?? "Unknown")
                                .font(.custom(FontExt.semiBold.rawValue, size: 15))
                                .foregroundStyle(.white)
                            Text(vm.gAccount?.profile?.email ?? "Unknown")
                                .font(.custom(FontExt.reg.rawValue, size: 14))
                                .foregroundStyle(.white.opacity(0.32))
                        }
                        
                        Button {
                            vm.signOut()
                        } label: {
                            Image(.signOut)
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                        
                        Spacer()

                    }
                    
                    ScrollView(.vertical) {
                        ForEach(vm.foldersToDisplay, id: \.self){ folder in
                            EmailFolderView(vm: vm, folder: folder, openFolder: $openFolder)
                        }
                    }
                    .scrollIndicators(.hidden)
                    .scrollBounceBehavior(.basedOnSize)
                   
                }
                .padding(.horizontal)
            }
            
            VStack{
                Spacer()
                Button{
                    Task{
                        await vm.deleteFolder()
                    }
                } label: {
                    HStack{
                        Text("Delete selected")
                    }
                    .foregroundStyle(.white)
                    .font(.custom(FontExt.bold.rawValue, size: 15))
                    .frame(width: 299, height: 60)
                    .background(Color(hex: "#0D65E0"))
                    .clipShape(RoundedRectangle(cornerRadius: 100))
                    .offset(y: vm.selectedFolderToDelete == nil ? 150 : 0)
                }
                .animation(.easeInOut(duration: 0.5), value: vm.selectedFolderToDelete)
                .padding(.bottom)
            }
        }
        .fullScreenCover(isPresented: $openFolder){
            EmailMessagesList(vm : vm)
            
            
        }
        .onOpenURL { url in
            GIDSignIn.sharedInstance.handle(url)
        }
    }
    
}

struct EmailFolderView : View {
    @ObservedObject var vm : EmailViewModel
    @State var folder : LabelModel
    
    @Binding var openFolder : Bool
    
    var body: some View {
        ZStack{
            if vm.selectedFolderToDelete == folder {
                RoundedRectangle(cornerRadius: 19).fill(Color(hex: "#0D65E0"))
            }
            HStack{
                ZStack{
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color(hex: "#282828"))
                        .frame(width: 46, height: 32)
                    if vm.selectedFolderToDelete == folder {
                        RoundedRectangle(cornerRadius: 30)
                            .fill(.white)
                            .frame(width: 46, height: 32)
                        Image(systemName: "checkmark")
                            .resizable()
                            .frame(width: 13, height: 9)
                            .foregroundStyle(.black)
                    }
                }
                
                VStack(alignment: .leading){
                    Text(folder.name.lowercased().capitalized.replacingOccurrences(of: "Category_", with: ""))
                        .font(.custom(FontExt.semiBold.rawValue, size: 15))
                        .foregroundStyle(.white)
                    if let num = folder.messagesTotal{
                        Text("\(num) emails")
                            .font(.custom(FontExt.reg.rawValue, size: 14))
                            .foregroundStyle(.white.opacity(0.47))
                    }
                }
                
                Spacer()
                
                Button{
                    vm.messagesToDisplay = []
                    vm.selectedFolder = folder
                    openFolder = true
                } label: {
                    ZStack{
                        Circle().fill(Color(hex: "#282828"))
                            .frame(width: 30, height: 30)
                        Image(systemName: "chevron.right")
                            .resizable()
                            .frame(width: 7, height: 13)
                            .foregroundStyle(.white)
                            .bold()
                    }
                }
            }
            .padding()
            .frame(height: 71)
            .background{
                Color(hex: "#181818")
            }
            .clipShape(RoundedRectangle(cornerRadius: 19))
            .onTapGesture {
                if vm.selectedFolderToDelete == folder{
                    vm.selectedFolderToDelete = nil
                } else {
                    vm.selectedFolderToDelete = folder
                }
            }
            .animation(.easeInOut(duration: 0.5), value: vm.selectedFolderToDelete)
            .offset(x: vm.selectedFolderToDelete == folder ? 3 : 0)
        }
        .frame(height: 71)
        
    }
}

struct MessageView : View {
    @State var message : MessagesToDisplay
    @Binding var selectedMsg : [MessagesToDisplay]
    var body: some View {
        ZStack{
            if selectedMsg.contains(message){
                RoundedRectangle(cornerRadius: 19).fill(Color(hex: "#0D65E0"))
            }
            HStack{
                ZStack{
                    Circle().fill(Color(uiColor: generateColorFor(text: String(message.title.first ?? "A"))))
                    Text("\(message.title.first(where: { $0.isLetter }) ?? "A")")
                        .font(.custom(FontExt.med.rawValue, size: 20))
                        .foregroundStyle(.white)
                    
                }
                VStack(alignment: .leading){
                    HStack{
                        Text(message.title)
                            .font(.custom(FontExt.semiBold.rawValue, size: 15))
                            .foregroundStyle(.white)
                        Spacer()
                        Text(message.date)
                            .font(.custom(FontExt.reg.rawValue, size: 14))
                            .foregroundStyle(.white.opacity(0.47))
                    }
                    Text(message.text)
                        .font(.custom(FontExt.reg.rawValue, size: 14))
                        .foregroundStyle(.white.opacity(0.47))
                }
                
                Spacer()
                
                ZStack{
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color(hex: "#282828"))
                        .frame(width: 46, height: 32)
                    if selectedMsg.contains(message) {
                        RoundedRectangle(cornerRadius: 30)
                            .fill(.white)
                            .frame(width: 46, height: 32)
                        Image(systemName: "checkmark")
                            .resizable()
                            .frame(width: 13, height: 9)
                            .foregroundStyle(.black)
                    }
                }
            }
            .padding()
            .frame(height: 71)
            .background{
                Color(hex: "#181818")
            }
            .clipShape(RoundedRectangle(cornerRadius: 19))
            .onTapGesture {
                if selectedMsg.contains(message){
                    if let idx = selectedMsg.firstIndex(of: message){
                        selectedMsg.remove(at: idx)
                    }
                } else {
                    selectedMsg.append(message)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: selectedMsg)
            .offset(x: selectedMsg.contains(message) ? 3 : 0)
        }
        .frame(height: 71)
        
    }
    
    func generateColorFor(text: String) -> UIColor{
        var hash = 0
        let colorConstant = 131
        let maxSafeValue = Int.max / colorConstant
        for char in text.unicodeScalars{
            if hash > maxSafeValue {
                hash = hash / colorConstant
            }
            hash = Int(char.value) + ((hash << 5) - hash)
        }
        let finalHash = abs(hash) % (256*256*256);
        //let color = UIColor(hue:CGFloat(finalHash)/255.0 , saturation: 0.40, brightness: 0.75, alpha: 1.0)
        let color = UIColor(red: CGFloat((finalHash & 0xFF0000) >> 16) / 255.0, green: CGFloat((finalHash & 0xFF00) >> 8) / 255.0, blue: CGFloat((finalHash & 0xFF)) / 255.0, alpha: 1.0)
        return color
    }
}



#Preview {
    MessageView(message: MessagesToDisplay(id: "", title: "TikTok", text: "ADAWdAWDAWDakdmawflmawlf", date: "01/22"), selectedMsg: .constant([]))
}
