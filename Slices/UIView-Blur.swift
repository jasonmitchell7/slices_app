import UIKit

extension UIView {
    
    func removeBlur() {
        for subview in subviews {
            if (subview is UIVisualEffectView) {
                subview.removeFromSuperview()
                return
            }
        }
    }
    
    func blur(style: UIBlurEffectStyle) {
        removeBlur()
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
    }
}
