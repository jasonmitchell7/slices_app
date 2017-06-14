import UIKit

class AccountDetailsViewController: UIViewController, UITextFieldDelegate {
    
    var signUpViewController: SignUpViewController!
    
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtRetypePassword: UITextField!
    @IBOutlet weak var lblValidationError: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dismissKeyboardOnTouch()
        
        txtUsername.addTarget(self, action: #selector(validateAccountDetails(textField:)), for: .editingChanged)
        txtPassword.addTarget(self, action: #selector(validateAccountDetails(textField:)), for: .editingChanged)
        txtRetypePassword.addTarget(self, action: #selector(validateAccountDetails(textField:)), for: .editingChanged)
        txtUsername.delegate = self
        txtPassword.delegate = self
        txtRetypePassword.delegate = self
        
        validateAccountDetails(textField: nil)
    }
    
    func validateAccountDetails(textField: UITextField?) {
        if (!allFieldsPresent()) {
            accountDetailsInvalid(errorMessage: nil)
            return
        }
        
        if (validateUsername() && validatePassword()) {
            accountDetailsValid()
        }
        
    }
    
    func validateUsername() -> Bool {
        // TODO: Add async call to check valid username here... do it after every new char typed?
        return true
    }
    
    func validatePassword() -> Bool {
        if (txtPassword.text!.characters.count < 8) {
            accountDetailsInvalid(errorMessage: "Password must be at least 8 characters long.")
            return false
        }
        
        if (txtPassword.text != txtRetypePassword.text) {
            accountDetailsInvalid(errorMessage: "Passwords do not match.")
            return false
        }
        
        return true
    }
    
    func allFieldsPresent() -> Bool {
        if (txtUsername.text != nil && txtPassword.text != nil && txtRetypePassword.text != nil) {
            if (txtUsername.text!.characters.count > 0 && txtPassword.text!.characters.count > 0 && txtRetypePassword.text!.characters.count > 0) {
                return true
            }
        }
        
        return false
    }
    
    func accountDetailsInvalid(errorMessage: String?) {
        if (errorMessage != nil) {
            lblValidationError.text = errorMessage
            lblValidationError.isHidden = false
        }
        else {
            lblValidationError.isHidden = true
        }
    }
    
    func accountDetailsValid() {
        lblValidationError.isHidden = true
        signUpViewController.validUsername = txtUsername.text
        signUpViewController.validPassword = txtPassword.text
        signUpViewController.updateIcons()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == txtUsername) {
            self.view.endEditing(true)
            txtPassword.becomeFirstResponder()
        }
        if (textField == txtPassword) {
            self.view.endEditing(true)
            txtRetypePassword.becomeFirstResponder()
        }
        else if (textField == txtRetypePassword) {
            self.view.endEditing(true)
            if (signUpViewController.validUsername != nil && signUpViewController.validPassword != nil) {
                signUpViewController.showChild(childViewController: signUpViewController.birthdateViewController)
            }
        }
        
        return true
    }
}
