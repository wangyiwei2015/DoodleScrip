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
    
    @AppStorage("_CFG_ACTION_COPY") var actionAfterCopy: Int = 0
    @AppStorage("_CFG_ACTION_SAVE") var actionAfterSave: Int = 0
    //@AppStorage("_CANVAS") var
    
    @State var generatedImage: UIImage? = nil
    //var onSetImage: (() -> Void)?
    @State private var selectedColor: Color = .accentColor
    @State private var selectedWidth: CGFloat = 10
    @State var exporting: Bool = false
    
    @ViewBuilder var drawingToolsBar: some View {
        HStack(spacing: 15) {
            Spacer()
            ColorPicker("Stroke", selection: $selectedColor).labelsHidden().padding(.trailing)
            Button { selectedWidth = 5 }
            label: { Image(systemName: "scribble").foregroundColor(.primary) }
                .buttonStyle(StrokeWidthBtnStyle(weight: .light))
                .frame(width: 60, height: 30)
                .background(Capsule().fill(Color(selectedWidth == 10 ? UIColor.systemGray3 : UIColor.systemGray5)))
            Button { selectedWidth = 15 }
            label: { Image(systemName: "scribble").foregroundColor(.primary) }
                .buttonStyle(StrokeWidthBtnStyle(weight: .semibold))
                .frame(width: 60, height: 30)
                .background(Capsule().fill(Color(selectedWidth == 20 ? UIColor.systemGray3 : UIColor.systemGray5)))
            Button { selectedWidth = 25 }
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
    
    func checkName(_ checked: Bool) -> String {
        checked ? "checkmark.circle.fill" : "circle.dotted"
    }
    
    @ViewBuilder var configMenus: some View {
        Menu {
            Button("About") {}
            Menu("After coping") {
                Button { actionAfterCopy = 0
                } label: {
                    Label("Do nothing", systemImage: checkName(actionAfterCopy == 0))
                }
                Button { actionAfterCopy = 1
                } label: {
                    Label("Go home", systemImage: checkName(actionAfterCopy == 1))
                }
            }
            Menu("After saving image") {
                Button { actionAfterSave = 0
                } label: {
                    Label("Do nothing", systemImage: checkName(actionAfterSave == 0))
                }
                Button { actionAfterSave = 1
                } label: {
                    Label("Go to Photos", systemImage: checkName(actionAfterSave == 1))
                }
                Button { actionAfterSave = 2
                } label: {
                    Label("Go home", systemImage: checkName(actionAfterSave == 2))
                }
            }
            Button("Home") { goHome() }
        } label: {
            ZStack {
                Capsule().fill(Color.gray)
                    .frame(width: 80, height: 32)
                Image(systemName: "gear")
                    .foregroundColor(.white)
            }
        }.buttonStyle(StrokeWidthBtnStyle(weight: .semibold))
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
                configMenus
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
                    .frame(width: 120, height: 32)
                    .background(Capsule().fill(Color.accentColor).opacity(lines.array.isEmpty ? 0.5 : 1))
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
