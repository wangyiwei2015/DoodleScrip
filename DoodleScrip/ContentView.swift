//
//  ContentView.swift
//  DoodleScrip
//
//  Created by leo on 2024-05-15.
//
// Source: https://github.com/MrPaschenko/Paint

import SwiftUI
import GlassyButton

var _canvasSize: CGSize = .zero
let tmp = "\(NSHomeDirectory())/tmp/doodle.jpg"
let tmpURL = URL(filePath: "\(NSHomeDirectory())/tmp/doodle.jpg", directoryHint: .notDirectory)

struct ContentView: View {
    @EnvironmentObject var lines: ObservableArray<PointShape>
    @Namespace var namespace
    
    @AppStorage("_CFG_ACTION_COPY") var actionAfterCopy: Int = 0
    @AppStorage("_CFG_ACTION_SAVE") var actionAfterSave: Int = 0
    //@AppStorage("_CANVAS") var
    @AppStorage("_CFG_CANVAS_BG") var canvasBackgroundType: Int = 0
    @AppStorage("_CFG_CANVAS_BG_COLOR") var canvasBackgroundColorId: Int = 0
    @AppStorage("_CFG_CANVAS_BG_GRAD") var canvasBackgroundGradId: Int = 0
    @AppStorage("_CFG_CANVAS_BG_IMG") var canvasBackgroundImage: Int = 0
    
    @State var generatedImage: UIImage? = nil
    //var onSetImage: (() -> Void)?
    @State private var selectedColor: Color = .hex(
        UInt32(UserDefaults.standard.integer(forKey: "_CFG_DEF_COLOR"))
    )
    @State private var selectedWidth: CGFloat = 5
    @State var exporting: Bool = false
    @State var showsAbout = false
    @State var showsPrefs = false
    
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
                //.buttonStyle(StrokeWidthBtnStyle(weight: .light))
                //.frame(width: 60, height: 30)
                //.background(Capsule().fill())
            Button { selectedWidth = 15 }
            label: {
                Image(systemName: "scribble").frame(width: 48, height: 28)
            }.glassyButton(.gray.opacity(selectedWidth == 15 ? 1 : 0.3))
                //.buttonStyle(StrokeWidthBtnStyle(weight: .semibold))
                //.frame(width: 60, height: 30)
                //.background(Capsule().fill(Color(selectedWidth == 15 ? UIColor.systemGray3 : UIColor.systemGray5)))
            Button { selectedWidth = 25 }
            label: {
                Image(systemName: "scribble").frame(width: 48, height: 28)
            }.glassyButton(.gray.opacity(selectedWidth == 25 ? 1 : 0.3))
                //.buttonStyle(StrokeWidthBtnStyle(weight: .black))
                //.frame(width: 60, height: 30)
                //.background(Capsule().fill(Color(selectedWidth == 25 ? UIColor.systemGray3 : UIColor.systemGray5)))
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
        switch canvasBackgroundType {
        case 0:
            if canvasBackgroundColorId == 0 {
                Color(UIColor.systemBackground)
            } else {
                bgColors[canvasBackgroundColorId]
            }
        case 1:
            bgGrads[canvasBackgroundGradId]
        default: Color.white
        }
        Image(bgImgNames[canvasBackgroundImage]).resizable(resizingMode: .tile)
    }
    
    func checkName(_ checked: Bool) -> String {
        checked ? "checkmark.circle.fill" : "circle.dotted"
    }
    
    @ViewBuilder var configMenus: some View {
        Menu {
            Button("About") { showsAbout = true }
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
            Button("Settings") { showsPrefs = true }
            Button("Home") { goHome() }
        } label: {
            Image(systemName: "gear")
                .padding(.horizontal).frame(height: 30)
        }.glassyButton(.gray.opacity(0.8))
        //.buttonStyle(StrokeWidthBtnStyle(weight: .semibold))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Button { _ = lines.array.popLast() }
                    label: {
                        Image(systemName: "arrow.uturn.left").bold()
                            .frame(width: 30, height: 30)
                    }.glassyButton(.gray).disabled(lines.array.isEmpty)
                    Button { lines.array = [] }
                    label: {
                        Image(systemName: "xmark").bold()
                            .frame(width: 30, height: 30)
                    }.glassyButton(.red).disabled(lines.array.isEmpty)
                        .padding(.horizontal, 10)
                    
                    Spacer()
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
                            .padding(.horizontal).frame(height: 30)
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
            }
            .background(Color(UIColor.systemGray6).ignoresSafeArea())
            .navigationDestination(isPresented: $showsPrefs) { PrefsView() }
        }
        .overlay {
            ExportView(
                isPresented: $exporting,
                image: generatedImage
            )
        }
        .sheet(isPresented: $showsAbout) { AboutView() }
        
        //.onDisappear {
            //saveCGPointArray(lines.array, to: "_LINES_STORE")
        //}
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
