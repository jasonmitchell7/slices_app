import UIKit

extension CameraViewController: CameraFiltersViewDelegate, CameraMasksDelegate {
    internal func hideAllOptionsViews() {
        filtersView.isHidden = true
        filtersView.isUserInteractionEnabled = false
        filtersView.removeFromSuperview()
        
        parentSliceView.isHidden = true
        parentSliceView.isUserInteractionEnabled = false
        parentSliceView.removeFromSuperview()
        
        maskView.isHidden = true
        maskView.isUserInteractionEnabled = false
        maskView.removeFromSuperview()
        imgMain.removeFaceBoxes()
    }
    
    func showFilterOptions() {
        hideAllOptionsViews()
        
        if (sliceTimeline?.getSelectedSliceMedia() == nil) {
            logger.message(
                type: .error,
                message: "No selected media. Need to implement filters for current recording."
            )
            
            return
        }
        
        filtersView.delegate = self
        filtersView.sliceMedia = sliceTimeline!.getSelectedSliceMedia()!
        
        filtersView.frame = CGRect(
            x: 0,
            y: 0,
            width: optionsView.frame.width,
            height: optionsView.frame.height
        )
        filtersView.isHidden = false
        filtersView.isUserInteractionEnabled = true
        optionsView.addSubview(filtersView)
    }
    
    func showParentSliceOptions() {
        hideAllOptionsViews()
        
        if (parentSlice == nil) {
            logger.message(type: .error, message: "Attempted to show view for parent Slice when it was nil.")
            return
        }
        
        parentSliceView.frame = CGRect(
            x: 0,
            y: 0,
            width: optionsView.frame.width,
            height: optionsView.frame.height
        )
        parentSliceView.isHidden = false
        parentSliceView.isUserInteractionEnabled = true
        optionsView.addSubview(parentSliceView)
    }
    
    func showMaskOptions() {
        hideAllOptionsViews()
        
        maskView.delegate = self
        maskView.sliceMedia = sliceTimeline!.getSelectedSliceMedia()!
        
        maskView.frame = CGRect(
            x: 0,
            y: 0,
            width: optionsView.frame.width,
            height: optionsView.frame.height
        )
        maskView.isHidden = false
        maskView.isUserInteractionEnabled = true
        optionsView.addSubview(maskView)
    }
    
    func didChangeAppliedFilters(filterList: [String]) {
        sliceTimeline?.updateSelectedMediaFilters(filterList: filterList)
    }
    
    func didChangeMask(maskName: String?) {
        // Use the following for debugging.
        //if (maskName != nil) {
        //    imgMain.drawBoxesAroundFaces()
        //} else {
        //     imgMain.removeFaceBoxes()
        //}
        
        sliceTimeline?.updateSelectedMediaMask(maskName: maskName)
    }
    
    internal func updateOptionsViewOnDisplayChange() {
        if (filtersView.isHidden == false && sliceTimeline?.getSelectedSliceMedia() != nil) {
            filtersView.sliceMedia = sliceTimeline!.getSelectedSliceMedia()!
        } else if (maskView.isHidden == false && sliceTimeline?.getSelectedSliceMedia() != nil) {
            maskView.sliceMedia = sliceTimeline!.getSelectedSliceMedia()!
        }
    }
}
