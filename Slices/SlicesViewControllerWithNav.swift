import UIKit

class SlicesViewControllerWithNav: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupRightBarItem()
    }
    
    func setupRightBarItem() {
        if (self.navigationController != nil) {
            if (self.navigationItem.rightBarButtonItem == nil) {
                
                let rightButtonItem = UIBarButtonItem.init(
                    image: UIImage(named: "menuItem"),
                    style: UIBarButtonItemStyle.plain,
                    target: self,
                    action: #selector(rightItemTapped(_:))
                )
                
                self.navigationItem.setRightBarButton(rightButtonItem, animated: true)
                
            } else {
                print("RIGHT NAV BAR ITEM ALREADY SET")
            }
        } else {
            logger.message(type: .error, message: "ViewControllerWithSlicesNavBar found nil navigation controller.")
        }
    }
    
    func rightItemTapped(_ sender: UIBarButtonItem) {
        slicesCircularMainMenu.showMenu()
    }
}
