//
//  Helpers.swift
//  NotSwiftUI
//
//  Created by Chris Eidhof on 05.10.20.
//

import Cocoa

extension CGContext {
    static func pdf(size: CGSize, render: (CGContext) -> ()) -> Data {
        let pdfData = NSMutableData()
        let consumer = CGDataConsumer(data: pdfData)!
        var mediaBox = CGRect(origin: .zero, size: size)
        let pdfContext = CGContext(consumer: consumer, mediaBox: &mediaBox, nil)!
        pdfContext.beginPage(mediaBox: &mediaBox)
        render(pdfContext)
        pdfContext.endPage()
        pdfContext.closePDF()
        return pdfData as Data
    }
}

extension Array {
    // expectes the array to be sorted by groupId
    func group<A: Equatable>(by groupId: (Element) -> A) -> [[Element]] {
        guard !isEmpty else { return [] }
        var groups: [[Element]] = []
        var currentGroup: [Element] = [self[0]]
        for element in dropFirst() {
            if groupId(currentGroup[0]) == groupId(element) {
                currentGroup.append(element)
            } else {
                groups.append(currentGroup)
                currentGroup = [element]
            }
        }
        groups.append(currentGroup)
        return groups
    }
}

import SwiftUI

extension Array where Element: BinaryFloatingPoint {
    func average() -> Element? {
        guard !isEmpty else { return nil }
        let factor = 1/Element(count)
        return map { $0 * factor }.reduce(0,+)
    }
}
