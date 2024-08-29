//
//  SnapKit
//
//  Copyright (c) 2011-Present SnapKit Team - https://github.com/SnapKit
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#if os(iOS) || os(tvOS)
    import UIKit
#else
    import AppKit
#endif

struct ConstraintAttributes: OptionSet, ExpressibleByIntegerLiteral {
    typealias IntegerLiteralType = UInt

    init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    init(_ rawValue: UInt) {
        self.init(rawValue: rawValue)
    }

    init(nilLiteral _: ()) {
        rawValue = 0
    }

    init(integerLiteral rawValue: IntegerLiteralType) {
        self.init(rawValue: rawValue)
    }

    private(set) var rawValue: UInt
    static var allZeros: ConstraintAttributes { 0 }
    static func convertFromNilLiteral() -> ConstraintAttributes { 0 }
    var boolValue: Bool { rawValue != 0 }

    func toRaw() -> UInt { rawValue }
    static func fromRaw(_ raw: UInt) -> ConstraintAttributes? { self.init(raw) }
    static func fromMask(_ raw: UInt) -> ConstraintAttributes { self.init(raw) }

    // normal

    static let none: ConstraintAttributes = 0
    static let left: ConstraintAttributes = .init(UInt(1) << 0)
    static let top: ConstraintAttributes = .init(UInt(1) << 1)
    static let right: ConstraintAttributes = .init(UInt(1) << 2)
    static let bottom: ConstraintAttributes = .init(UInt(1) << 3)
    static let leading: ConstraintAttributes = .init(UInt(1) << 4)
    static let trailing: ConstraintAttributes = .init(UInt(1) << 5)
    static let width: ConstraintAttributes = .init(UInt(1) << 6)
    static let height: ConstraintAttributes = .init(UInt(1) << 7)
    static let centerX: ConstraintAttributes = .init(UInt(1) << 8)
    static let centerY: ConstraintAttributes = .init(UInt(1) << 9)
    static let lastBaseline: ConstraintAttributes = .init(UInt(1) << 10)

    @available(iOS 8.0, OSX 10.11, *)
    static let firstBaseline: ConstraintAttributes = .init(UInt(1) << 11)

    @available(iOS 8.0, *)
    static let leftMargin: ConstraintAttributes = .init(UInt(1) << 12)

    @available(iOS 8.0, *)
    static let rightMargin: ConstraintAttributes = .init(UInt(1) << 13)

    @available(iOS 8.0, *)
    static let topMargin: ConstraintAttributes = .init(UInt(1) << 14)

    @available(iOS 8.0, *)
    static let bottomMargin: ConstraintAttributes = .init(UInt(1) << 15)

    @available(iOS 8.0, *)
    static let leadingMargin: ConstraintAttributes = .init(UInt(1) << 16)

    @available(iOS 8.0, *)
    static let trailingMargin: ConstraintAttributes = .init(UInt(1) << 17)

    @available(iOS 8.0, *)
    static let centerXWithinMargins: ConstraintAttributes = .init(UInt(1) << 18)

    @available(iOS 8.0, *)
    static let centerYWithinMargins: ConstraintAttributes = .init(UInt(1) << 19)

    // aggregates

    static let edges: ConstraintAttributes = [.horizontalEdges, .verticalEdges]
    static let horizontalEdges: ConstraintAttributes = [.left, .right]
    static let verticalEdges: ConstraintAttributes = [.top, .bottom]
    static let directionalEdges: ConstraintAttributes = [.directionalHorizontalEdges, .directionalVerticalEdges]
    static let directionalHorizontalEdges: ConstraintAttributes = [.leading, .trailing]
    static let directionalVerticalEdges: ConstraintAttributes = [.top, .bottom]
    static let size: ConstraintAttributes = [.width, .height]
    static let center: ConstraintAttributes = [.centerX, .centerY]

    @available(iOS 8.0, *)
    static let margins: ConstraintAttributes = [.leftMargin, .topMargin, .rightMargin, .bottomMargin]

    @available(iOS 8.0, *)
    static let directionalMargins: ConstraintAttributes = [.leadingMargin, .topMargin, .trailingMargin, .bottomMargin]

    @available(iOS 8.0, *)
    static let centerWithinMargins: ConstraintAttributes = [.centerXWithinMargins, .centerYWithinMargins]

    var layoutAttributes: [LayoutAttribute] {
        var attrs = [LayoutAttribute]()
        if contains(ConstraintAttributes.left) {
            attrs.append(.left)
        }
        if contains(ConstraintAttributes.top) {
            attrs.append(.top)
        }
        if contains(ConstraintAttributes.right) {
            attrs.append(.right)
        }
        if contains(ConstraintAttributes.bottom) {
            attrs.append(.bottom)
        }
        if contains(ConstraintAttributes.leading) {
            attrs.append(.leading)
        }
        if contains(ConstraintAttributes.trailing) {
            attrs.append(.trailing)
        }
        if contains(ConstraintAttributes.width) {
            attrs.append(.width)
        }
        if contains(ConstraintAttributes.height) {
            attrs.append(.height)
        }
        if contains(ConstraintAttributes.centerX) {
            attrs.append(.centerX)
        }
        if contains(ConstraintAttributes.centerY) {
            attrs.append(.centerY)
        }
        if contains(ConstraintAttributes.lastBaseline) {
            attrs.append(.lastBaseline)
        }

        #if os(iOS) || os(tvOS)
            if contains(ConstraintAttributes.firstBaseline) {
                attrs.append(.firstBaseline)
            }
            if contains(ConstraintAttributes.leftMargin) {
                attrs.append(.leftMargin)
            }
            if contains(ConstraintAttributes.rightMargin) {
                attrs.append(.rightMargin)
            }
            if contains(ConstraintAttributes.topMargin) {
                attrs.append(.topMargin)
            }
            if contains(ConstraintAttributes.bottomMargin) {
                attrs.append(.bottomMargin)
            }
            if contains(ConstraintAttributes.leadingMargin) {
                attrs.append(.leadingMargin)
            }
            if contains(ConstraintAttributes.trailingMargin) {
                attrs.append(.trailingMargin)
            }
            if contains(ConstraintAttributes.centerXWithinMargins) {
                attrs.append(.centerXWithinMargins)
            }
            if contains(ConstraintAttributes.centerYWithinMargins) {
                attrs.append(.centerYWithinMargins)
            }
        #endif

        return attrs
    }
}

func + (left: ConstraintAttributes, right: ConstraintAttributes) -> ConstraintAttributes {
    left.union(right)
}

func += (left: inout ConstraintAttributes, right: ConstraintAttributes) {
    left.formUnion(right)
}

func -= (left: inout ConstraintAttributes, right: ConstraintAttributes) {
    left.subtract(right)
}

func == (left: ConstraintAttributes, right: ConstraintAttributes) -> Bool {
    left.rawValue == right.rawValue
}
