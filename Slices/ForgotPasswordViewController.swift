import UIKit

class ForgotPasswordViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var btnSendIt: UIButton!
    
    @IBAction func didPressSendIt(_ sender: UIButton) {
        sendForgotPasswordEmail()
    }
    
    func sendForgotPasswordEmail() {
       // TODO: Add functionality.
    }
    
//    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnSendIt.addBorder(size: .small, color: .white, radius: .large)
        txtEmail.addBorder(size: .small, color: .white, radius: .large)
        
        txtEmail.delegate = self
        
        self.dismissKeyboardOnTouch()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtEmail.resignFirstResponder()
        sendForgotPasswordEmail()
        
        return true
    }
    
}
