//
//  QuietCalApp.swift
//  QuietCal
//
//  Created by Saglam, Fatih on 27.04.2026.
//

import SwiftUI
import SwiftData

@main
struct QuietCalApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try AppGroup.makeModelContainer()
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(modelContainer: modelContainer)
        }
    }
}
