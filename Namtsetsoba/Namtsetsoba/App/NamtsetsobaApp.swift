//
//  NamtsetsobaApp.swift
//  Namtsetsoba
//
//  Created by Ani Gasitashvili on 04.04.26.
//

import SwiftUI

@main
struct NamtsetsobaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(DesignTokens.primaryGreen)
        }
    }
}
