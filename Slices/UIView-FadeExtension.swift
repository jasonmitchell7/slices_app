import Foundation
import UIKit

extension UIView {
    
    func fadeInAndOut(duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        fadeIn(duration: duration/2, completion: {(success) -> Void in
            self.fadeOut(duration: duration/2, completion: completion)})
    }
    
    func fadeIn(duration: TimeInterval!, completion: ((Bool) -> Void)? = nil) {
        // Move our fade out code from earlier
        UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
            }, completion: completion)
    }
    
    func fadeOut(duration: TimeInterval!, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.alpha = 0.0
            }, completion: completion)
    }
}
