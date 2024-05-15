//
//  DoodleScripApp.swift
//  DoodleScrip
//
//  Created by leo on 2024-05-15.
//

import SwiftUI

@main
struct DoodleScripApp: App {
    var lines: ObservableArray<PointShape> = ObservableArray(array: [])
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(lines)
        }
    }
}
