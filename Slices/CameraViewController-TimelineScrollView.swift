import UIKit

extension CameraViewController: SliceTimelineDelegate, SliceTimelineEditingDelegate {
    
    func setupSliceTimeline() {
        if (sliceTimeline == nil && timelineView != nil) {
            sliceTimeline = SliceTimelineView()
            timelineView.addSubview(sliceTimeline!)
            sliceTimeline?.frame.origin = CGPoint.zero
            sliceTimeline?.frame.size = timelineView.frame.size
            sliceTimeline?.delegate = self
            sliceTimeline?.editingDelegate = self
            sliceTimeline?.createEmptyTimelineForEditing()
        }
    }
    
    func displayMediaFromTimelineBlock(image: UIImage) {
        imgMain.image = image
        updateOptionsViewOnDisplayChange()
        hideCapturedMedia(hide: false)
    }
    
    func changeInUploadValidity() {
        uploadButton.isEnabled = sliceTimeline!.sliceComposite.blocks.count > 0
        uploadButton.isUserInteractionEnabled = sliceTimeline!.sliceComposite.blocks.count > 0
    }
    
    func timelineCameraWasPressed() {
        hideCapturedMedia(hide: true)
    }
}
