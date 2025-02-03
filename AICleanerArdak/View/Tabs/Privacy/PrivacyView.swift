
import SwiftUI



struct PrivacyView: View {
    @StateObject var privVM = PrivacyViewModel()
    @EnvironmentObject var photoVM : PhotoGalleryViewModel
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    @State var tempPinEntered = false
    @State var pin : [String] = Array(repeating: "", count: 4)
    @State var pinIncorrect = false
    var body: some View {
        ZStack{
            Color(hex: "#0E0F10").ignoresSafeArea()
            
            VStack{
                switch privVM.pageState {
                case .firstCreatePin :
                    Text("Create a PIN")
                        .font(.custom(FontExt.semiBold.rawValue, size: 22))
                    PinCodeField(pin: $privVM.pin, vm: privVM)
                        .onChange(of: privVM.pin) { _ in
                            privVM.isPinSet()
                        }
                    
                case .firstRepeatPin :
                    VStack{
                        Text("Repeat a PIN")
                            .font(.custom(FontExt.semiBold.rawValue, size: 22))
                        PinCodeField(pin: $privVM.confirmPin, vm: privVM)
                            .onChange(of: privVM.confirmPin) { _ in
                                privVM.isPinTheSame()
                            }
                        Text("PINs are not the same")
                            .font(.custom(FontExt.semiBold.rawValue, size: 18))
                            .foregroundStyle(.red)
                            .opacity(privVM.repeatPinWrong ? 1 : 0)
                    }
                    
                case .enterExistingPin :
                    Text("Enter your PIN")
                        .font(.custom(FontExt.semiBold.rawValue, size: 22))
                    PinCodeField(pin: $pin, vm: privVM)
                        .onChange(of: pin) { _ in
                            if pin.joined().count == 4 {
                                if pin.joined() == privVM.pin.joined() {
                                    privVM.pageState = .view
                                } else {
                                    pinIncorrect = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                                        pin = Array(repeating: "", count: 4)
                                        pinIncorrect = false
                                    }
                                }
                            }
                        }
                    
                    Text("PINs are not the same")
                        .font(.custom(FontExt.semiBold.rawValue, size: 18))
                        .foregroundStyle(.red)
                        .opacity(pinIncorrect ? 1 : 0)
                    
                    
                case .secondRepeatPin :
                    Text("Repeat a PIN")
                        .font(.custom(FontExt.semiBold.rawValue, size: 22))
                    PinCodeField(pin: $privVM.secondRepeatPin, vm: privVM)
                        .onChange(of: privVM.secondRepeatPin) { _ in
                            if privVM.secondRepeatPin.joined().count == 4 {
                                if privVM.secondRepeatPin.joined() == privVM.pin.joined(){
                                    privVM.pin = Array(repeating: "", count: 4)
                                    privVM.pageState = .secondCreatePin
                                } else {
                                    privVM.repeatPinWrong = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                                        privVM.secondRepeatPin = Array(repeating: "", count: 4)
                                        privVM.repeatPinWrong = false
                                    }
                                }
                            }
                        }
                    Text("PINs are not the same")
                        .font(.custom(FontExt.semiBold.rawValue, size: 18))
                        .foregroundStyle(.red)
                        .opacity(privVM.repeatPinWrong ? 1 : 0)
                    
                case .secondCreatePin :
                    Text("Create a PIN")
                        .font(.custom(FontExt.semiBold.rawValue, size: 22))
                    PinCodeField(pin: $privVM.pin, vm: privVM)
                        .onChange(of: privVM.pin) { _ in
                            if privVM.pin.joined().count == 4 {
                                privVM.pageState = .view
                                privVM.savePin()
                            }
                        }
                    
                case .view :
                    HStack{
                        HStack{
                            Text("\(privVM.photoCount) photo")
                                .font(.custom(FontExt.reg.rawValue, size: 14))
                            Rectangle()
                                .frame(width: 1)
                            Text("\(privVM.videoCount) video")
                                .font(.custom(FontExt.reg.rawValue, size: 14))
                        }
                        .frame(height: 17)
                        .foregroundStyle(.white.opacity(0.47))
                        .padding()
                        .background(Color(hex: "#181818"))
                        .clipShape(RoundedRectangle(cornerRadius: 31))
                        
                        Spacer()
                        
                        Button{
                            privVM.pageState = .secondRepeatPin
                        } label: {
                            Image("Lock")
                                .resizable()
                                .frame(width: 21, height: 20)
                                .padding()
                                .background(Color(hex: "#181818"))
                                .clipShape(Circle())
                        }
                        
                    }
                    if privVM.savedPhotos.isEmpty{
                        Spacer()
                        Image("Empty")
                            .resizable()
                            .frame(width: 112, height: 112)
                        Text("No private files")
                            .font(.custom(FontExt.med.rawValue, size: 16))
                            .foregroundStyle(Color(hex: "#5E5E5E"))
                        
                        Button{
                            privVM.photoLibPresented.toggle()
                        } label: {
                            HStack{
                                Image(systemName: "plus")
                                Text("Add new")
                            }
                            .font(.custom(FontExt.bold.rawValue, size: 15))
                            .frame(width: 242, height: 54)
                            .background(Color(hex: "#0D65E0"))
                            .clipShape(RoundedRectangle(cornerRadius: 49))
                        }
                        .padding(.top, 20)
                        Spacer()
                    }
                    else {
                        if privVM.uploading{
                            UploadingView()
                        } else {
                            ZStack(alignment: .bottom) {
                                VStack{
                                    GridView(assets: $privVM.savedPhotos)
                                }
                                Button{
                                    privVM.photoLibPresented.toggle()
                                } label: {
                                    HStack{
                                        Image(systemName: "plus")
                                        Text("Add new")
                                    }
                                    .font(.custom(FontExt.bold.rawValue, size: 15))
                                    .frame(width: 242, height: 54)
                                    .background(Color(hex: "#0D65E0"))
                                    .clipShape(RoundedRectangle(cornerRadius: 49))
                                }
                                .padding(.bottom, 20)
                            }
                        }
                        
                    }
                    
                }
                
                
            }
            .padding(.horizontal, 12)
            .animation(.easeInOut(duration: 0.3), value: privVM.uploading)
            .animation(.easeInOut(duration: 0.3), value: privVM.pageState)
            .foregroundStyle(.white)
            .sheet(isPresented: $privVM.photoLibPresented, onDismiss: {
                privVM.copySelectedPhotosToLocalStorage()
            }, content: {
                PrivacyGalleryView(viewModel: photoVM, selectedPhotos: $privVM.selectedPhotos)
                    .presentationDetents([.fraction(0.9)])
                    .presentationCornerRadius(20)
                    .presentationDragIndicator(.visible)
            })
        }
        .onAppear{
            if UserDefaults.standard.bool(forKey: "usePin") == false {
                privVM.pageState = .view
                privVM.loadSavedPhotosFromLocalStorage()
            }
        }
    }
    
    #Preview {
        NavView(curPage: .privacy)
    }
    
    
    struct PinCodeField : View {
        @Binding var pin : [String]
        @ObservedObject var vm : PrivacyViewModel
        @FocusState var focusField : Int?
        var body: some View {
            HStack(spacing: 15){
                ForEach(0..<4) { index in
                    ZStack{
                        Circle().fill(Color(hex: "#181818"))
                        SecureField("", text: $pin[index])
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.blue)
                            .font(.largeTitle)
                            .focused($focusField, equals: index)
                            .tag(index)
                            .onChange(of: pin[index]) { newValue in
                                if !newValue.isEmpty {
                                    if index == 3 {
                                        focusField = nil
                                    } else {
                                        focusField = (focusField ?? 0) + 1
                                    }
                                } else {
                                    focusField = (focusField ?? 0) - 1
                                }
                            }
                    }
                    .frame(width: 53, height: 53)
                }
            }
        }
    }
}
