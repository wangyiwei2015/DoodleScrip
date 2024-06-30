//
//  DoodleScripApp.swift
//  DoodleScrip
//
//  Created by leo on 2024-05-15.
//

import SwiftUI

@main
struct DoodleScripApp: App {
    var lines: ObservableArray<PointShape> = ObservableArray(
        array: []//readCGPointArray(for: "_LINES_STORE")
    )
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(lines)
        }
    }
}

@inlinable func goHome() {
    UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
}
