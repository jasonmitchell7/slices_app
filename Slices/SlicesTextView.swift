import UIKit

class SlicesTextView: UITextView, UITextViewDelegate {
    var isShowingPlaceholderText = false
    var placeholderText: String?
    var maxCharacters: Int?
    var remainingCharactersLabel: UILabel?
    var remainingCharactersString = "Characters remaining:"
    var shouldFinishEditingOnLineBreak = false
    
    private var remainingCharacters = Int.max
    
    func setupSlicesTextView(placeholderText: String?, maxCharacters: Int?, remainingCharactersLabel: UILabel?, remainingCharactersString: String?, shouldFinishEditingOnLineBreak: Bool!) {
        self.placeholderText = placeholderText
        self.maxCharacters = maxCharacters
        self.remainingCharactersLabel = remainingCharactersLabel
        if remainingCharactersString != nil {
            self.remainingCharactersString = remainingCharactersString!
        }
        self.shouldFinishEditingOnLineBreak = shouldFinishEditingOnLineBreak
        self.delegate = self
        updateCharactersRemaining(newText: self.text)
        checkIfShowPlaceholder()
    }
    
    func checkIfShowPlaceholder(){
        if (placeholderText != nil && isShowingPlaceholderText == false && !self.isFirstResponder && self.text.isEmpty) {
            self.text = placeholderText!
            self.textColor = UIColor.gray
            isShowingPlaceholderText = true
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if isShowingPlaceholderText == true {
            self.text = ""
            self.textColor = UIColor.black
            isShowingPlaceholderText = false
        }
        
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        checkIfShowPlaceholder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateCharactersRemaining(newText: textView.text)
    }
    
    func updateCharactersRemaining(newText: String?) {
        if maxCharacters != nil {
            var charCount = maxCharacters!
            if (newText != nil) {
                charCount = charCount - newText!.characters.count
            }
            remainingCharacters = charCount
        }
        
        if remainingCharactersLabel != nil {
            remainingCharactersLabel!.text = "\(remainingCharactersString) \(remainingCharacters)"
        }
    }
    
    func getRemainingCharacters() -> Int! {
        return remainingCharacters
    }
    
    func isValidText() -> Bool {
        return remainingCharacters >= 0 ? true : false
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n" && shouldFinishEditingOnLineBreak) {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
