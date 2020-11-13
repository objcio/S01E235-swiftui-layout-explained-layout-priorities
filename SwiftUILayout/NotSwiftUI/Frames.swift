//
//  Frames.swift
//  SwiftUILayout
//
//  Created by Florian Kugler on 26-10-2020.
//

import SwiftUI

struct FixedFrame<Content: View_>: View_, BuiltinView {
    var width: CGFloat?
    var height: CGFloat?
    var alignment: Alignment_
    var content: Content

    var layoutPriority: Double {
        content._layoutPriority
    }
    
    func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
        let childSize = content._size(proposed: ProposedSize(size))
        if let customX = content._customAlignment(for: alignment, in: childSize) {
            let t = translation(for: content, in: size, childSize: childSize, alignment: self.alignment)
            return t.x + customX
        }
        return nil
    }
    

    func size(proposed: ProposedSize) -> CGSize {
        let childSize = content._size(proposed: ProposedSize(width: width ?? proposed.width, height: height ?? proposed.height))
        return CGSize(width: width ?? childSize.width, height: height ?? childSize.height)
    }
    
    func render(context: RenderingContext, size: CGSize) {
        context.saveGState()
        let childSize = content._size(proposed: ProposedSize(size))
        let t = translation(for: content, in: size, childSize: childSize, alignment: alignment)
        context.translateBy(x: t.x, y: t.y)
        content._render(context: context, size: childSize)
        context.restoreGState()
    }
    
    var swiftUI: some View {
        content.swiftUI.frame(width: width, height: height, alignment: alignment.swiftUI)
    }
}

extension View_ {
    func translation<V: View_>(for childView: V, in parentSize: CGSize, childSize: CGSize, alignment: Alignment_) -> CGPoint {
        let parentPoint = alignment.point(for: parentSize)
        var childPoint = alignment.point(for: childSize)
        if let customX  = childView._customAlignment(for: alignment.horizontal, in: childSize) {
            childPoint.x = customX
        }
        // TODO vertical axis
        return CGPoint(x: parentPoint.x-childPoint.x, y: parentPoint.y-childPoint.y)
    }
    
    func translation<V: View_>(for sibling: V, in size: CGSize, siblingSize: CGSize, alignment: Alignment_) -> CGPoint {
        var selfPoint = alignment.point(for: size)
        if let customX  = self._customAlignment(for: alignment.horizontal, in: size) {
            selfPoint.x = customX
        }
        var childPoint = alignment.point(for: siblingSize)
        if let customX  = sibling._customAlignment(for: alignment.horizontal, in: siblingSize) {
            childPoint.x = customX
        }
        // TODO vertical axis
        return CGPoint(x: selfPoint.x-childPoint.x, y: selfPoint.y-childPoint.y)
    }
}

struct FlexibleFrame<Content: View_>: View_, BuiltinView {
    var minWidth: CGFloat?
    var idealWidth: CGFloat?
    var maxWidth: CGFloat?
    var minHeight: CGFloat?
    var idealHeight: CGFloat?
    var maxHeight: CGFloat?
    var alignment: Alignment_
    var content: Content
    
    var layoutPriority: Double {
        content._layoutPriority
    }

    func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
        let childSize = content._size(proposed: ProposedSize(size))
        if let customX = content._customAlignment(for: alignment, in: childSize) {
            let t = translation(for: content, in: size, childSize: childSize, alignment: self.alignment)
            return t.x + customX
        }
        return nil
    }

    func size(proposed p: ProposedSize) -> CGSize {
        var proposed = ProposedSize(width: p.width ?? idealWidth, height: p.height ??  idealHeight).orDefault
        if let min = minWidth, min > proposed.width {
            proposed.width = min
        }
        if let max = maxWidth, max <  proposed.width {
            proposed.width = max
        }
        if let min = minHeight, min > proposed.height {
            proposed.height = min
        }
        if let max = maxHeight, max <  proposed.height {
            proposed.height = max
        }
        var result = content._size(proposed: ProposedSize(proposed))
        if let m = minWidth {
            result.width = max(m, min(result.width, proposed.width))
        }
        if let m = maxWidth {
            result.width = min(m, max(result.width, proposed.width))
        }
        if let m = minHeight {
            result.height = max(m, min(result.height, proposed.height))
        }
        if let m = maxHeight {
            result.height = min(m, max(result.height, proposed.height))
        }
        return result
    }
    
    func render(context: RenderingContext, size: CGSize) {
        context.saveGState()
        let childSize = content._size(proposed: ProposedSize(size))
        let t = translation(for: content, in: size, childSize: childSize, alignment: alignment)
        context.translateBy(x: t.x, y: t.y)
        content._render(context: context, size: childSize)
        context.restoreGState()
    }
    
    var swiftUI: some View {
        content.swiftUI.frame(minWidth: minWidth, idealWidth: idealWidth, maxWidth: maxWidth, minHeight: minHeight, idealHeight: idealHeight, maxHeight: maxHeight, alignment: alignment.swiftUI)
    }
}


extension View_ {
    func frame(width: CGFloat? = nil, height: CGFloat? = nil, alignment: Alignment_ = .center) -> some View_ {
        FixedFrame(width: width, height: height, alignment: alignment, content: self)
    }
    
    func frame(minWidth: CGFloat? = nil, idealWidth: CGFloat? = nil, maxWidth: CGFloat? = nil, minHeight: CGFloat? = nil, idealHeight: CGFloat? = nil, maxHeight: CGFloat? = nil, alignment: Alignment_ = .center) -> some View_ {
        FlexibleFrame(minWidth: minWidth, idealWidth: idealWidth, maxWidth: maxWidth, minHeight: minHeight, idealHeight: idealHeight, maxHeight: maxHeight, alignment: alignment, content: self)
    }

}


