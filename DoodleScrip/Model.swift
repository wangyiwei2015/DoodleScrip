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

// Saving PointSaheps

//struct CGPointWrapper: Codable {
//    let point: CGPoint
//    init(point: CGPoint) {
//        self.point = point
//    }
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(point.x, forKey: .x)
//        try container.encode(point.y, forKey: .y)
//    }
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        let x = try container.decode(Double.self, forKey: .x)
//        let y = try container.decode(Double.self, forKey: .y)
//        point = CGPoint(x: x, y: y)
//    }
//    private enum CodingKeys: String, CodingKey {
//        case x, y
//    }
//}
//
//struct PointShapeWrapper: Codable {
//    let shape: PointShape
//    init(shape: PointShape) {
//        self.shape = shape
//    }
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(shape.id, forKey: .id)
//        try container.encode(shape.points.map{CGPointWrapper(point: $0)}, forKey: .pt)
//        try container.encode(shape.lineWidth, forKey: .w)
//        shape.color.resolve(in: EnvironmentValues)
//    }
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        let x = try container.decode(Double.self, forKey: .x)
//        let y = try container.decode(Double.self, forKey: .y)
//        point = CGPoint(x: x, y: y)
//    }
//    private enum CodingKeys: String, CodingKey {
//        case id, pt, w, r, g, b, a
//    }
//}
//
//
//
//func saveCGPointArray(_ data: [CGPoint], to key: String, in ud: UserDefaults = .standard) {
//    let dict = data.map { CGPointWrapper(point: $0) }
//    ud.set(dict, forKey: key)
//}
//
//func readCGPointArray(for key: String, in ud: UserDefaults = .standard) -> [CGPoint] {
//    if let array = ud.array(forKey: key) as? [CGPointWrapper] {
//        return array.map { $0.point }
//    }
//    return []
//}
