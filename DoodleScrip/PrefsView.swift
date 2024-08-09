//
//  PrefsView.swift
//  DoodleScrip
//
//  Created by leo on 2024-08-09.
//

import SwiftUI

struct PrefsView: View {
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("_CFG_ACTION_COPY") var actionAfterCopy: Int = 0
    @AppStorage("_CFG_ACTION_SAVE") var actionAfterSave: Int = 0
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Label("Back", systemImage: "checkmark") //chevron.left
                }.buttonStyle(StrokeWidthBtnStyle(weight: .semibold))
                    .frame(width: 100, height: 32)
                    .background(Capsule().fill(Color.gray))
                    .foregroundColor(.white)
                Divider().padding(.horizontal, 10)
                Text("Settings").font(.title2).bold()
                Spacer()
            }
            .frame(height: 32)
            .padding(.horizontal)
            
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
                    ColorPicker("Default color", selection: .constant(.accentColor))
                        .frame(width: 160)
                    Spacer()
                }
                
                HStack {
                    Text("Canvas paper")
                    Picker("Canvas background", selection: $canvasBackgroundType) {
                        Text("Color").tag(0)
                        Text("Gradient").tag(1)
                        Text("Texture").tag(2)
                    }.pickerStyle(.segmented)
                    Spacer()
                }.padding(.top)
                
                switch canvasBackgroundType {
                case 0: Text("Color")
                case 1: Text("Gradient")
                case 2: Text("Texture")
                default: Spacer()
                }
                bgColorSel
                bgGradientSel
                bgTextureSel
            }.padding(30)
            
            Spacer()
        }
    }
    
    @AppStorage("_CFG_CANVAS_BG") var canvasBackgroundType: Int = 0
    @AppStorage("_CFG_CANVAS_BG_COLOR") var canvasBackgroundColorId: Int = 0
    @AppStorage("_CFG_CANVAS_BG_GRAD") var canvasBackgroundGradId: Int = 0
    @AppStorage("_CFG_CANVAS_BG_IMG") var canvasBackgroundImage: String = ""
    let colorSelWidth: CGFloat = 60
    let colorSelHeight: CGFloat = 30
    
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
                    Circle().fill(.white)
                        .frame(width: colorSelHeight - 8, height: colorSelHeight - 8)
                        .shadow(color: .primary, radius: 1)
                    Image(systemName: "checkmark.circle.fill")
                        .resizable().scaledToFit()
                        .foregroundColor(.accentColor)
                        .frame(width: colorSelHeight - 10, height: colorSelHeight - 10)
                }
            }
            
            ForEach(1..<bgColors.count, id: \.self) { index in
                ZStack {
                    Capsule()
                        .fill(bgColors[index])
                        .frame(width: colorSelWidth, height: colorSelHeight)
                        .shadow(color: .primary, radius: 1)
                        .onTapGesture {
                            canvasBackgroundColorId = index
                        }
                    if canvasBackgroundColorId == index {
                        Circle().fill(.white)
                            .frame(width: colorSelHeight - 8, height: colorSelHeight - 8)
                            .shadow(color: .primary, radius: 1)
                        Image(systemName: "checkmark.circle.fill")
                            .resizable().scaledToFit()
                            .foregroundColor(.accentColor)
                            .frame(width: colorSelHeight - 10, height: colorSelHeight - 10)
                    }
                }
            }
        }
    }
    
    @ViewBuilder var bgGradientSel: some View {
        Text("not done")
    }
    
    @ViewBuilder var bgTextureSel: some View {
        Text("not done")
    }
}

let bgColors: [Color] = [.clear, .white, .black, .gray, Color(red: 1.0, green: 0.97, blue: 0.75)]
let bgGrads: [Gradient] = [
]
let bgImgNames: [String] = [
    "",
]

#Preview {
    PrefsView()
}
