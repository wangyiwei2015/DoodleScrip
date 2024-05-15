//
//  ContentView.swift
//  DoodleScrip
//
//  Created by leo on 2024-05-15.
//
// Source: https://github.com/MrPaschenko/Paint

import SwiftUI

var _canvasSize: CGSize = .zero
let tmp = "\(NSHomeDirectory())/tmp/doodle.jpg"
let tmpURL = URL(filePath: "\(NSHomeDirectory())/tmp/doodle.jpg", directoryHint: .notDirectory)

struct ContentView: View {
    @EnvironmentObject var lines: ObservableArray<PointShape>
    @Namespace var namespace
    
    @State var generatedImage: UIImage? = nil
    //var onSetImage: (() -> Void)?
    @State private var selectedColor: Color = .accentColor
    @State private var selectedWidth: CGFloat = 10
    @State var exporting: Bool = false
    
    @ViewBuilder var drawingToolsBar: some View {
        HStack(spacing: 15) {
            Spacer()
            ColorPicker("Stroke", selection: $selectedColor).labelsHidden().padding(.trailing)
            Button { selectedWidth = 10 }
            label: { Image(systemName: "scribble").foregroundColor(.primary) }
                .buttonStyle(StrokeWidthBtnStyle(weight: .light))
                .frame(width: 60, height: 30)
                .background(Capsule().fill(Color(selectedWidth == 10 ? UIColor.systemGray3 : UIColor.systemGray5)))
            Button { selectedWidth = 20 }
            label: { Image(systemName: "scribble").foregroundColor(.primary) }
                .buttonStyle(StrokeWidthBtnStyle(weight: .semibold))
                .frame(width: 60, height: 30)
                .background(Capsule().fill(Color(selectedWidth == 20 ? UIColor.systemGray3 : UIColor.systemGray5)))
            Button { selectedWidth = 30 }
            label: { Image(systemName: "scribble").foregroundColor(.primary) }
                .buttonStyle(StrokeWidthBtnStyle(weight: .black))
                .frame(width: 60, height: 30)
                .background(Capsule().fill(Color(selectedWidth == 30 ? UIColor.systemGray3 : UIColor.systemGray5)))
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
        }//.aspectRatio(1, contentMode: .fit)
    }
    
    var body: some View {
        VStack {
            HStack {
                Button { _ = lines.array.popLast() }
                label: { Image(systemName: "arrow.uturn.left").bold().foregroundColor(.white) }
                    .frame(width: 32, height: 32)
                    .background(Capsule().fill(Color.gray).opacity(lines.array.isEmpty ? 0.5 : 1))
                    .disabled(lines.array.isEmpty)
                Button { lines.array = [] }
                label: { Image(systemName: "xmark").bold().foregroundColor(.white) }
                    .frame(width: 32, height: 32)
                    .background(Capsule().fill(lines.array.isEmpty ? Color.gray : Color.red))
                    .disabled(lines.array.isEmpty)
                    .padding(.horizontal, 10)
                Spacer()
                //Text("Scrip").font(.title2)
                Spacer()
                Button {
                    let renderer = ImageRenderer(
                        content: drawingCanvas.frame(
                            width: _canvasSize.width, height: _canvasSize.height
                        ).background(Color.white)
                    )
                    generatedImage = renderer.uiImage!
                    try? FileManager.default.removeItem(at: tmpURL)
                    try! generatedImage?.jpegData(compressionQuality: 1.0)!.write(to: tmpURL, options: .atomic)
                    withAnimation {
                        exporting = true
                    }
                } label: {
                    Label("Export", systemImage: "checkmark")
                }.buttonStyle(StrokeWidthBtnStyle(weight: .semibold))
                    .frame(width: 128, height: 32)
                    .background(Capsule().fill(Color.accentColor))
                    .foregroundColor(.white)
                    .disabled(lines.array.isEmpty)
            }.padding(.horizontal)
            //Spacer()
            ZStack {
                drawingCanvas
                    .gesture(
                        DragGesture(
                            minimumDistance: 0, coordinateSpace: .local
                        ).onChanged(updateGesture(_:))
                    )
//                if !exporting {
//                    if let img = generatedImage {
//                        Image(uiImage: img).resizable()
//                            .matchedGeometryEffect(id: "doodle", in: namespace, properties: .frame)
//                    }
//                }
            }
            .background(Color.white).padding(2)
            .background(Color(UIColor.systemGray5))
            .padding(.horizontal)
            drawingToolsBar.padding([.horizontal, .bottom])
            
            //Spacer()
        }.background(Color(UIColor.systemGray6).ignoresSafeArea())
        
        .overlay {
            ExportView(
                isPresented: $exporting,
                image: generatedImage
            )
        }
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

struct StrokeWidthBtnStyle: ButtonStyle {
    var weight: Font.Weight
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 20, weight: weight))
    }
}

#Preview {
    var lines: ObservableArray<PointShape> = ObservableArray(array: [])
    return ContentView().environmentObject(lines)
}
