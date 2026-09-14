//
//  MyDayApp.swift
//  MyDay
//
//  Created by Apple on 08/09/26.
//

import SwiftUI
import SwiftData
import AppIntents

@main
struct MyDayApp: App {
    private let database = AppDatabase.shared

    init() {
        // Required by Apple: registers MyDayShortcuts with iOS Siri & Shortcuts system.
        // Without this call, the OS cannot discover our AppShortcutsProvider and will
        // show "Unable to run App Shortcut" errors.
        MyDayShortcuts.updateAppShortcutParameters()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(database.container)
    }
}
