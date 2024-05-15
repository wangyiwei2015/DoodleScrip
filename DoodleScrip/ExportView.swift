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
    
    func dismiss() {
        withAnimation { isPresented = false }
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
                        Label("Share", systemImage: "swift").bold()
                    }.buttonStyle(BorderedProminentButtonStyle())
                    
                    Button {
                        UIPasteboard.general.image = image
                        dismiss()
                        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                    } label: {
                        Label("Copy", systemImage: "swift").bold()
                    }.buttonStyle(BorderedProminentButtonStyle())
                    
                    Button {
                        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
                        dismiss()
                        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                    } label: {
                        Label("Save", systemImage: "swift").bold()
                    }.buttonStyle(BorderedProminentButtonStyle())
                    
                    Button {
                        dismiss()
                    } label: { Image(systemName: "xmark").bold().foregroundColor(.white) }
                        .frame(width: 50, height: 50)
                        .background(Capsule().fill(Color.gray))
                }.tint(.gray).transition(.move(edge: .bottom))
            }
            VStack {
                Image(uiImage: image ?? UIImage()).resizable().scaledToFit()
                    //.matchedGeometryEffect(id: "doodle", in: namespace, properties: .frame)
                    .background(Color.white.shadow(color: .black.opacity(0.5), radius: 4, y: 2))
                    //.draggable(<#T##payload: Transferable##Transferable#>)
                    .animation(.easeOut(duration: 0.3), value: isPresented)
                    .padding(.top, isPresented ? 32+30 : 32+10)
                    .padding(.horizontal, 22)
                    .padding(.bottom, isPresented ? 280 : 0)
                    .opacity(isPresented ? 1 : 0)
                Spacer()
            }
        }
    }
}

#Preview {
    var lines: ObservableArray<PointShape> = ObservableArray(array: [])
    return ContentView(exporting: true).environmentObject(lines)
}
