//
//  Misc.swift
//  SwiftUILayout
//
//  Created by Florian Kugler on 26-10-2020.
//

import SwiftUI

struct BorderShape: Shape_ {
    var width: CGFloat

    func path(in rect: CGRect) -> CGPath {
        CGPath(rect: rect.insetBy(dx: width/2, dy: width/2), transform: nil)
            .copy(strokingWithWidth: width, lineCap: .butt, lineJoin: .miter, miterLimit: 10)
    }
}

struct Overlay<Content: View_, O: View_>: View_, BuiltinView {
    let content: Content
    let overlay: O
    let alignment: Alignment_
    
    var layoutPriority: Double {
        content._layoutPriority
    }

    func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
        content._customAlignment(for: alignment, in: size)
    }

    func render(context: RenderingContext, size: CGSize) {
        content._render(context: context, size: size)
        let childSize = overlay._size(proposed: ProposedSize(size))
        context.saveGState()
        let t = content.translation(for: overlay, in: size, siblingSize: childSize, alignment: alignment)
        context.translateBy(x: t.x, y: t.y)
        overlay._render(context: context, size: childSize)
        context.restoreGState()
    }
    
    func size(proposed: ProposedSize) -> CGSize {
        content._size(proposed: proposed)
    }
    
    var swiftUI: some View {
        content.swiftUI.overlay(overlay.swiftUI, alignment: alignment.swiftUI)
    }
}

extension View_ {
    func border(_ color: NSColor, width: CGFloat = 1) -> some View_ {
        overlay(BorderShape(width: width).foregroundColor(color))
    }
    
    func overlay<O: View_>(_  overlay: O, alignment: Alignment_ = .center) -> some View_  {
        Overlay(content: self, overlay: overlay, alignment: alignment)
    }
}

struct GeometryReader_<Content: View_>: View_, BuiltinView {
    let content: (CGSize) -> Content

    var layoutPriority: Double { 0 }
    
    func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
        return nil
    }

    func render(context: RenderingContext, size: CGSize) {
        let child = content(size)
        let childSize = child._size(proposed: ProposedSize(size))
        context.saveGState()
        let alignment = Alignment_.center
        let parentPoint = alignment.point(for: size)
        let childPoint = alignment.point(for: childSize)
        context.translateBy(x: parentPoint.x-childPoint.x, y: parentPoint.y-childPoint.y)
        child._render(context: context, size: childSize)
        context.restoreGState()
    }
    
    func size(proposed: ProposedSize) -> CGSize {
        return proposed.orDefault
    }
    
    var swiftUI: some View {
        GeometryReader { proxy in
            content(proxy.size).swiftUI
        }
    }
}

struct FixedSize<Content: View_>: View_, BuiltinView {
    var content: Content
    var horizontal: Bool
    var vertical: Bool
    
    var layoutPriority: Double {
        content._layoutPriority
    }

    func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
        content._customAlignment(for: alignment, in: size)
    }

    func render(context: RenderingContext, size: CGSize) {
        content._render(context: context, size: size)
    }
    
    func size(proposed p: ProposedSize) -> CGSize {
        var proposed = p
        if horizontal { proposed.width = nil }
        if vertical { proposed.height = nil }
        return content._size(proposed: proposed)
    }
    
    var swiftUI: some View {
        content.swiftUI.fixedSize(horizontal: horizontal, vertical: vertical)
    }
}

extension View_ {
    func fixedSize(horizontal: Bool  = true, vertical: Bool  = true) -> some View_ {
        FixedSize(content: self, horizontal: horizontal, vertical: vertical)
    }
}

struct LayoutPriority<Content: View_>: View_, BuiltinView {
    var content: Content
    var layoutPriority: Double
    
    func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
        content._customAlignment(for: alignment, in: size)
    }
    
    func render(context: RenderingContext, size: CGSize) {
        content._render(context: context, size: size)
    }
    
    func size(proposed: ProposedSize) -> CGSize {
        content._size(proposed: proposed)
    }
    
    var swiftUI: some View {
        content.swiftUI.layoutPriority(layoutPriority)
    }
}

extension View_ {
    func layoutPriority(_ value: Double) -> some View_ {
        LayoutPriority(content: self, layoutPriority: value)
    }
}

@propertyWrapper
final class LayoutState<A> {
    var wrappedValue: A
    init(wrappedValue: A) {
        self.wrappedValue = wrappedValue
    }
}
