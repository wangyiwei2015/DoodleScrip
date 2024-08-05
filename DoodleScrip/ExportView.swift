//
//  ExportView.swift
//  DoodleScrip
//
//  Created by leo on 2024-05-15.
//

import SwiftUI

struct ExportView: View {
    @Namespace var namespace
    @Binding var isPresented: Bool
    var image: UIImage?
    @State var cropping = false
    @State var croppedImg: UIImage? = nil
    
    @AppStorage("_CFG_ACTION_COPY") var actionAfterCopy: Int = 0
    @AppStorage("_CFG_ACTION_SAVE") var actionAfterSave: Int = 0
    
    func dismiss() {
        withAnimation {
            isPresented = false
            croppedImg = nil
        }
    }
    
    var body: some View {
        ZStack {
            if isPresented {
                Rectangle().fill(Gradient(colors: [
                    .black.opacity(0.5), .black.opacity(0.8)
                ])).transition(.opacity).ignoresSafeArea()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                VStack(spacing: 20) {
                    Spacer()
                    
                    Label("Draggable", systemImage: "arrow.up").bold().foregroundColor(.white)
                    
                    ShareLink(item: tmpURL, subject: Text("Subject"), message: Text("message")) {
                        Label("Share", systemImage: "square.and.arrow.up").bold()
                    }.buttonStyle(BorderedProminentButtonStyle())
                    
                    Button {
                        UIPasteboard.general.image = croppedImg ?? image
                        dismiss()
                        switch actionAfterCopy {
                        case 1:
                            goHome()
                        default:
                            break
                        }
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc").bold()
                    }.buttonStyle(BorderedProminentButtonStyle())
                    
                    Button {
                        UIImageWriteToSavedPhotosAlbum(croppedImg ?? image!, nil, nil, nil)
                        dismiss()
                        switch actionAfterCopy {
                        case 1:
                            UIApplication.shared.open(URL(string: "photos-redirect:")!, options: [:])
                        case 2:
                            goHome()
                        default:
                            break
                        }
                    } label: {
                        Label("Save", systemImage: "tray.and.arrow.down").bold()
                    }.buttonStyle(BorderedProminentButtonStyle())
                    
                    Button {
                        dismiss()
                    } label: { Image(systemName: "xmark").bold().foregroundColor(.white) }
                        .frame(width: 50, height: 50)
                        .background(Capsule().fill(Color.gray))
                }.tint(.gray).transition(.move(edge: .bottom))
            }
            VStack {
                Image(uiImage: croppedImg ?? image ?? UIImage()).resizable().scaledToFit()
                    //.matchedGeometryEffect(id: "doodle", in: namespace, properties: .frame)
                    .background(Color.white.shadow(color: .black.opacity(0.5), radius: 4, y: 2))
                    .draggable(TransferrableUIImage(croppedImg ?? image!))
                    .animation(.easeOut(duration: 0.3), value: isPresented)
                    .padding(.top, isPresented ? 32+30 : 32+10)
                    .padding(.horizontal, 22)
                    .padding(.bottom, isPresented ? 280 : 0)
                    .onTapGesture {
                        withAnimation(.linear(duration: 0.2)) {
                            cropping = true
                        }
                    }
                    .opacity(isPresented ? 1 : 0)
                Spacer()
            }
            CropperView(
                inputImage: image ?? UIImage(),
                croppedImage: $croppedImg,
                isPresented: $cropping
            ).opacity(cropping ? 1 : 0)
        }
    }
}

#Preview {
    var lines: ObservableArray<PointShape> = ObservableArray(array: [])
    return ContentView(exporting: true).environmentObject(lines)
}
