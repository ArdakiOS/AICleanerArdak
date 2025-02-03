
import SwiftUI
import EventKit

struct CalendarView: View {
    @StateObject var vm = CalendarViewModel()
    var body: some View {
        ZStack(alignment: .bottom){
            Color(hex: "#0E0F10").ignoresSafeArea()
            VStack{
                
                if vm.shouldRequestPermission {
                    PremiumBanner()
                    Spacer()
                    Button{
                        vm.requestAccessToCalendar()
                    } label: {
                        HStack{
                            Text("Allow's calendar")
                        }
                        .foregroundStyle(.white)
                        .font(.custom(FontExt.bold.rawValue, size: 15))
                        .frame(width: 242, height: 54)
                        .background(Color(hex: "#0D65E0"))
                        .clipShape(RoundedRectangle(cornerRadius: 100))
                    }
                    Spacer()
                }
                else {
                    ScrollView(.vertical) {
                        PremiumBanner()
                        HStack{
                            Text("My calendar")
                                .font(.custom(FontExt.semiBold.rawValue, size: 18))
                                .foregroundStyle(.white)
                            
                            Spacer()
                            
                            Button{
                                vm.selectedEvents = Set(vm.allEvents)
                            }label: {
                                Text("Select all")
                                    .font(.custom(FontExt.reg.rawValue, size: 15))
                                    .foregroundStyle(Color(hex: "#0D65E0"))
                            }
                            
                        }
                        .padding(.vertical)
                        LazyVStack(spacing: 10){
                            ForEach(vm.allEvents, id: \.self) {row in
                                CalendarRow(row: row, selectedEvents: $vm.selectedEvents)
                                    .onTapGesture {
                                        if vm.selectedEvents.contains(row){
                                            vm.selectedEvents.remove(row)
                                        } else {
                                            vm.selectedEvents.insert(row)
                                        }
                                    }
                            }
                            Rectangle().fill(Color.clear).frame(height: 92)
                        }
                    }
                    .scrollIndicators(.hidden)
                }
                
            }
            
            
            .padding(.horizontal)
            
            Button{
                vm.removeEvent()
            } label: {
                HStack{
                    Text("Delete selected")
                }
                .foregroundStyle(.white)
                .font(.custom(FontExt.bold.rawValue, size: 15))
                .frame(width: 299, height: 60)
                .background(Color(hex: "#0D65E0"))
                .clipShape(RoundedRectangle(cornerRadius: 100))
                .offset(y: vm.selectedEvents.isEmpty ? 150 : 0)
            }
            .animation(.easeInOut(duration: 0.5), value: vm.selectedEvents)
            .padding(.bottom)
        }
        
        
    }
    
}

struct CalendarRow : View {
    @State var row : EKEvent
    @Binding var selectedEvents : Set<EKEvent>
    var body: some View {
        ZStack{
            if selectedEvents.contains(row){
                RoundedRectangle(cornerRadius: 19).fill(Color(hex: "#0D65E0"))
            }
            HStack{
                VStack(alignment: .leading){
                    Text(row.title)
                        .font(.custom(FontExt.semiBold.rawValue, size: 14))
                        .foregroundStyle(.white)
                    Spacer()
                    Text(formatDateToYearMonthDay(date: row.startDate))
                        .font(.custom(FontExt.reg.rawValue, size: 14))
                        .foregroundStyle(.white.opacity(0.47))
                    
                }
                Spacer()
                
                
                ZStack{
                    if selectedEvents.contains(row){
                        RoundedRectangle(cornerRadius: 30).fill(.white)
                        Image(systemName: "checkmark")
                            .resizable()
                            .frame(width: 13, height: 9)
                            .foregroundStyle(.black)
                    }
                    else {
                        RoundedRectangle(cornerRadius: 30).fill(Color(hex: "#282828"))
                    }
                    
                }
                
                .frame(width: 46, height: 32)
                
                
            }
            .padding()
            .background(Color(hex: "#181818"))
            .clipShape(RoundedRectangle(cornerRadius: 19))
            .offset(x: selectedEvents.contains(row) ? 3 : 0)
        }
        .animation(.easeInOut(duration: 0.5), value: selectedEvents)
        .frame(height: 92)
        
    }
    
    private func formatDateToYearMonthDay(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

#Preview {
    CalendarView()
}
