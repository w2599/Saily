//
//  PackageSavedCollectionController.swift
//  Chromatic
//
//  Created by Lakr Aream on 2021/9/15.
//  Copyright © 2021 Lakr Aream. All rights reserved.
//

import AptRepository
import UIKit

class PackageSavedCollectionController: PackageCollectionController {
    override func viewDidLoad() {
        title = NSLocalizedString("COLLECTED_PACKAGES", comment: "Collected Packages")
        super.viewDidLoad()
        let clearItem = UIBarButtonItem(image: .fluent(.delete24Filled),
                                        style: .done,
                                        target: self,
                                        action: #selector(clearBlock))
        let installItem = UIBarButtonItem(title: NSLocalizedString("INSTALL_ALL", comment: "Install All (By.zp)"),
                                          style: .done,
                                          target: self,
                                          action: #selector(installAll))
        let spaceItem = UIBarButtonItem(title: "   ", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItems = [clearItem, spaceItem, installItem]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadCollectionItems()
    }

    @objc
    func clearBlock() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        let alert = UIAlertController(title: "⚠️",
                                      message: NSLocalizedString("THIS_OPERATION_CANNOT_BE_UNDONE", comment: "This operation cannot be undone."),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"),
                                      style: .cancel,
                                      handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("CONFIRM", comment: "CONFIRM"),
                                      style: .destructive,
                                      handler: { _ in
                                          InterfaceBridge.collectedPackages = []
                                          self.reloadCollectionItems()
                                          if let navigator = self.navigationController {
                                              navigator.popViewController()
                                          } else {
                                              self.dismiss(animated: true, completion: nil)
                                          }
                                      }))
        present(alert, animated: true, completion: nil)
    }

    @objc
    func installAll() {
        let collected = InterfaceBridge.collectedPackages
        var actions = [TaskManager.PackageAction]()
        for item in collected {
            guard item.repoRef != nil else { continue }
            guard let action = TaskManager.PackageAction(action: .install,
                                                         represent: item,
                                                         isUserRequired: true) else { continue }
            actions.append(action)
        }
        actions.forEach { TaskManager.shared.resolveInstall(action: $0) }
    }

    func reloadCollectionItems() {
        dataSource = InterfaceBridge
            .collectedPackages
            .sorted { a, b in
                PackageCenter.default.name(of: a)
                    < PackageCenter.default.name(of: b)
            }
        collectionView.reloadData()
        updateGuiderOpacity()
    }
}
