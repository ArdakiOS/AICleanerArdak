
import SwiftUI

struct UploadingView: View {
    let timer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()
    @State var progress = 0
    let text = "Wait a second, let's add..."
    var body: some View {
        ZStack{
            Color(hex: "#0E0F10").ignoresSafeArea()
            VStack{
                Spacer()
                Text("\(progress)%")
                    .foregroundStyle(.white)
                    .font(.custom(FontExt.bold.rawValue, size: 87))
                Text(text)
                    .font(.custom(FontExt.reg.rawValue, size: 14))
                    .foregroundStyle(.white.opacity(0.47))
                Spacer()
                
                ZStack(alignment: .leading){
                    Color(hex: "#272727")
                    Color(hex: "#0D65E0")
                        .frame(width: CGFloat(180 * progress) / 100)
                }
                .frame(width: 180, height: 5)
                .clipShape(RoundedRectangle(cornerRadius: 100))
            }
            .padding(.vertical, 20)
            .onReceive(timer) { _ in
                withAnimation(.snappy(duration: 0.05)) {
                    if progress < 93 {
                        progress += 1
                    }
                }
                
            }
        }
    }
}

#Preview {
    UploadingView()
}
