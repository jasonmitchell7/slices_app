import UIKit

extension UIViewController {
    func dismissKeyboardOnTouch() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                          action: #selector(dismissKeyboard(gestureRecognizer:)))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func dismissKeyboard(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}
