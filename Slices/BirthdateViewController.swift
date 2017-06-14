import UIKit

class BirthdateViewController: UIViewController {
    
    var signUpViewController: SignUpViewController!
    
    @IBOutlet weak var viewBlurBG: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var lblValidationError: UILabel!

    private let minimumAge = 13

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewBlurBG.addBorder(size: .none, color: .none, radius: .large)
        viewBlurBG.blur(style: .dark)
        datePicker.setValue(UIColor.white, forKeyPath: "textColor")
        
        let calendar = NSCalendar.current
        
        datePicker.minimumDate = calendar.date(byAdding: .year,
                                               value: -100,
                                               to: datePicker.date)
        datePicker.maximumDate = datePicker.date

        datePicker.date = calendar.date(byAdding: .year,
                                        value: -10,
                                        to: datePicker.date)!
        
        datePicker.addTarget(self, action: #selector(validateBirthdate), for: .valueChanged)
    }
    
    func validateBirthdate(sender: UIDatePicker) {
        let age = Calendar.current.dateComponents([.year], from: datePicker.date, to: Date()).year!
        if (age >= minimumAge) {
            signUpViewController.validBirthdate = datePicker.date
            lblValidationError.isHidden = true
        } else {
            signUpViewController.validBirthdate = nil
            lblValidationError.isHidden = false
        }
        
        signUpViewController.updateIcons()
    }
}
