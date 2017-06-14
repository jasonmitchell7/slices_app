import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var blurredBackgroundLower: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var btnReviewTerms: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var btnEmail: UIButton!
    @IBOutlet weak var btnAccountDetails: UIButton!
    @IBOutlet weak var btnBirthdate: UIButton!
    
    var emailViewController: EmailViewController!
    var accountDetailsViewController: AccountDetailsViewController!
    var birthdateViewController: BirthdateViewController!
    var currentChildViewController: UIViewController?
    
    var validEmail: String?
    var validUsername: String?
    var validPassword: String?
    var validBirthdate: Date?
    
    private let invalidColor = styleMgr.colorRed
    private let validColor = styleMgr.colorPrimary
    
    let actInd = ActivityIndicatorWithText(text: "Signing Up...")
    
    @IBAction func didPressReviewTerms(_ sender: UIButton) {
        // TODO: Add abaility to see ToS here.
    }
    
    @IBAction func didPressSignUp(_ sender: UIButton) {
        if (allFieldsValid() == false) {
            let alert = UIAlertController(title: "Missing Fields", message: "Please enter all fields then try again.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Back", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        actInd.show()
        
        requestSignUp(validUsername!, email: validEmail!, newPassword: validPassword!, birthdate: validBirthdate!,
                      completion: {(success, errorMessage) -> Void in
                        self.actInd.hide()
                        
                        if (success) {
                            let alert = UIAlertController(title: "Success", message: "The account was created successfully.", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Sign In", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            
                            self.dismiss(animated: true, completion: nil)
                        } else {
                            let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Back", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
        })
    }
    
    @IBAction func didPressEmail(_ sender: UIButton) {
        showChild(childViewController: emailViewController)
    }
    
    @IBAction func didPressAccountDetails(_ sender: UIButton) {
        showChild(childViewController: accountDetailsViewController)
    }
    
    @IBAction func didPressBirthdate(_ sender: UIButton) {
        showChild(childViewController: birthdateViewController)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dismissKeyboardOnTouch()
        
        if let sb = storyboard {
            emailViewController = sb.instantiateViewController(withIdentifier: "EmailViewController") as! EmailViewController
            accountDetailsViewController = sb.instantiateViewController(withIdentifier: "AccountDetailsViewController") as! AccountDetailsViewController
            birthdateViewController = sb.instantiateViewController(withIdentifier: "BirthdateViewController") as! BirthdateViewController
        }
        else {
            logger.message(type: .error, message: "Nil storyboard when attempting to instantiate child view for Sign Up View.")
        }
        
        emailViewController.signUpViewController = self
        accountDetailsViewController.signUpViewController = self
        birthdateViewController.signUpViewController = self
        
        setupAppearance()
    }
    
    func setupAppearance() {
        blurredBackgroundLower.addBorder(size: .none, color: .none, radius: .large)
        blurredBackgroundLower.blur(style: .dark)
        
        btnEmail.addBorder(size: .large, color: .white, radius: .none)
        btnAccountDetails.addBorder(size: .large, color: .white, radius: .none)
        btnBirthdate.addBorder(size: .large, color: .white, radius: .none)
        btnEmail.layer.cornerRadius = 40
        btnAccountDetails.layer.cornerRadius = 40
        btnBirthdate.layer.cornerRadius = 40
        
        btnReviewTerms.addBorder(size: .small, color: .white, radius: .large)
        btnSignUp.addBorder(size: .small, color: .white, radius: .large)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showChild(childViewController: emailViewController)
        
        updateIcons()
    }
    
    func updateIcons() {
        
        if (validEmail == nil) {
            btnEmail.backgroundColor = invalidColor
        }
        else {
            btnEmail.backgroundColor = validColor
        }
        
        if (validUsername == nil || validPassword == nil) {
            btnAccountDetails.backgroundColor = invalidColor
        }
        else {
            btnAccountDetails.backgroundColor = validColor
        }
        
        if (validBirthdate == nil) {
            btnBirthdate.backgroundColor = invalidColor
        }
        else {
            btnBirthdate.backgroundColor = validColor
        }
    }
    
    func removeCurrentChild() {
        if (currentChildViewController != nil) {
            currentChildViewController!.willMove(toParentViewController: nil)
            currentChildViewController!.view.removeFromSuperview()
            currentChildViewController!.removeFromParentViewController()
            currentChildViewController = nil
        }
    }
    
    func showChild(childViewController: UIViewController) {
        removeCurrentChild()
        
        childViewController.willMove(toParentViewController: self)
        containerView.addSubview(childViewController.view)
        addChildViewController(childViewController)
        childViewController.didMove(toParentViewController: self)
        
        currentChildViewController = childViewController
    }
    
    func allFieldsValid() -> Bool {
        if (validBirthdate == nil || validUsername == nil || validEmail == nil || validPassword == nil) {
            return false
        }
        
        return true
    }
}
