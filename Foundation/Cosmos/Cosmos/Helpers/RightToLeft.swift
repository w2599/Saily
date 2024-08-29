import UIKit

/**

 Helper functions for dealing with right-to-left languages.

 */
enum RightToLeft {
    static func isRightToLeft(_ view: UIView) -> Bool {
        if #available(iOS 9.0, *) {
            UIView.userInterfaceLayoutDirection(
                for: view.semanticContentAttribute) == .rightToLeft
        } else {
            false
        }
    }
}
