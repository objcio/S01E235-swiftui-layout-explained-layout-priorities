//
//  HStack.swift
//  SwiftUILayout
//
//  Created by Chris Eidhof on 03.11.20.
//

import SwiftUI

struct HStack_: View_, BuiltinView {
    var children: [AnyView_]
    var alignment: VerticalAlignment_ = .center
    let spacing: CGFloat? = 0
    @LayoutState var sizes: [CGSize] = []
    
    var layoutPriority: Double { 0 }

    func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
        if alignment.builtin { return nil }
        
        var currentX: CGFloat = 0
        var values: [CGFloat] = []
        for idx in children.indices {
            let child = children[idx]
            let childSize = sizes[idx]
            if let value = child.customAlignment(for: alignment, in: childSize) {
                values.append(value + currentX)
            }
            currentX += childSize.width
        }
        return values.average() ?? nil
    }

    func render(context: RenderingContext, size: CGSize) {
        let stackY = alignment.alignmentID.defaultValue(in: size)
        var currentX: CGFloat = 0
        for idx in children.indices {
            let child = children[idx]
            let childSize = sizes[idx]
            let childY = alignment.alignmentID.defaultValue(in: childSize)
            context.saveGState()
            context.translateBy(x: currentX, y: stackY-childY)
            child.render(context: context, size: childSize)
            context.restoreGState()
            currentX += childSize.width
        }
    }
    
    func size(proposed: ProposedSize) -> CGSize {
        layout(proposed: proposed)
        let width: CGFloat = sizes.reduce(0) { $0 + $1.width }
        let height: CGFloat = sizes.reduce(0) { max($0, $1.height) }
        return CGSize(width: width, height: height)
    }
    
    func layout(proposed: ProposedSize) {
        let flexibility: [LayoutInfo] = children.indices.map { idx in
            let child = children[idx]
            let lower = child.size(proposed: ProposedSize(width: 0, height: proposed.height)).width
            let upper = child.size(proposed: ProposedSize(width: .greatestFiniteMagnitude, height: proposed.height)).width
            return LayoutInfo(minWidth: lower, maxWidth: upper, idx: idx, priority: child.layoutPriority)
        }.sorted()
        var groups = flexibility.group(by: \.priority)
        var sizes: [CGSize] = Array(repeating: .zero, count: children.count)
        let allMinWidths = flexibility.map(\.minWidth).reduce(0,+)
        var remainingWidth = proposed.width! - allMinWidths // TODO force unwrap
        
        while !groups.isEmpty {
            let group = groups.removeFirst()
            remainingWidth += group.map(\.minWidth).reduce(0,+)
            
            var remainingIndices = group.map { $0.idx }
            while !remainingIndices.isEmpty {
                let width = remainingWidth / CGFloat(remainingIndices.count)
                let idx = remainingIndices.removeFirst()
                let child = children[idx]
                let size = child.size(proposed: ProposedSize(width: width, height: proposed.height))
                sizes[idx] = size
                remainingWidth -= size.width
                if remainingWidth < 0 { remainingWidth = 0 }
            }
        }
        self.sizes = sizes
    }
    
    var swiftUI: some View {
        HStack(alignment: alignment.swiftUI, spacing: spacing) {
            ForEach(children.indices, id: \.self) { idx in
                children[idx].swiftUI
            }
        }
    }
}

struct LayoutInfo: Comparable {
    var minWidth: CGFloat
    var maxWidth: CGFloat
    var idx: Int
    var priority: Double
    
    static func <(_ l: LayoutInfo, _ r: LayoutInfo) -> Bool {
        if l.priority > r.priority { return true }
        if r.priority > l.priority { return false }
        return l.flexibility < r.flexibility
    }
    
    var flexibility: CGFloat {
        maxWidth - minWidth
    }
}


