//
//  ContentView.swift
//  NotSwiftUI
//
//  Created by Chris Eidhof on 05.10.20.
//

import SwiftUI
import Cocoa

func render<V: View_>(view: V, size: CGSize) -> Data {
    return CGContext.pdf(size: size) { context in
        view
            .frame(width: size.width, height: size.height)
            ._render(context: context, size: size)
    }
}

extension View_ {
    var measured: some View_ {
        overlay(GeometryReader_ { size in
            Text_("\(Int(size.width))")
        })
    }
}

enum MyLeading: AlignmentID, SwiftUI.AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        0
    }
    
    static func defaultValue(in context: CGSize) -> CGFloat {
        0
    }
}

extension HorizontalAlignment_ {
    static let myLeading = HorizontalAlignment_(alignmentID: MyLeading.self, swiftUI: HorizontalAlignment(MyLeading.self))
}

struct ContentView: View {
    let size = CGSize(width: 600, height: 400)

    
    var sample: some View_ {
        HStack_(children: [
            AnyView_(
                Rectangle_()
                    .foregroundColor(NSColor.red)
                    .frame(minWidth: 50)
                    .measured
            ),
            AnyView_(
                Rectangle_()
                    .foregroundColor(NSColor.green)
                    .frame(width: 30)
                    .layoutPriority(2)
                    .measured
            ),
            AnyView_(
                Rectangle_()
                    .foregroundColor(NSColor.yellow)
                    .frame(minWidth: 50)
                    .layoutPriority(1)
                    .measured
            ),
            AnyView_(
                Rectangle_()
                    .foregroundColor(NSColor.blue)
                    .layoutPriority(2)
                    .measured
            ),
            AnyView_(
                Rectangle_()
                    .foregroundColor(NSColor.orange)
                    .frame(minWidth: 100, maxWidth: 120)
                    .measured
            ),
        ])
        .frame(width: 400, height: 200, alignment: Alignment_(horizontal: .leading, vertical: .center))
        .border(NSColor.white)
    }

    @State var opacity: Double = 0.5
    @State var width: CGFloat  = 300

    var body: some View {
        VStack {
            ZStack {
                Image(nsImage: NSImage(data: render(view: sample, size: size))!)
                    .opacity(1-opacity)
                sample.swiftUI.frame(width: size.width, height: size.height)
                    .opacity(opacity)
            }
            Slider(value: $opacity, in: 0...1)
                .padding()
            HStack {
                Text("Width \(width.rounded())")
                Slider(value: $width, in: 0...600)
            }.padding()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 1080/2)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
