import UIKit

class LoadedAnimationViewController: UIViewController {
    @IBOutlet weak var appIcon: UIImageView!
    
    func animateGrowingIris(completion: @escaping (Bool) -> Void) {
        UIView.animate(withDuration: 1.0,
                       animations:
                            {
                                //self.appIcon.transform = CGAffineTransform(scaleX: 2, y: 2)
                                //self.appIcon.alpha = 0
                            },
                       completion: completion)
    }
    
}
