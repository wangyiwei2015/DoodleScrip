//
//  CropImager.swift
//  DoodleScrip
//
//  Created by leo on 2024-07-30.
//

import SwiftUI

func cropImage(
    _ inputImage: UIImage, toRect cropRect: CGRect,
    viewWidth: CGFloat, viewHeight: CGFloat) -> UIImage? {
    let imageViewWidthScale = inputImage.size.width / viewWidth
    let imageViewHeightScale = inputImage.size.height / viewHeight
    // Scale cropRect to handle images larger than shown-on-screen size
    let cropZone = CGRect(x:cropRect.origin.x * imageViewWidthScale,
                          y:cropRect.origin.y * imageViewHeightScale,
                          width:cropRect.size.width * imageViewWidthScale,
                          height:cropRect.size.height * imageViewHeightScale)
    // Perform cropping in Core Graphics
    guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to:cropZone)
    else {
        return nil
    }
    // Return image to UIImage
    let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
    return croppedImage
}

struct CropperView: View {
    var inputImage: UIImage
    @Binding var croppedImage: UIImage?
    @Binding var isPresented: Bool
    
    //视图的宽高，不用全局变量是为了方便修改视图：默认横向（landscape）
    @State private var screenWidth = UIScreen.main.bounds.height
    @State private var screenHeight = UIScreen.main.bounds.width
    
    //后面可以变成自定义的部分
    //边框颜色
    var cropBorderColor: Color? = Color.white
    //顶点图案颜色
    var cropVerticesColor: Color = Color.pink
    //遮罩透明度
    var cropperOutsideOpacity: Double = 0.4
    //    //裁切框样式
    //    @State private var iconVertices: Bool = false
    
    //@Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    @State var imageDisplayWidth: CGFloat = 0
    @State var imageDisplayHeight: CGFloat = 0
    
    @State var cropWidth: CGFloat = UIScreen.main.bounds.height/3
    @State var cropHeight: CGFloat = UIScreen.main.bounds.height/3*0.5
    @State var cropWidthAdd: CGFloat = 0
    @State var cropHeightAdd: CGFloat = 0
    @State var cropMode = 0
    
    @State var currentPositionZS: CGSize = .zero
    @State var newPositionZS: CGSize = .zero
    @State var currentPositionZ: CGSize = .zero
    @State var newPositionZ: CGSize = .zero
    @State var currentPositionZX: CGSize = .zero
    @State var newPositionZX: CGSize = .zero
    @State var currentPositionX: CGSize = .zero
    @State var newPositionX: CGSize = .zero
    @State var currentPositionYX: CGSize = .zero
    @State var newPositionYX: CGSize = .zero
    @State var currentPositionY: CGSize = .zero
    @State var newPositionY: CGSize = .zero
    @State var currentPositionYS: CGSize = .zero
    @State var newPositionYS: CGSize = .zero
    @State var currentPositionS: CGSize = .zero
    @State var newPositionS: CGSize = .zero
    @State var currentPositionCrop: CGSize = .zero
    @State var newPositionCrop: CGSize = .zero
    
    var body: some View {
        ZStack {
            //黑色背景
            Rectangle().fill(.black).ignoresSafeArea()
            
            VStack {
                ZStack {
                    Image(uiImage: inputImage)
                        .resizable().scaledToFit()
                        .overlay(GeometryReader{ geo -> AnyView in
                            DispatchQueue.main.async{
                                self.imageDisplayWidth = geo.size.width
                                self.imageDisplayHeight = geo.size.height
                            }
                            return AnyView(EmptyView())
                        })
                        
                    ZStack {
                        半透明遮罩; 裁剪框
                        上边; 下边; 左边; 右边
                    }
                    左上把手; 左下把手; 右上把手; 右下把手
                }
                
                Spacer()
                
                HStack {
                    HStack {
                        Button (action : {
                            cropMode = 0
                        }) {
                            if cropMode == 0 {
                                Text("Custom")
                                    .padding(.all, 10)
                                    .foregroundColor(.white)
                                    .background(.gray)
                                
                            } else {
                                Text("Custom")
                                    .foregroundColor(.white)
                                    .padding(.all, 10)
                            }
                        }
                        
                        Button (action : {
                            cropMode = 1
                            cropHeight = cropWidth*9/16
                            if cropWidth > cropHeight{
                                cropWidth = cropHeight*16/9
                            }else{
                                cropHeight = cropWidth*9/16
                            }
                            
                            if currentPositionCrop.width >= imageDisplayWidth/2 - cropWidth/2{
                                currentPositionCrop.width = imageDisplayWidth/2 - cropWidth/2
                                operateOnEnd()
                            }else if currentPositionCrop.width <= -imageDisplayWidth/2 + cropWidth/2{
                                currentPositionCrop.width = -imageDisplayWidth/2 + cropWidth/2
                                operateOnEnd()
                            }
                        }) {
                            if cropMode == 1 {
                                Text("16:9")
                                    .padding(.all, 10)
                                    .foregroundColor(.white)
                                    .background(.gray)
                            } else {
                                Text("16:9")
                                    .padding(.all, 10)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Button (action : {
                            cropMode = 2
                            if cropWidth > cropHeight{
                                cropWidth = cropHeight*4/3
                            }else{
                                cropHeight = cropWidth*3/4
                            }
                            
                            if currentPositionCrop.width >= imageDisplayWidth/2 - cropWidth/2{
                                currentPositionCrop.width = imageDisplayWidth/2 - cropWidth/2
                                operateOnEnd()
                            }else if currentPositionCrop.width <= -imageDisplayWidth/2 + cropWidth/2{
                                currentPositionCrop.width = -imageDisplayWidth/2 + cropWidth/2
                                operateOnEnd()
                            }
                        }) {
                            if cropMode == 2 {
                                Text("4:3")
                                    .padding(.all, 10)
                                    .foregroundColor(.white)
                                    .background(.gray)
                            } else {
                                Text("4:3")
                                    .padding(.all, 10)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .background(Color.gray.opacity(0.2))
                    .padding()
                    
                    Spacer()
                    
                    Button(action: crop, label: {
                        Image(systemName: "crop")
                            .padding(.all, 10)
                            .foregroundColor(.white)
                            .background(Color.gray.opacity(0.2))
                    })
                    .padding()
                }
            }
        }
        .navigationBarHidden(true)
//        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
//            
//            if UIDevice.current.orientation.isPortrait {
//                screenWidth = UIScreen.main.bounds.width
//                screenHeight = UIScreen.main.bounds.height
//            } else if UIDevice.current.orientation.isLandscape {
//                screenWidth = UIScreen.main.bounds.height
//                screenHeight = UIScreen.main.bounds.width
//            }
//            
//            print("screenWidth: \(screenWidth), screenHeight: \(screenHeight)")
//        }
    }
    
    func crop() {
        //由于CGRect是先到坐标再开始生成的，所以要这样减去剪裁栏的部分
        let rect = CGRect(x: imageDisplayWidth/2 + currentPositionCrop.width - cropWidth/2,
                          y: imageDisplayHeight/2 + currentPositionCrop.height - cropHeight/2,
                          width: cropWidth,
                          height: cropHeight)
        croppedImage = cropImage(inputImage, toRect: rect, viewWidth: imageDisplayWidth, viewHeight: imageDisplayHeight)!
        try? FileManager.default.removeItem(at: tmpURL)
        try! croppedImage?.jpegData(compressionQuality: 1.0)!.write(to: tmpURL, options: .atomic)
        isPresented = false
    }
    
    func operateOnEnd() {
        cropWidth = cropWidth + cropWidthAdd
        cropHeight = cropHeight + cropHeightAdd
        cropWidthAdd = 0
        cropHeightAdd = 0
        
        //Conners
        currentPositionZS.width = currentPositionCrop.width
        currentPositionZS.height = currentPositionCrop.height
        
        currentPositionZX.width = currentPositionCrop.width
        currentPositionZX.height = currentPositionCrop.height
        
        currentPositionYX.width = currentPositionCrop.width
        currentPositionYX.height = currentPositionCrop.height
        
        currentPositionYS.width = currentPositionCrop.width
        currentPositionYS.height = currentPositionCrop.height
        
        //Sides
        currentPositionS.width = currentPositionCrop.width
        currentPositionS.height = currentPositionCrop.height
        
        currentPositionZ.width = currentPositionCrop.width
        currentPositionZ.height = currentPositionCrop.height
        
        currentPositionX.width = currentPositionCrop.width
        currentPositionX.height = currentPositionCrop.height
        
        currentPositionY.width = currentPositionCrop.width
        currentPositionY.height = currentPositionCrop.height
        
        self.newPositionCrop = self.currentPositionCrop
        self.newPositionZS = self.currentPositionZS
        self.newPositionZX = self.currentPositionZX
        self.newPositionYX = self.currentPositionYX
        self.newPositionYS = self.currentPositionYS
        self.newPositionS = self.currentPositionS
        self.newPositionZ = self.currentPositionZ
        self.newPositionX = self.currentPositionX
        self.newPositionY = self.currentPositionY
    }
}

#Preview {
    CropperView(inputImage: UIImage(systemName: "swift")!, croppedImage: .constant(UIImage()), isPresented: .constant(true))
}
