//
//  AnyView.swift
//  SwiftUILayout
//
//  Created by Chris Eidhof on 10.11.20.
//

import Foundation
import SwiftUI

class AnyViewBase: BuiltinView {
    func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
        fatalError()
    }
    func render(context: RenderingContext, size: CGSize) {
        fatalError()
    }
    func size(proposed: ProposedSize) -> CGSize {
        fatalError()
    }
    var layoutPriority: Double {
        fatalError()
    }
}

final class AnyViewImpl<V: View_>: AnyViewBase {
    let view: V
    init(_ view: V) {
        self.view = view
    }
    override func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
        view._customAlignment(for: alignment, in: size)
    }
    override func render(context: RenderingContext, size: CGSize) {
        view._render(context: context, size: size)
    }
    override func size(proposed: ProposedSize) -> CGSize {
        view._size(proposed: proposed)
    }
    override var layoutPriority: Double {
        view._layoutPriority
    }
}

struct AnyView_: View_, BuiltinView {
    let swiftUI: AnyView
    let impl: AnyViewBase
    
    init<V: View_>(_ view: V) {
        self.swiftUI = AnyView(view.swiftUI)
        self.impl = AnyViewImpl(view)
    }
    
    var layoutPriority: Double {
        impl.layoutPriority
    }
    
    func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
        impl.customAlignment(for: alignment, in: size)
    }
    
    func render(context: RenderingContext, size: CGSize) {
        impl.render(context: context, size: size)
    }
    
    func size(proposed: ProposedSize) -> CGSize {
        impl.size(proposed: proposed)
    }
}

