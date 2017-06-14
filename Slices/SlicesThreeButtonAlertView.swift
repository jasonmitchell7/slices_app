import UIKit

protocol SlicesThreeButtonAlertDelegate {
    func threeButtonAlertCancelSelected()
    func threeButtonAlertFirstButtonSelected()
    func threeButtonAlertSecondButtonSelected()
}

class SlicesThreeButtonAlertView: NibLoadingView, SlicesModal {
    public var delegate: SlicesThreeButtonAlertDelegate?
    
    @IBOutlet weak var viewBlurredBackground: UIView!
    @IBOutlet weak var viewModalBackground: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    
    private var maxCharCount: Int?
    
    public func setup(title: String, description: String, cancelText: String, firstButtonText: String, secondButtonText: String, fullFrame: CGRect, blurBackground: Bool) {
        titleLabel.text = title
        descriptionLabel.text = description
        cancelButton.setTitle(cancelText, for: .normal)
        firstButton.setTitle(firstButtonText, for: .normal)
        secondButton.setTitle(secondButtonText, for: .normal)
        
        viewModalBackground.layer.cornerRadius = 8.0
        viewModalBackground.layer.masksToBounds = true
        
        if (blurBackground == true) {
            self.isOpaque = false
            viewBlurredBackground.isOpaque = false
            viewBlurredBackground.blur(style: .dark)
        }
        
        self.frame = fullFrame
    }
    
    @IBAction func didPressCancel(_ sender: UIButton) {
        if (self.delegate != nil) {
            delegate?.threeButtonAlertCancelSelected()
        }
        
        self.hideModal()
    }
    
    @IBAction func didPressFirstButton(_ sender: UIButton) {
        if (self.delegate != nil) {
            delegate?.threeButtonAlertFirstButtonSelected()
        }
        
        self.hideModal()
    }
    
    @IBAction func didPressSecondButton(_ sender: UIButton) {
        if (self.delegate != nil) {
            delegate?.threeButtonAlertSecondButtonSelected()
        }
        
        self.hideModal()
    }
}
