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

public class ConstraintMaker {
    public var left: ConstraintMakerExtendable {
        makeExtendableWithAttributes(.left)
    }

    public var top: ConstraintMakerExtendable {
        makeExtendableWithAttributes(.top)
    }

    public var bottom: ConstraintMakerExtendable {
        makeExtendableWithAttributes(.bottom)
    }

    public var right: ConstraintMakerExtendable {
        makeExtendableWithAttributes(.right)
    }

    public var leading: ConstraintMakerExtendable {
        makeExtendableWithAttributes(.leading)
    }

    public var trailing: ConstraintMakerExtendable {
        makeExtendableWithAttributes(.trailing)
    }

    public var width: ConstraintMakerExtendable {
        makeExtendableWithAttributes(.width)
    }

    public var height: ConstraintMakerExtendable {
        makeExtendableWithAttributes(.height)
    }

    public var centerX: ConstraintMakerExtendable {
        makeExtendableWithAttributes(.centerX)
    }

    public var centerY: ConstraintMakerExtendable {
        makeExtendableWithAttributes(.centerY)
    }

    @available(*, deprecated, renamed: "lastBaseline")
    public var baseline: ConstraintMakerExtendable {
        makeExtendableWithAttributes(.lastBaseline)
    }

    public var lastBaseline: ConstraintMakerExtendable {
        makeExtendableWithAttributes(.lastBaseline)
    }

    @available(iOS 8.0, OSX 10.11, *)
    public var firstBaseline: ConstraintMakerExtendable {
        makeExtendableWithAttributes(.firstBaseline)
    }

    @available(iOS 8.0, *)
    public var leftMargin: ConstraintMakerExtendable {
        makeExtendableWithAttributes(.leftMargin)
    }

    @available(iOS 8.0, *)
    public var rightMargin: ConstraintMakerExtendable {
        makeExtendableWithAttributes(.rightMargin)
    }

    @available(iOS 8.0, *)
    public var topMargin: ConstraintMakerExtendable {
        makeExtendableWithAttributes(.topMargin)
    }

    @available(iOS 8.0, *)
    public var bottomMargin: ConstraintMakerExtendable {
        makeExtendableWithAttributes(.bottomMargin)
    }

    @available(iOS 8.0, *)
    public var leadingMargin: ConstraintMakerExtendable {
        makeExtendableWithAttributes(.leadingMargin)
    }

    @available(iOS 8.0, *)
    public var trailingMargin: ConstraintMakerExtendable {
        makeExtendableWithAttributes(.trailingMargin)
    }

    @available(iOS 8.0, *)
    public var centerXWithinMargins: ConstraintMakerExtendable {
        makeExtendableWithAttributes(.centerXWithinMargins)
    }

    @available(iOS 8.0, *)
    public var centerYWithinMargins: ConstraintMakerExtendable {
        makeExtendableWithAttributes(.centerYWithinMargins)
    }

    public var edges: ConstraintMakerExtendable {
        makeExtendableWithAttributes(.edges)
    }

    public var horizontalEdges: ConstraintMakerExtendable {
        makeExtendableWithAttributes(.horizontalEdges)
    }

    public var verticalEdges: ConstraintMakerExtendable {
        makeExtendableWithAttributes(.verticalEdges)
    }

    public var directionalEdges: ConstraintMakerExtendable {
        makeExtendableWithAttributes(.directionalEdges)
    }

    public var directionalHorizontalEdges: ConstraintMakerExtendable {
        makeExtendableWithAttributes(.directionalHorizontalEdges)
    }

    public var directionalVerticalEdges: ConstraintMakerExtendable {
        makeExtendableWithAttributes(.directionalVerticalEdges)
    }

    public var size: ConstraintMakerExtendable {
        makeExtendableWithAttributes(.size)
    }

    public var center: ConstraintMakerExtendable {
        makeExtendableWithAttributes(.center)
    }

    @available(iOS 8.0, *)
    public var margins: ConstraintMakerExtendable {
        makeExtendableWithAttributes(.margins)
    }

    @available(iOS 8.0, *)
    public var directionalMargins: ConstraintMakerExtendable {
        makeExtendableWithAttributes(.directionalMargins)
    }

    @available(iOS 8.0, *)
    public var centerWithinMargins: ConstraintMakerExtendable {
        makeExtendableWithAttributes(.centerWithinMargins)
    }

    public let item: LayoutConstraintItem
    private var descriptions = [ConstraintDescription]()

    init(item: LayoutConstraintItem) {
        self.item = item
        self.item.prepare()
    }

    func makeExtendableWithAttributes(_ attributes: ConstraintAttributes) -> ConstraintMakerExtendable {
        let description = ConstraintDescription(item: item, attributes: attributes)
        descriptions.append(description)
        return ConstraintMakerExtendable(description)
    }

    static func prepareConstraints(item: LayoutConstraintItem, closure: (_ make: ConstraintMaker) -> Void) -> [Constraint] {
        let maker = ConstraintMaker(item: item)
        closure(maker)
        var constraints: [Constraint] = []
        for description in maker.descriptions {
            guard let constraint = description.constraint else {
                continue
            }
            constraints.append(constraint)
        }
        return constraints
    }

    static func makeConstraints(item: LayoutConstraintItem, closure: (_ make: ConstraintMaker) -> Void) {
        let constraints = prepareConstraints(item: item, closure: closure)
        for constraint in constraints {
            constraint.activateIfNeeded(updatingExisting: false)
        }
    }

    static func remakeConstraints(item: LayoutConstraintItem, closure: (_ make: ConstraintMaker) -> Void) {
        removeConstraints(item: item)
        makeConstraints(item: item, closure: closure)
    }

    static func updateConstraints(item: LayoutConstraintItem, closure: (_ make: ConstraintMaker) -> Void) {
        guard item.constraints.count > 0 else {
            makeConstraints(item: item, closure: closure)
            return
        }

        let constraints = prepareConstraints(item: item, closure: closure)
        for constraint in constraints {
            constraint.activateIfNeeded(updatingExisting: true)
        }
    }

    static func removeConstraints(item: LayoutConstraintItem) {
        let constraints = item.constraints
        for constraint in constraints {
            constraint.deactivateIfNeeded()
        }
    }
}
