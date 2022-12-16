//
//  MemorizeApp.swift
//  Memorize
//
//  Created by Amini on 09/05/22.
//

import SwiftUI
import Firebase

@main
struct MemorizeApp: App {
    // Initializinf Firebase...
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            MemoryGameView()
        }
    }
}

