//
//  FerreControlApp.swift
//  FerreControl
//
//  Created by mierlin on 17/05/2026.
//

import SwiftUI
import CoreData

@main
struct FerreControlApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
