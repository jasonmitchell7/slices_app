import UIKit

class ConfirmEmailView: NibLoadingView, SlicesModal, UITextFieldDelegate {
    
    @IBOutlet weak var blurredBackground: UIView!
    @IBOutlet weak var modalBackground: UIView!
    
    @IBOutlet var codeDigits: [UITextField]!
    
    @IBOutlet weak var emailAddress: UILabel!
    
    @IBOutlet weak var resendCodeButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    func dismissKeyboard(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    public func setup(blurBackground: Bool) {
        modalBackground.layer.cornerRadius = 8.0
        modalBackground.layer.masksToBounds = true
        
        if (blurBackground == true) {
            self.isOpaque = false
            blurredBackground.isOpaque = false
            blurredBackground.blur(style: .dark)
        }
        
        if (currentUser?.email) != nil {
            emailAddress.text = currentUser!.email!
        } else {
            emailAddress.text = ""
        }
        
        for codeDigit in codeDigits {
            codeDigit.text = ""
            codeDigit.delegate = self
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                              action: #selector(dismissKeyboard(gestureRecognizer:)))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        
        checkIfShouldEnableButtons()
    }
    
    @IBAction func didPressCancel(_ sender: UIButton) {
        hideModal()
    }

    @IBAction func didPressChangeEmail(_ sender: UIButton) {
        print("pressed change email")
        // TODO: Implement this with new ShortTextViewModal
    }
    
    @IBAction func didPressResendCode(_ sender: UIButton) {
        print("pressed resend")
        sendResendConfirmationCodeRequest(completion: {(success, error) -> Void in
            let rootViewController = UIApplication.shared.keyWindow?.rootViewController
            
            if (rootViewController != nil) {
                let alertTitle: String = (success == true) ? "Code Sent" : "Error"
                var alertMessage: String = "Check your email for the super secret code!"
                if (success == false) {
                    if (error != nil) {
                        alertMessage = error!
                    } else {
                        alertMessage = "Oh no! Something went wrong!"
                    }
                }
                
                let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Back", style: UIAlertActionStyle.default, handler: nil))
                rootViewController?.present(alert, animated: true, completion: nil)
            }

        })
    }
    
    @IBAction func didPressConfirm(_ sender: UIButton) {
        if (sender.isEnabled == false) {
            return
        }
        
        let confirmationCode: String = codeDigits.reduce("", {(code: String, digit: UITextField) -> String in
            return code + ((digit.text == nil) ? "" : digit.text!)
        })
        sendConfirmEmailRequest(code: confirmationCode, completion: {(success, error) -> Void in
            let rootViewController = UIApplication.shared.keyWindow?.rootViewController
            
            if (rootViewController != nil) {
                let alertTitle: String = (success == true) ? "Success" : "Error"
                var alertMessage: String = "Email confirmed!"
                if (success == false) {
                    if (error != nil) {
                        alertMessage = error!
                    } else {
                        alertMessage = "Code was invalid, please check it and try again."
                    }
                }
                
                let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
                if (success == true) {
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: {(action) -> Void in
                        self.hideModal()
                    }))
                } else {
                    alert.addAction(UIAlertAction(title: "Back", style: UIAlertActionStyle.default, handler: nil))
                }
                rootViewController?.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    func isValidDigit(digit: String) -> Bool {
        if (digit.characters.count == 1) {
            if (Int(digit) != nil) {
                return true
            }
        }
        
        return false
    }
    
    func isConfirmationCodeValid() -> Bool {
        for codeDigit in codeDigits {
            if (codeDigit.text == nil) {
                return false
            }
            
            if (isValidDigit(digit: codeDigit.text!) == false) {
                return false
            }
        }
        
        return true
    }
    
    func enableButton(button: UIButton, shouldBeEnabled: Bool) {
        button.isEnabled = shouldBeEnabled
        
        if (shouldBeEnabled == true) {
            if (button == confirmButton) {
                button.backgroundColor = styleMgr.colorPrimary
            } else {
                button.backgroundColor = styleMgr.colorLight
            }
        } else {
            button.backgroundColor = styleMgr.colorLightGrey
        }
    }
    
    func checkIfShouldEnableButtons() {
        if (currentUser?.emailConfirmed == false) {
            enableButton(button: resendCodeButton, shouldBeEnabled: true)
            enableButton(button: confirmButton, shouldBeEnabled: isConfirmationCodeValid())
        } else {
            enableButton(button: resendCodeButton, shouldBeEnabled: false)
            enableButton(button: confirmButton, shouldBeEnabled: false)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (isValidDigit(digit: string)) {
            textField.text = string
            textField.resignFirstResponder()
            
            checkIfShouldEnableButtons()
            
            for (index, codeDigit) in codeDigits.enumerated() {
                if (index < codeDigits.count - 1 && textField == codeDigit) {
                    codeDigits[index + 1].becomeFirstResponder()
                    break
                }
            }
        }
        
        return false
    }
}
