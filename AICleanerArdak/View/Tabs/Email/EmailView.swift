
import SwiftUI

struct EmailView: View {
    @State private var userName: String = ""
    var body: some View {
        ZStack{
            Color(hex: "#0E0F10").ignoresSafeArea()
            VStack{
                Text("Page EmailView")
                    .foregroundStyle(.white)
            }
        }
        .onAppear {
            
        }
    }
    
}



#Preview {
    EmailView()
}
