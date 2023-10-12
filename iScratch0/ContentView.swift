//
//  ContentView.swift
//  iScratch0
//
//  Created by Qiwei on 10/11/23.
//

import SwiftUI

struct ContentView: View {
    @State var onFinish: Bool = false
    var body: some View {
        
        VStack{
            
            ScratchCardView(cursorSize: 50, onFinish: $onFinish){
                
                VStack{
                    Image("simpsons")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(10)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                
            } overlayView: {
                    
                    
                    Image("introimg")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
            .frame(maxWidth:.infinity, maxHeight: .infinity)
            .background(Color.black.ignoresSafeArea())
            .overlay(
                
                //not necessary for my final app...
                HStack{
                    
                    Button(action: {}, label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white)
                    })
                    
                    Text("Scratch Card")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer(minLength: 0)
                    
                    Button(action: {}, label: {
                        Image("simpsons")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width:55, height: 55)
                            .clipShape(Circle())
                    })
                }
                    .padding()
                ,alignment: .top
            )}
    }


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ScratchCardView<Content: View,overlayImage:View>: View {
    
    var content: Content
    var overlayView: overlayImage
    
    init(cursorSize: CGFloat, onFinish: Binding<Bool>, @ViewBuilder content: @escaping ()->Content, @ViewBuilder overlayView: @escaping()->overlayImage){
        self.content = content()
        self.overlayView = overlayView()
        self.cursorSize = cursorSize
        self._onFinish = onFinish
    }
    
    @State var startingPoint: CGPoint = .zero
    @State var points: [CGPoint] = []
    
    @GestureState var gestureLocation: CGPoint = .zero
    
    var cursorSize: CGFloat
    @Binding var onFinish: Bool
    
    var body: some View{
        
        ZStack{
            overlayView
            
            content
                .mask(ScratchMask(points: points, startingPoint: startingPoint)
                    .stroke(style: StrokeStyle(lineWidth: cursorSize, lineCap: .round, lineJoin: .round)))
                .gesture(
            
                    DragGesture()
                        .updating($gestureLocation, body: { value, out, _ in
                            out = value.location
                            
                            DispatchQueue.main.async {
                                //ipdate starting point, add drag logations
                                if startingPoint == .zero{
                                    startingPoint = value.location
                                }
                                
                                points.append(value.location)
                                print(points)
                            }
                        })
                        .onEnded({ value in
                            withAnimation{
                                onFinish = true
                            }
                        })
                )
                
        }
        .frame(width: 300, height: 300)
        .cornerRadius(20)
    }
    
}

//scratch mask
struct ScratchMask: Shape {
    var points:[CGPoint]
    var startingPoint: CGPoint
    
    func path(in rect: CGRect) -> Path{
        return Path{path in
            path.move(to:startingPoint)
            path.addLines(points)
        }
    }
}
