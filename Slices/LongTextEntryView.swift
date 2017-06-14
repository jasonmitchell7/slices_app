import UIKit

protocol LongTextEntryDelegate {
    func longTextEntryCancelSelected(text: String?)
    func longTextEntryOkaySelected(text: String)
}

class LongTextEntryView: NibLoadingView, SlicesModal, UITextViewDelegate {
    public var delegate: LongTextEntryDelegate?
    
    @IBOutlet weak var viewBlurredBackground: UIView!
    @IBOutlet weak var viewModalBackground: UIView!

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var lblCharactersRemaining: UILabel!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnOkay: UIButton!
    
    private var maxCharCount: Int?
    
    public func setup(title: String, cancelText: String, okayText: String, initialText: String, characterLimit: Int?, blurBackground: Bool) {
        lblTitle.text = title
        btnCancel.setTitle(cancelText, for: .normal)
        btnOkay.setTitle(okayText, for: .normal)
        maxCharCount = characterLimit
        
        textView.delegate = self
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = styleMgr.colorOffWhite.cgColor
        textView.layer.masksToBounds = true
        
        viewModalBackground.layer.cornerRadius = 8.0
        viewModalBackground.layer.masksToBounds = true
        
        lblCharactersRemaining.isHidden = true
        
        if (blurBackground == true) {
            self.isOpaque = false
            viewBlurredBackground.isOpaque = false
            viewBlurredBackground.blur(style: .dark)
        }
        
        textView.text = initialText
        updateCharactersRemaining(textView.text)
    }
    
    func updateCharactersRemaining(_ newText: String?) {
        if (maxCharCount != nil) {
            lblCharactersRemaining.isHidden = false
            
            var charCount = maxCharCount!
            if (newText != nil) {
                charCount = charCount - newText!.characters.count
            }
            lblCharactersRemaining.text = "Characters Remaining: \(charCount)"
            if (charCount < 0) {
                btnOkay.isEnabled = false
                btnOkay.isUserInteractionEnabled = false
                btnOkay.backgroundColor = UIColor.lightGray
            }
            else {
                btnOkay.isEnabled = true
                btnOkay.isUserInteractionEnabled = true
                btnOkay.backgroundColor = styleMgr.colorPrimary
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateCharactersRemaining(textView.text)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    @IBAction func didPressCancelUserDescription(_ sender: UIButton) {
        if (self.delegate != nil) {
            delegate?.longTextEntryCancelSelected(text: textView.text)
        }
        
        self.hideModal()
    }
    
    @IBAction func didPressUpdateUserDescription(_ sender: UIButton) {
        if (self.delegate != nil) {
            delegate?.longTextEntryOkaySelected(text: textView.text)
        }
        
        self.hideModal()
    }
}
