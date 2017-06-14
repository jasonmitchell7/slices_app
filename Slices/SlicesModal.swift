import UIKit

protocol SlicesModal {
    func hideModal()
}

extension SlicesModal where Self: UIView {
    func hideModal() {
        self.isHidden = true
        self.removeFromSuperview()
    }
}
