//
//  QuickActions.swift
//  QuietCal
//
//  Home Screen quick actions (long-press the app icon) and the plumbing that
//  delivers them into SwiftUI.
//

import SwiftUI
import UIKit

// MARK: - Quick actions

/// The Home Screen quick actions QuietCal exposes when the user long-presses
/// the app icon. Raw values must match the `UIApplicationShortcutItemType`
/// entries declared in Info.plist.
enum QuickAction: String, CaseIterable {
    /// Opens the app straight into the Add Meal sheet.
    case logMeal = "mfsaglam.QuietCal.logMeal"
    /// Opens the app and pushes the History screen.
    case history = "mfsaglam.QuietCal.history"

    init?(_ shortcutItem: UIApplicationShortcutItem) {
        self.init(rawValue: shortcutItem.type)
    }
}

// MARK: - Router

/// Bridges Home Screen quick actions, which are delivered to the UIKit scene
/// delegate, into SwiftUI. Views observe `pending` and clear it once handled.
@MainActor
@Observable
final class QuickActionRouter {
    static let shared = QuickActionRouter()

    /// The most recent quick action awaiting handling, or `nil` when there's
    /// nothing pending. Set by the scene delegate, consumed by `HomeView`.
    var pending: QuickAction?

    private init() {}

    /// Records a quick action for the UI to handle. Returns whether the
    /// shortcut was recognized, as the scene delegate callback requires.
    @discardableResult
    func enqueue(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        guard let action = QuickAction(shortcutItem) else { return false }
        pending = action
        return true
    }
}

// MARK: - UIKit bridge

/// SwiftUI apps don't receive scene-delegate callbacks by default. Installing
/// this app delegate lets us point new scenes at `QuickActionSceneDelegate`,
/// which is where Home Screen quick actions are delivered.
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(
            name: nil,
            sessionRole: connectingSceneSession.role
        )
        configuration.delegateClass = QuickActionSceneDelegate.self
        return configuration
    }
}

/// Receives quick actions and forwards them to `QuickActionRouter`. SwiftUI
/// still owns the window and its content; this delegate only handles the
/// shortcut callbacks.
final class QuickActionSceneDelegate: NSObject, UIWindowSceneDelegate {
    /// Cold launch: the app wasn't running, so the shortcut arrives here.
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        if let shortcutItem = connectionOptions.shortcutItem {
            QuickActionRouter.shared.enqueue(shortcutItem)
        }
    }

    /// Warm launch: the app was already running in the background.
    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        completionHandler(QuickActionRouter.shared.enqueue(shortcutItem))
    }
}
