//
//  Model.swift
//  DoodleScrip
//
//  Created by leo on 2024-05-15.
//

import Foundation
import SwiftUI
import Combine

class ObservableArray<T>: ObservableObject {
    @Published var array:[T] = []
    init(array: [T]) {
        self.array = array
    }
}

class MyShape: ObservableObject, Identifiable {
    let id = UUID()
    var color: Color
    var lineWidth: CGFloat
    
    init(color: Color, lineWidth: CGFloat) {
        self.color = color
        self.lineWidth = lineWidth
    }
}

class PointShape: MyShape {
    var points: [CGPoint]
    
    init(points: [CGPoint], color: Color, lineWidth: CGFloat) {
        self.points = points
        super.init(color: color, lineWidth: lineWidth)
    }
}
