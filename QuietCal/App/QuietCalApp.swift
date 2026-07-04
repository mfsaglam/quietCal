//
//  QuietCalApp.swift
//  QuietCal
//
//  Created by Saglam, Fatih on 27.04.2026.
//

import SwiftUI
import SwiftData
import AppIntents

@main
struct QuietCalApp: App {
    /// Installs an app delegate so new scenes get a delegate that receives
    /// Home Screen quick actions (SwiftUI doesn't deliver these by default).
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try AppGroup.makeModelContainer()
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
        // Register the App Shortcuts so Siri/Spotlight pick up any phrase or
        // parameter changes on launch.
        QuietCalShortcuts.updateAppShortcutParameters()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(modelContainer: modelContainer)
        }
    }
}
