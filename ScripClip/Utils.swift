//
//  Utils.swift
//  DoodleScrip
//
//  Created by leo on 2025.12.16.
//

import Foundation
import SwiftUI
import Combine
import UniformTypeIdentifiers

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

// Image drag and drop

struct TransferrableUIImage: Transferable {
    var image: UIImage
    init(_ image: UIImage) {self.image = image}
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .image) { asset in
            asset.image.jpegData(compressionQuality: 1.0)!
        }
        DataRepresentation(exportedContentType: .png) { asset in
            asset.image.pngData()!
        }
        DataRepresentation(exportedContentType: .jpeg) { asset in
            asset.image.jpegData(compressionQuality: 1.0)!
        }
    }
}
