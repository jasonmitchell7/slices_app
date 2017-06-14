import UIKit

class EmailViewController: UIViewController, UITextFieldDelegate {
    
    var signUpViewController: SignUpViewController!
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtRetypeEmail: UITextField!
    @IBOutlet weak var lblValidationError: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dismissKeyboardOnTouch()
        
        txtEmail.addTarget(self, action: #selector(validateEmail(textField:)), for: .editingChanged)
        txtRetypeEmail.addTarget(self, action: #selector(validateEmail(textField:)), for: .editingChanged)
        txtEmail.delegate = self
        txtRetypeEmail.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        validateEmail(textField: nil)
    }
    
    func validateEmail(textField: UITextField?) {
        if (!bothFieldsPresent()) {
            emailIsInvalid(errorMessage: nil)
            return
        }
        
        if (txtEmail.text != txtRetypeEmail.text) {
            emailIsInvalid(errorMessage: "The e-mails entered do not match.")
            return
        }
        
        if (!emailRegExTest(email: txtEmail.text!)){
            emailIsInvalid(errorMessage: "The e-mail entered is not valid.")
            return
        }
        
        // TODO: Check if e-mail is in use with API call.
        
        emailIsValid()
    }
    
    func bothFieldsPresent() -> Bool {
        if (txtEmail.text != nil && txtRetypeEmail.text != nil) {
            if (txtEmail.text!.characters.count > 0 && txtRetypeEmail.text!.characters.count > 0) {
                return true
            }
        }
        
        return false
    }
    
    func emailRegExTest(email:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluate(with: email)
    }
    
    func emailIsValid() {
        lblValidationError.isHidden = true
        
        signUpViewController.validEmail = txtEmail.text
        signUpViewController.updateIcons()
    }
    
    func emailIsInvalid(errorMessage: String?) {
        if (errorMessage != nil) {
            lblValidationError.text = errorMessage
            lblValidationError.isHidden = false
        }
        else {
            lblValidationError.isHidden = true
        }
        signUpViewController.validEmail = nil
        signUpViewController.updateIcons()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == txtEmail) {
            self.view.endEditing(true)
            txtRetypeEmail.becomeFirstResponder()
        }
        else if (textField == txtRetypeEmail) {
            self.view.endEditing(true)
            if (signUpViewController.validEmail != nil) {
                signUpViewController.showChild(childViewController: signUpViewController.accountDetailsViewController)
            }
        }
        
        return true
    }
}
