import UIKit
import CircleMenu

extension UIViewController: CircleMenuDelegate {
//    func addCircularMainMenuGesture() {
//        let gestureRecognizer = UILongPressGestureRecognizer(target: self,
//                                                             action: #selector(menuGestureAction(gestureRecognizer:)))
//        view.addGestureRecognizer(gestureRecognizer)
//    }
//    
//    
//    func menuGestureAction(gestureRecognizer: UILongPressGestureRecognizer) {
//        showMenu()
//    }
//    
//    func showMenu() {
//        //self.view.blur(style: .dark)
//        let circleMenuView = getCircleMenu()
//        if (circleMenuView == nil) {
//            initMenu()
//        }
//        circleMenuView?.isHidden = false
//        circleMenuView?.isUserInteractionEnabled = true
//    }
//    
//    func hideMenuWithDelay(_ circleMenu: CircleMenu) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + circleMenu.duration, execute: {
//                self.hideMenu()
//        })
//    }
//    
//    func hideMenu() {
//        //self.view.removeBlur()
//        let circleMenu = getCircleMenu()
//        circleMenu?.isHidden = true
//        circleMenu?.isUserInteractionEnabled = false
//    }
//    
//    func getCircleMenu() -> UIView? {
//        for subview in view.subviews {
//            if (subview is CircleMenu) {
//                return subview
//            }
//        }
//        
//        return nil
//    }
//    
//    func initMenu() {
//        let menuButton = slicesCircularMainMenu.getMenu()
//        menuButton.backgroundColor = SlicesCircularMainMenu.backgroundColor
//        menuButton.delegate = self
//        menuButton.layer.cornerRadius = menuButton.frame.size.width / 2.0
//        view.addSubview(menuButton)
//        menuButton.sendActions(for: .touchUpInside)
//    }
//    
//    public func circleMenu(_ circleMenu: CircleMenu, willDisplay button: UIButton, atIndex: Int) {
//        let items = slicesCircularMainMenu.items
//        
//        button.backgroundColor = items[atIndex].color
//        
//        button.setImage(UIImage(named: items[atIndex].icon), for: .normal)
//    }
//    
//    public func menuCollapsed(_ circleMenu: CircleMenu) {
//        circleMenu.isHidden = true
//        circleMenu.isUserInteractionEnabled = false
//        hideMenuWithDelay(circleMenu)
//    }
//    
//    public func circleMenu(_ circleMenu: CircleMenu, buttonWillSelected button: UIButton, atIndex: Int) {
//        if (slicesCircularMainMenu.buttonsEnabled == true) {
//            circleMenu.isHidden = true
//            let viewController: UIViewController? = slicesCircularMainMenu.getViewControllerForItem(atIndex: atIndex)
//        
//            if (viewController != nil) {
//                navigateToNew(viewController: viewController, circleMenu: circleMenu)
//            }
//        }
//    }
//    
//    public func circleMenu(_ circleMenu: CircleMenu, buttonDidSelected button: UIButton, atIndex: Int) {
//        hideMenuWithDelay(circleMenu)
//    }
//    
//    func navigateToNew(viewController: UIViewController!, circleMenu: CircleMenu?) {
//        var delay = 0.0
//        
//        slicesCircularMainMenu.buttonsEnabled = false
//        
//        if (circleMenu != nil) {
//            // 0.5 is a hard coded duration for the expand and fade out animation
//            // of the circle menu
//            delay = circleMenu!.duration + 0.5
//        }
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
//            if (viewController != self) {
//                if (self.navigationController != nil) {
//                    if (self.navigationController!.viewControllers.contains(viewController)) {
//                        self.navigationController!.popToViewController(viewController, animated: true)
//                    } else {
//                        self.navigationController!.pushViewController(viewController, animated: true)
//                    }
//                } else {
//                    self.present(viewController!, animated: true, completion: nil)
//                }
//            } else {
//                logger.message(type: .debug, message: "View controller attempted to navigate to itself.")
//            }
//            self.hideMenu()
//            slicesCircularMainMenu.buttonsEnabled = true
//        })
//    }
}
