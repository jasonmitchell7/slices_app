import UIKit

extension CameraViewController {
    
    func addKeyboardObservers() {
        print("Added keyboard observers.")
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
 
    override func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == startingViewFrame.origin.y {
                self.view.frame.origin.y -= (keyboardSize.height - tabBarHeight)
                
                if (enterTitleModal != nil) {
                    enterTitleModal?.view.frame.origin.y -= (keyboardSize.height - tabBarHeight) / 2
                }
            }
        }
    }
    
    override func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != startingViewFrame.origin.y {
                self.view.frame.origin.y += (keyboardSize.height - tabBarHeight)
                
                if (enterTitleModal != nil) {
                    enterTitleModal?.view.frame.origin.y += (keyboardSize.height - tabBarHeight) / 2
                }
            }
        }
    }
    
}
