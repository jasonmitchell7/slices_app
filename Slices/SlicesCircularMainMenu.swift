import UIKit
import CircleMenu

var slicesCircularMainMenu: SlicesCircularMainMenu = SlicesCircularMainMenu()

// TODO: Make various properties and methods private.

class SlicesCircularMainMenu: CircleMenuDelegate {
    static let itemColor = styleMgr.colorPrimary
    static let backgroundColor = styleMgr.colorRed
    
    let items: [(icon: String, color: UIColor)] = [
        ("Slice", SlicesCircularMainMenu.itemColor),
        ("Convo", SlicesCircularMainMenu.itemColor),
        ("Edit", SlicesCircularMainMenu.itemColor),
        ("User", SlicesCircularMainMenu.itemColor),
        ("Camera", SlicesCircularMainMenu.itemColor),
        ]
    
    var sliceTableViewController: SliceTableViewController?
    var navigationController: UINavigationController?
    var containerView: UIView?
    var blurredBackground: UIView?
    var menu: CircleMenu?
    var buttonsEnabled: Bool = true
    
    func setRootSlicesTableViewController(to: SliceTableViewController) {
        if (sliceTableViewController == nil) {
            sliceTableViewController = to
            navigationController = to.navigationController
        }
    }
    
    func createContainerView() {
        if (containerView == nil) {
            containerView = UIView(
                frame:  CGRect(
                    origin: CGPoint(x: 0, y: 0),
                    size:   CGSize(
                        width: UIScreen.main.bounds.width,
                        height: UIScreen.main.bounds.height
                    )
                )
            )
            
            containerView!.isOpaque = false
            containerView!.backgroundColor = UIColor.clear
            
            UIApplication.shared.keyWindow?.addSubview(containerView!)
        }
    }
    
    func createBlurredBackground() {
        createContainerView()
        
        if (blurredBackground == nil) {
            blurredBackground =     UIView(
                                        frame:  CGRect(
                                                    origin: CGPoint(x: 0, y: 0),
                                                    size:   CGSize(
                                                                width: UIScreen.main.bounds.width,
                                                                height: UIScreen.main.bounds.height
                                                            )
                                                )
                                    )
            
            blurredBackground!.isOpaque = false
            blurredBackground!.blur(style: .dark)
            blurredBackground!.alpha = 0.4
         
            containerView!.addSubview(blurredBackground!)
        }
    }
    
    func createSlicesMenu() {
        if (menu == nil) {
            createBlurredBackground()
            menu = CircleMenu(
                frame: CGRect(x: (Int(UIScreen.main.bounds.width) - 80) / 2,
                              y: (Int(UIScreen.main.bounds.height) - 80) / 2,
                              width: 80,
                              height: 80),
                normalIcon:"x",
                selectedIcon:"x",
                buttonsCount: items.count,
                duration: 0.5,
                distance: 160)
            
            menu!.delegate = self
            containerView!.addSubview(menu!)
        }
    }
    
    func getSlicesMenu() -> CircleMenu {
        createSlicesMenu()
        
        return menu!
    }
    
    func showMenu() {
        createSlicesMenu()
        
        containerView?.isUserInteractionEnabled = true
        containerView?.isHidden = false
        
        menu!.sendActions(for: .touchUpInside)
    }
    
    func hideMenu() {
        containerView?.isUserInteractionEnabled = false
        containerView?.isHidden = true
    }
    
    func hideMenuWithDelay(_ circleMenu: CircleMenu) {
        DispatchQueue.main.asyncAfter(deadline: .now() + circleMenu.duration, execute: {
            self.hideMenu()
        })
    }
    
    func getViewControllerForItem(atIndex: Int) -> UIViewController? {
        if (items[atIndex].icon == "Slice") {
            if (sliceTableViewController != nil) {
                return sliceTableViewController!
            }
            
            logger.message(type: .error, message: "No SliceTableViewController set on main menu.")
            
            return nil
        }
        
        if (items[atIndex].icon == "User") {
            return UserViewController(nibName: "UserView", bundle: nil)
        }
        
        if (items[atIndex].icon == "Camera") {
            return CameraViewController(nibName: "CameraView", bundle: nil)
        }
        
        
        return nil
    }
    
    func navigateTo(viewController: UIViewController!, circleMenu: CircleMenu?) {

            if (self.navigationController != nil) {
                if (self.navigationController!.visibleViewController != viewController) {
                    if (self.navigationController!.viewControllers.contains(viewController)) {
                        self.navigationController!.popToViewController(viewController, animated: true)
                    } else {
                        self.navigationController!.pushViewController(viewController, animated: true)
                    }
                } else {
                        logger.message(type: .debug, message: "View controller attempted to navigate to itself.")
                }
            } else {
                logger.message(type: .debug, message: "Nil navigation controller found from Slices Circular Menu.")
            }
            self.hideMenu()

    }
    
    public func circleMenu(_ circleMenu: CircleMenu, willDisplay button: UIButton, atIndex: Int) {
        let items = slicesCircularMainMenu.items
        
        button.backgroundColor = items[atIndex].color
        
        button.setImage(UIImage(named: items[atIndex].icon), for: .normal)
    }
    
    public func menuCollapsed(_ circleMenu: CircleMenu) {
        hideMenu()
    }
    
    public func circleMenu(_ circleMenu: CircleMenu, buttonWillSelected button: UIButton, atIndex: Int) {
        if (slicesCircularMainMenu.buttonsEnabled == true) {
            let viewController: UIViewController? = slicesCircularMainMenu.getViewControllerForItem(atIndex: atIndex)
            
            if (viewController != nil) {
                navigateTo(viewController: viewController, circleMenu: circleMenu)
            }
        }
        
        hideMenu()
    }
    
    public func circleMenu(_ circleMenu: CircleMenu, buttonDidSelected button: UIButton, atIndex: Int) {
        hideMenuWithDelay(circleMenu)
    }
}
