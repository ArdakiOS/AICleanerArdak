//
//  CalendarViewModel.swift
//  AICleanerArdak
//
//  Created by Ardak Tursunbayev on 15.01.2025.
//

import SwiftUI
import EventKit

@MainActor
class CalendarViewModel : ObservableObject {
    let eventStore = EKEventStore()
    var titles: [String] = []
    var startDates: [Date] = []
    var endDates: [Date] = []
    
    @Published var allEvents : [EKEvent] = []
    @Published var selectedEvents : Set<EKEvent> = []
    
    @Published var shouldRequestPermission = false
    
    init() {
        fetchEvents()
    }
    
     func fetchEvents() -> Void {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        switch status {
        case .notDetermined:
            shouldRequestPermission = true
            print("in class\(shouldRequestPermission)")
        case .authorized: fetchEventsFromCalendar()
        case .denied: print("Access denied")
        default: break
        }
    }
    
    func requestAccessToCalendar() {
        eventStore.requestAccess(to: EKEntityType.event) { (_, _) in
            self.fetchEventsFromCalendar()
        }
    }
    @MainActor
    func fetchEventsFromCalendar() -> Void {
        for calendar in eventStore.calendars(for: .event) {
            let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
            let oneMonthAfter = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
            let predicate = eventStore.predicateForEvents(
                withStart: oneMonthAgo,
                end: oneMonthAfter,
                calendars: [calendar]
            )
            let events = eventStore.events(matching: predicate)
            for event in events {
                DispatchQueue.main.async{
                    self.allEvents.append(event)
                }
            }
            
        }
        DispatchQueue.main.async{
            self.shouldRequestPermission = false
        }
        // Print the event titles so check if everything works correctly
        print(allEvents)
    }
    
    func removeEvent() {
        for events in selectedEvents {
            do{
                try eventStore.remove(events, span: .thisEvent)
                withAnimation {
                    allEvents.remove(at: allEvents.firstIndex(of: events)!)
                }
            } catch {
                print(error)
            }
        }
    }
}
