import UIKit

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var txtUsernameOrEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var btnFacebook: UIButton!
    @IBOutlet weak var btnGoogle: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    
    let actInd = ActivityIndicatorWithText(text: "Signing in...")

    @IBAction func didPressSignIn(_ sender: UIButton) {
        doSignIn()
    }

    @IBAction func didPressSignInWithFacebook(_ sender: UIButton) {
        // TODO: Add functionality.
    }
    
    @IBAction func didPressSignInWithGoogle(_ sender: UIButton) {
        // TODO: Add functionality.
    }
    
    @IBAction func didPressSignUp(_ sender: UIButton) {
        performSegue(withIdentifier: "signInToSignUp", sender: self)
    }
    
    @IBAction func didPressForgotPassword(_ sender: UIButton) {
        performSegue(withIdentifier: "signInToForgotPassword", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnSignIn.addBorder(size: .small, color: .white, radius: .large)
        btnGoogle.addBorder(size: .small, color: .white, radius: .large)
        btnFacebook.addBorder(size: .small, color: .white, radius: .large)
        btnSignUp.addBorder(size: .small, color: .white, radius: .large)
        txtUsernameOrEmail.addBorder(size: .small, color: .white, radius: .large)
        txtPassword.addBorder(size: .small, color: .white, radius: .large)
        
        txtUsernameOrEmail.delegate = self
        txtPassword.delegate = self
        
        self.dismissKeyboardOnTouch()
        
        self.showLoadedAnimation()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    func validateSignInDetails() -> Bool {
        if (txtUsernameOrEmail.text == nil || txtPassword.text == nil) {
            // TODO: Add alert.
            return false
        }
        else if (txtUsernameOrEmail.text!.characters.count < 5) {
            // TODO: Add alert.
            return false
        }
        else if (txtPassword.text!.characters.count < 8) {
            // TODO: Add alert.
            return false
        }
        else {
            return true
        }
    }
    
    func dismissKeyboards() {
        if (txtUsernameOrEmail.isFirstResponder) {
            txtUsernameOrEmail.resignFirstResponder()
        }
        
        if (txtPassword.isFirstResponder) {
            txtPassword.resignFirstResponder()
        }
    }
    
    func doSignIn() {
        dismissKeyboards()
        if (validateSignInDetails()) {
            
            self.view.addSubview(actInd)
            self.actInd.show()
            
            sessionMgr.makeSignInRequest(txtUsernameOrEmail.text!, userPassword: txtPassword.text!, completion:{ (success, errorMessage) -> Void in
                if (success) {
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }
                else{
                    if (errorMessage != nil)
                    {
                        self.actInd.hide()
                        
                        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Back", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            })
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == txtUsernameOrEmail) {
            dismissKeyboards()
            txtPassword.becomeFirstResponder()
        }
        else if (textField == txtPassword) {
            doSignIn()
        }
        
        return true
    }
}
