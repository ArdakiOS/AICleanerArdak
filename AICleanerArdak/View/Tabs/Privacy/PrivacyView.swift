
import SwiftUI

struct PrivacyView: View {
    @StateObject var privVM = PrivacyViewModel()
    @EnvironmentObject var photoVM : PhotoGalleryViewModel
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    var body: some View {
        ZStack{
            Color(hex: "#0E0F10").ignoresSafeArea()
            VStack{
                if !privVM.isConfirmed {
                    if !privVM.isPinEntered {
                        Text("Create a PIN")
                            .font(.custom(FontExt.semiBold.rawValue, size: 22))
                        PinCodeField(pin: $privVM.pin, vm: privVM, repeatingPin: false)
                    }
                    else {
                        Text("Repeat a PIN")
                            .font(.custom(FontExt.semiBold.rawValue, size: 22))
                        PinCodeField(pin: $privVM.confirmPin, vm: privVM, repeatingPin: true)
                    }
                    Text("PINs are not the same")
                        .font(.custom(FontExt.semiBold.rawValue, size: 18))
                        .foregroundStyle(.red)
                        .opacity(privVM.repeatPinWrong ? 1 : 0)
                    
                }
                else {
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
                            //
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
            .animation(.easeInOut(duration: 1), value: privVM.isPinEntered)
            .animation(.easeInOut(duration: 1), value: privVM.isConfirmed)
            .animation(.easeInOut(duration: 1), value: privVM.uploading)
        }
        .foregroundStyle(.white)
        .sheet(isPresented: $privVM.photoLibPresented, onDismiss: {
            privVM.copySelectedPhotosToLocalStorage()
        }, content: {
            PhotoGalleryView(viewModel: photoVM, selectedPhotos: $privVM.selectedPhotos, displayOptions: .all)
                .presentationDetents([.fraction(0.9)])
                .presentationCornerRadius(20)
                .presentationDragIndicator(.visible)
        })
    }
}

#Preview {
    NavView(curPage: .privacy)
}


struct PinCodeField : View {
    @Binding var pin : [String]
    @ObservedObject var vm : PrivacyViewModel
    @FocusState var focusField : Int?
    @State var repeatingPin : Bool
    var body: some View {
        HStack{
            ForEach(0..<4) { index in
                ZStack{
                    Circle().fill(Color(hex: "#181818"))
                    SecureField("", text: $pin[index])
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.blue)
                        .font(.largeTitle)
                        .focused($focusField, equals: index)
                        .tag(index)
                        .onChange(of: pin[index]) { newValue in
                            if !newValue.isEmpty {
                                if index == 3 {
                                    focusField = nil
                                    if repeatingPin{
                                        if !vm.isPinTheSame() {
                                            vm.repeatPinWrong = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                                                pin = Array(repeating: "", count: 4)
                                            }
                                        }
                                    }
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
