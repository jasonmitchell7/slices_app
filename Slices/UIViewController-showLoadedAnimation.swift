import UIKit

extension UIViewController {
    
    func showLoadedAnimation() {
        if(styleMgr.hasShownLoadedAnimation == false) {
            styleMgr.hasShownLoadedAnimation = true
            var loadedAnimationViewController: LoadedAnimationViewController?
            loadedAnimationViewController = LoadedAnimationViewController(nibName: "LoadedAnimation", bundle: nil)
            self.addChildViewController(loadedAnimationViewController!)
            loadedAnimationViewController!.animateGrowingIris(completion: {(success) -> Void in
                loadedAnimationViewController!.removeFromParentViewController()
                loadedAnimationViewController = nil
            })
        }
    }
    
}
