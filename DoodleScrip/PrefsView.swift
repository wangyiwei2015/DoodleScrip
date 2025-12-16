//
//  PrefsView.swift
//  DoodleScrip
//
//  Created by leo on 2024-08-09.
//

import SwiftUI

struct PrefsView: View {
    @Environment(\.dismiss) var dismiss
    //@Environment(\.self) var env
    
    @AppStorage("_CFG_ACTION_COPY") var actionAfterCopy: Int = 0
    @AppStorage("_CFG_ACTION_SAVE") var actionAfterSave: Int = 0
    @AppStorage("_CFG_DEF_COLOR") var defColor: Int = 0xFF333333
    
    @State var defaultColor: Color = .hex(
        UInt32(UserDefaults.standard.integer(forKey: "_CFG_DEF_COLOR"))
    )
    
    var body: some View {
        VStack {
//            HStack {
//                Button {
//                    dismiss()
//                } label: {
//                    Label("Back", systemImage: "checkmark") //chevron.left
//                }.buttonStyle(StrokeWidthBtnStyle(weight: .semibold))
//                    .frame(width: 100, height: 32)
//                    .background(Capsule().fill(Color.gray))
//                    .foregroundColor(.white)
//                Divider().padding(.horizontal, 10)
//                Text("Settings").font(.title2).bold()
//                Spacer()
//            }
//            .frame(height: 32)
//            .padding(.horizontal)
            
            VStack(spacing: 10) {
                HStack {
                    Text("After coping")
                    Picker("After coping", selection: $actionAfterCopy) {
                        Text("Do nothing").tag(0)
                        Text("Go home").tag(1)
                    }.pickerStyle(.menu)
                    Spacer()
                }
                
                HStack {
                    Text("After saving image")
                    Picker("After saving image", selection: $actionAfterSave) {
                        Text("Do nothing").tag(0)
                        Text("Go to Photos").tag(1)
                        Text("Go home").tag(2)
                    }.pickerStyle(.menu)
                    Spacer()
                }
                
                HStack {
                    ColorPicker("Default color", selection: $defaultColor)
                        .frame(width: 160)
                        .onChange(of: defaultColor) { newValue in
                            //let res = newValue.resolve(in: env)
                            var a: CGFloat = 0.0
                            var r: CGFloat = 0.0
                            var g: CGFloat = 0.0
                            var b: CGFloat = 0.0
                            UIColor(newValue).getRed(&r, green: &g, blue: &b, alpha: &a)
                            var storedColor: Int = 0
                            storedColor += Int(255 * a) << 24
                            storedColor += Int(255 * r) << 16
                            storedColor += Int(255 * g) << 8
                            storedColor += Int(255 * b) << 0
                            defColor = storedColor
                        }
                    Spacer()
                }
                
                HStack {
                    Text("Canvas paper")
                    Picker("Canvas background", selection: $canvasBackgroundType) {
                        Text("Color").tag(0)
                        Text("Gradient").tag(1)
                    }.pickerStyle(.segmented).animation(.easeInOut, value: canvasBackgroundType)
                    Spacer()
                }.padding(.vertical)
                
                switch canvasBackgroundType {
                case 0: bgColorSel
                        .transition(.move(edge: .leading))
                        .animation(.easeInOut, value: canvasBackgroundType)
                case 1: bgGradientSel
                        .transition(.move(edge: .trailing))
                        .animation(.easeInOut, value: canvasBackgroundType)
                        .padding(.vertical, 5)
                default: Spacer()
                }
                
                HStack {
                    Text("Canvas texture").padding(.vertical)
                    Spacer()
                }
                bgTextureSel
            }.padding(30)
            
            Spacer()
        }
        .tint(.accentColor)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @AppStorage("_CFG_CANVAS_BG") var canvasBackgroundType: Int = 0
    @AppStorage("_CFG_CANVAS_BG_COLOR") var canvasBackgroundColorId: Int = 0
    @AppStorage("_CFG_CANVAS_BG_GRAD") var canvasBackgroundGradId: Int = 0
    @AppStorage("_CFG_CANVAS_BG_IMG") var canvasBackgroundImage: Int = 0
    let colorSelWidth: CGFloat = 60
    let colorSelHeight: CGFloat = 30
    
    @ViewBuilder var selsctedCheckmark: some View {
        Circle().fill(.white)
            .frame(width: colorSelHeight - 8, height: colorSelHeight - 8)
            .shadow(color: .primary, radius: 1)
        Image(systemName: "checkmark.circle.fill")
            .resizable().scaledToFit()
            .foregroundColor(.accentColor)
            .frame(width: colorSelHeight - 10, height: colorSelHeight - 10)
    }
    
    @ViewBuilder var bgColorSel: some View {
        HStack(spacing: 12) {
            ZStack {
                ZStack {
                    Color.white
                    Color.black.frame(height: colorSelHeight * 3)
                        .rotationEffect(.degrees(20))
                        .offset(x: colorSelWidth / 2)
                }
                .clipShape(Capsule())
                .frame(width: colorSelWidth, height: colorSelHeight)
                .clipped().clipShape(Capsule())
                .shadow(color: .primary, radius: 1)
                .onTapGesture {
                    canvasBackgroundColorId = 0
                }
                if canvasBackgroundColorId == 0 {
                    selsctedCheckmark
                }
            }
            
            ForEach(1...4, id: \.self) { index in
                ZStack {
                    Capsule()
                        .fill(bgColors[index])
                        .frame(width: colorSelWidth, height: colorSelHeight)
                        .shadow(color: .primary, radius: 1)
                        .onTapGesture {
                            canvasBackgroundColorId = index
                        }
                    if canvasBackgroundColorId == index {
                        selsctedCheckmark
                    }
                }
            }
        }
        HStack(spacing: 12) {
            ForEach(5...9, id: \.self) { index in
                ZStack {
                    Capsule()
                        .fill(bgColors[index])
                        .frame(width: colorSelWidth, height: colorSelHeight)
                        .shadow(color: .primary, radius: 1)
                        .onTapGesture {
                            canvasBackgroundColorId = index
                        }
                    if canvasBackgroundColorId == index {
                        selsctedCheckmark
                    }
                }
            }
        }
    }
    
    @ViewBuilder var bgGradientSel: some View {
        HStack(spacing: 12) {
            ForEach(0..<bgGrads.count, id: \.self) { index in
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(bgGrads[index])
                        .frame(width: colorSelWidth, height: colorSelWidth)
                        .shadow(color: .primary, radius: 1)
                        .onTapGesture {
                            canvasBackgroundGradId = index
                        }
                    if canvasBackgroundGradId == index {
                        selsctedCheckmark
                    }
                }
            } // foreach
        }
    }
    
    @ViewBuilder var bgTextureSel: some View {
        HStack(spacing: 12) {
            ForEach(0...4, id: \.self) { index in
                ZStack {
                    RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.systemBackground))
                        .frame(width: colorSelWidth, height: colorSelWidth)
                        .shadow(color: .primary, radius: 1)
                    Image(bgImgPreviewNames[index]).resizable().scaledToFill()
                        .frame(width: colorSelWidth, height: colorSelWidth)
                        .onTapGesture {
                            canvasBackgroundImage = index
                        }
                    if canvasBackgroundImage == index {
                        selsctedCheckmark
                    }
                }
            }
        }
    }
}

extension Color {
    static func hex(_ hex: UInt32) -> Color { // ARGB format
        let gCompAlign = hex >> 8
        let rCompAlign = hex >> 16
        let aCompAlign = hex >> 24
        let a = Double(aCompAlign & 0xFF) / 255
        let r = Double(rCompAlign & 0xFF) / 255
        let g = Double(gCompAlign & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        return Color(red: r, green: g, blue: b, opacity: a == 0 ? 1 : a)
    }
}

let bgColors: [Color] = [
    .clear, .white, .black, .gray, Color(red: 1.0, green: 0.97, blue: 0.78),
    .hex(0xFFDAE8), .hex(0xCDEAFF), .hex(0xB4FFC8), .hex(0xFFE6A0), .hex(0xE6CDFF),
]
let bgGrads: [LinearGradient] = [
    LinearGradient(colors: [.white, .black], startPoint: .top, endPoint: .bottom),
    LinearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom),
    LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom),
    LinearGradient(colors: [.green, .blue], startPoint: .top, endPoint: .bottom),
    LinearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom),
]
let bgImgNames: [String] = [
    "", "dot", "line", "grid", ""
]
let bgImgPreviewNames: [String] = [
    "", "dot_preview", "line_preview", "grid_preview", "_preview"
]

#Preview {
    PrefsView()
}
