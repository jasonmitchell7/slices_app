import UIKit

extension CameraViewController {
    
    func showEnterTitleModal() {
        if (enterTitleModal != nil) {
            logger.message(type: .error, message: "Upload from Camera view attempted to load Enter Title Modal when it already existed.")
            return
        }
        
        setupSliceTimeline()
        
        enterTitleModal = LongTextEntryView()
        enterTitleModal?.frame = self.view.frame
        enterTitleModal?.bounds = self.view.bounds
        enterTitleModal?.delegate = self
        enterTitleModal?.setup(
            title: "Description",
            cancelText: "Cancel",
            okayText: "Upload",
            initialText: sliceTimeline!.sliceComposite.title,
            characterLimit: Slice.maxTitleLength,
            blurBackground: true
        )
        
        UIApplication.shared.keyWindow?.addSubview(enterTitleModal!)
    }
    
    func hideUserDescriptionModal() {
        enterTitleModal?.removeFromSuperview()
        enterTitleModal = nil
    }
    
    func startUploadOfCurrentMedia() {
        showEnterTitleModal()
        
        // TODO: Move actual upload to here, then hold on to upload id to publish or delete (if user cancels title or it is invalid).
        // Need published flag before doing that. This will increase perceived performance by the user, as uploads should appear faster.
    }
    
    func validateTitle() -> Bool {
        if (sliceTimeline!.sliceComposite.title.characters.count < Slice.minTitleLength) {
            return false
        }
        
        return true
    }
    
    func longTextEntryCancelSelected(text: String?) {
        if (text != nil) {
            sliceTimeline!.sliceComposite.title = text!
        }
        
        if (enterTitleModal != nil) {
            enterTitleModal?.textView.resignFirstResponder()
            enterTitleModal?.isHidden = true
            enterTitleModal = nil
        }
    }
    
    func longTextEntryOkaySelected(text: String) {
        sliceTimeline!.sliceComposite.title = text
        completeUploadOfCurrentMedia()
    }
    
    func completeUploadOfCurrentMedia() {
        // TODO: Refactor this to handle videos and Slice Composites.
        
        if validateTitle()  {
            showActivityIndicatorWithText(text: "Uploading...")
            
            uploadSlice(sliceTimeline!.sliceComposite, parentID: parentSlice?.sliceID, conversationID: nil, completion: {(success, errorMessage) -> Void in
                self.hideActivityIndicator()
                if (success == true) {
                    self.hideCapturedMedia(hide: true)
                }
                else {
                    let errorString = errorMessage == nil ? "" : ": \(errorMessage!)"
                    let alert = UIAlertController(title: "Could Not Upload", message: "Upload failed with error\(errorString).", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Back", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
        else {
            let alert = UIAlertController(title: "Invalid Description", message: "Please change the description of the \(getSliceOrToppingString()) and try again.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Back", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

}
