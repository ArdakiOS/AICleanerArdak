//
//  EntitlementManager.swift
//  TruthOrDare
//
//  Created by Ardak Tursunbayev on 14.11.2024.
//

import SwiftUI

class EntitlementManager: ObservableObject {
    static let userDefaults = UserDefaults(suiteName: "group.demo.app")!
    
    @AppStorage("hasPro", store: userDefaults)
    var hasPro: Bool = false
}
