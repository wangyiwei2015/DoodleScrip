//
//  ContentView.swift
//  DoodleScrip
//
//  Created by leo on 2024-05-15.
//

import SwiftUI
import GlassyButton
import Combine
import UniformTypeIdentifiers

var _canvasSize: CGSize = .zero
let tmp = "\(NSHomeDirectory())/tmp/doodleclip.jpg"
let tmpURL = URL(filePath: "\(NSHomeDirectory())/tmp/doodleclip.jpg", directoryHint: .notDirectory)

struct ClipView: View {
    @EnvironmentObject var lines: ObservableArray<PointShape>
    @Namespace var namespace
    
    @Environment(\.openURL) var openURL
    
    @State private var selectedColor: Color = .accentColor
    @State private var selectedWidth: CGFloat = 5
    @State var sharingItem: UIImage? = nil
    
    @ViewBuilder var drawingToolsBar: some View {
        HStack(spacing: 15) {
            Spacer()
            Circle().fill(.gray.opacity(0.2)).frame(width: 40, height: 40)
                .overlay {
                    ColorPicker("Stroke", selection: $selectedColor).labelsHidden()
                }.padding(.trailing)
            Button { selectedWidth = 5 }
            label: {
                Image(systemName: "scribble").frame(width: 48, height: 28)
            }.glassyButton(.gray.opacity(selectedWidth == 5 ? 1 : 0.3))
            Button { selectedWidth = 15 }
            label: {
                Image(systemName: "scribble").frame(width: 48, height: 28)
            }.glassyButton(.gray.opacity(selectedWidth == 15 ? 1 : 0.3))
            Button { selectedWidth = 25 }
            label: {
                Image(systemName: "scribble").frame(width: 48, height: 28)
            }.glassyButton(.gray.opacity(selectedWidth == 25 ? 1 : 0.3))
            Spacer()
        }
    }
    
    @ViewBuilder var drawingCanvas: some View {
        Canvas { context, size in
            if _canvasSize == .zero { _canvasSize = size }
            for line in lines.array {
                var path = Path()
                path.addLines(line.points)
                context.stroke(
                    path, with: .color(line.color), lineWidth: line.lineWidth
                )
            }
        }.background(canvasBackground)
    }
    
    @ViewBuilder var canvasBackground: some View {
        Color(uiColor: .systemBackground)
    }
    
    func checkName(_ checked: Bool) -> String {
        checked ? "checkmark.circle.fill" : "circle.dotted"
    }
    
    var body: some View {
        VStack {
            HStack {
                Button { lines.array = [] }
                label: {
                    Image(systemName: "trash.fill").bold()
                        .frame(width: 30, height: 30)
                }.glassyButton(.red).disabled(lines.array.isEmpty)
                
                Spacer()
                
                Button {
                    openURL(URL(string: "https://apps.apple.com/us/app/id6502684688")!)
                } label: {
                    Label("Get app", systemImage: "app.gift.fill")
                        .padding(.horizontal).frame(height: 30)
                }.glassyButton(.blue)
                
                Spacer()
                
                Button {
                    let generatedImage = ImageRenderer(
                        content: drawingCanvas.frame(
                            width: _canvasSize.width, height: _canvasSize.height
                        ).background(Color.white)
                    ).uiImage!
                    UIPasteboard.general.image = generatedImage
                    try? FileManager.default.removeItem(at: tmpURL)
                    try! generatedImage.jpegData(compressionQuality: 0.8)!.write(to: tmpURL, options: .atomic)
                    sharingItem = generatedImage
                } label: {
                    Image(systemName: "checkmark")
                        .frame(width: 30, height: 30)
                }.glassyButton(.accentColor).disabled(lines.array.isEmpty)
            }.padding(.horizontal)
            //Spacer()
            ZStack {
                drawingCanvas
                    .gesture(
                        DragGesture(
                            minimumDistance: 0, coordinateSpace: .local
                        ).onChanged(updateGesture(_:))
                    )
            }
            .background(Color.white).padding(2)
            .background(Color(UIColor.systemGray5))
            .padding(.horizontal)
            drawingToolsBar.padding([.horizontal, .bottom])
        }
        .background(Color(UIColor.systemGray6).ignoresSafeArea())
        .fileExporter(
            isPresented: Binding(
                get: { sharingItem != nil },
                set: { if !$0 { sharingItem = nil }}
            ), item: tmpURL, contentTypes: [.jpeg], onCompletion: { _ in }
        )
    }
    
    @inlinable func updateGesture(_ value: DragGesture.Value) {
        let newPoint = value.location
        if value.translation.width + value.translation.height == 0 {
            lines.array.append(
                PointShape(
                    points: [newPoint],
                    color: selectedColor,
                    lineWidth: selectedWidth
                )
            )
        } else {
            let index = lines.array.count - 1
            lines.objectWillChange.send()
            lines.array[index].points.append(newPoint)
        }
    }
}

#Preview {
    var lines: ObservableArray<PointShape> = ObservableArray(array: [])
    return ClipView().environmentObject(lines)
}

