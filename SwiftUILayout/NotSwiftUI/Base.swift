//
//  Base.swift
//  SwiftUILayout
//
//  Created by Florian Kugler on 26-10-2020.
//

import SwiftUI

protocol View_ {
    associatedtype Body: View_
    var body: Body { get }
    
    // for debugging
    associatedtype SwiftUIView: View
    var swiftUI: SwiftUIView { get }
}

typealias RenderingContext = CGContext

struct ProposedSize {
    var width: CGFloat?
    var height: CGFloat?
}

extension ProposedSize {
    init(_ cgSize: CGSize) {
        self.init(width: cgSize.width, height: cgSize.height)
    }
    
    var orMax: CGSize {
        CGSize(width: width ?? .greatestFiniteMagnitude, height: height ?? .greatestFiniteMagnitude)
    }
    
    var orDefault: CGSize  {
        CGSize(width: width ??  10, height: height ?? 10)
    }
}

protocol BuiltinView {
    func render(context: RenderingContext, size: CGSize)
    func size(proposed: ProposedSize) -> CGSize
    func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat?
    var layoutPriority: Double { get }
    typealias Body = Never
}

extension View_ where Body == Never {
    var body: Never { fatalError("This should never be called.") }
}

extension Never: View_ {
    typealias Body = Never
    var swiftUI: Never { fatalError("Should never be called") }
}

extension View_ {
    var _layoutPriority: Double {
        if let builtin = self as? BuiltinView {
            return builtin.layoutPriority
        } else {
            return body._layoutPriority
        }
    }
    
    func _customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
        if let builtin = self as? BuiltinView {
            return builtin.customAlignment(for: alignment, in: size)
        } else {
            return  body._customAlignment(for: alignment, in: size)
        }
    }

    func _render(context: RenderingContext, size: CGSize) {
        if let builtin = self as? BuiltinView {
            builtin.render(context: context, size: size)
        } else {
            body._render(context: context, size: size)
        }
    }
    
    func _size(proposed: ProposedSize) -> CGSize {
        if let builtin = self as? BuiltinView {
            return builtin.size(proposed: proposed)
        } else {
            return body._size(proposed: proposed)
        }
    }
}
