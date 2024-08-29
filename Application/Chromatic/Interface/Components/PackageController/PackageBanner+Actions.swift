//
//  PackageBanner+Actions.swift
//  Chromatic
//
//  Created by Lakr Aream on 2021/8/20.
//  Copyright © 2021 Lakr Aream. All rights reserved.
//

import AptRepository
import Dog
import DropDown
import SnapKit
import SPIndicator
import UIKit

extension PackageBannerView {
    @objc
    func dropDownActionList(gestureReconizer: UILongPressGestureRecognizer?) {
        if gestureReconizer?.state != UIGestureRecognizer.State.began {
            return
        }
        let actions = obtainValidatedBannerActions()
        let dropDown = DropDown(anchorView: buttonAnchor,
                                selectionAction: {
                                    self.dealWithAction(actions: actions, index: $0, item: $1)
                                },
                                dataSource: obtainDropDownLabels(actions: actions),
                                topOffset: nil,
                                bottomOffset: nil,
                                cellConfiguration: nil,
                                cancelAction: nil)
        let gen = UIImpactFeedbackGenerator(style: .medium)
        gen.prepare()
        gen.impactOccurred()
        dropDown.show(onTopOf: window)
    }

    @objc
    func dropDownActionListQuick() {
        let actions = obtainValidatedBannerActions()
        dealWithAction(actions: actions, index: 0, item: "quick")
    }

    func dealWithAction(actions: [PackageMenuAction.MenuAction], index: Int, item _: String) {
        guard index >= 0, index < actions.count else {
            Dog.shared.join(self, "package action at index \(index) invalidated, cancel action", level: .error)
            let build = "      > " + actions
                .map { $0.descriptor.describe() }
                .joined(separator: "\n      > ")
            Dog.shared.join(self, "available actions are\n\(build)", level: .error)
            return
        }
        let action = actions[index]
        action.block(package, self)
    }

    func obtainValidatedBannerActions() -> [PackageMenuAction.MenuAction] {
        PackageMenuAction
            .allMenuActions
            .filter { $0.elegantForPerform(package) }
    }

    func obtainDropDownLabels(actions: [PackageMenuAction.MenuAction]) -> [String] {
        actions
            .map { $0.descriptor.describe() }
            // padding horizontal 🥺
            .invisibleSpacePadding()
    }
}
