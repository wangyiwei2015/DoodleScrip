//
//  ScripClipApp.swift
//  ScripClip
//
//  Created by leo on 2025.12.16.
//

import SwiftUI

@main
struct ScripClipApp: App {
    var lines: ObservableArray<PointShape> = ObservableArray(
        array: []
    )
    
    var body: some Scene {
        WindowGroup {
            ClipView().environmentObject(lines)
        }
    }
}
