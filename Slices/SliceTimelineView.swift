import UIKit

protocol SliceTimelineDelegate {
    func displayMediaFromTimelineBlock(image: UIImage)
}

protocol SliceTimelineEditingDelegate {
    func changeInUploadValidity()
    func timelineCameraWasPressed()
}

class SliceTimelineView: NibLoadingView {
    
    @IBOutlet weak var timelineScrollView: UIScrollView!
    
    var delegate: SliceTimelineDelegate?
    var editingDelegate: SliceTimelineEditingDelegate?
    var showPreview: Bool = false
    var shouldDispalyNextMedia: Bool = true
    var nextMediaTimer: Timer?
    var nextMediaIndex: Int = 0
    var progressView: UIView?
    var sliceComposite = SliceComposite()
    
    private var isTimelinePanning: Bool = false
    
    var slice: Slice? {
        didSet {
            if (slice == nil) {
                removeAllSubviewsFromTimeline()
            } else {
                loadSliceIntoTimeline()
            }
        }
    }
    
    var selectedTimelineBlockIndex: Int? {
        didSet {
            if (selectedTimelineBlockIndex == nil && isEditingAllowed() == true) {
                editingDelegate?.timelineCameraWasPressed()
            }
            displayBlockBorders(highlightBlockIndex: selectedTimelineBlockIndex)
        }
    }
    
    func getSelectedSliceMedia() -> SliceMedia? {
        if (selectedTimelineBlockIndex != nil) {
            if (selectedTimelineBlockIndex! >= 0 && selectedTimelineBlockIndex! < sliceComposite.blocks.count) {
                return sliceComposite.blocks[selectedTimelineBlockIndex!].sliceMedia
            }
        }
        
        return nil
    }
    
    func updateSelectedMediaFilters(filterList: [String]) {
        if (selectedTimelineBlockIndex != nil) {
            if (selectedTimelineBlockIndex! >= 0 && selectedTimelineBlockIndex! < sliceComposite.blocks.count) {
                sliceComposite.blocks[selectedTimelineBlockIndex!].sliceMedia.filters = filterList
                
                if (sliceComposite.blocks[selectedTimelineBlockIndex!].sliceMedia.image != nil) {
                    if let blockView = getViewForTimelineBlock(atIndex: selectedTimelineBlockIndex!) {
                        let newImage = sliceComposite.blocks[selectedTimelineBlockIndex!].sliceMedia.getImageWithEffects()
                        blockView.setImage(newImage, for: .normal)
                        delegate?.displayMediaFromTimelineBlock(image: newImage)
                    }
                }
            }
        }
    }
    
    func updateSelectedMediaMask(maskName: String?) {
        if (selectedTimelineBlockIndex != nil) {
            if (selectedTimelineBlockIndex! >= 0 && selectedTimelineBlockIndex! < sliceComposite.blocks.count) {
                sliceComposite.blocks[selectedTimelineBlockIndex!].sliceMedia.maskName = maskName
                
                if (sliceComposite.blocks[selectedTimelineBlockIndex!].sliceMedia.image != nil) {
                    if let blockView = getViewForTimelineBlock(atIndex: selectedTimelineBlockIndex!) {
                        let newImage = sliceComposite.blocks[selectedTimelineBlockIndex!].sliceMedia.getImageWithEffects()
                        blockView.setImage(newImage, for: .normal)
                        delegate?.displayMediaFromTimelineBlock(image: newImage)
                    }
                }
            }
        }
    }
    
    func addTimelineBlock(image: UIImage) {
        sliceComposite.addBlock(withImage: image)
        layoutTimelineViews()
        nextMediaIndex = sliceComposite.blocks.count - 1
        selectedTimelineBlockIndex = nextMediaIndex
        displayNextMedia()
        scrollToTimelineEnd()
        
        editingDelegate?.changeInUploadValidity()
    }
    
    func createEmptyTimelineForEditing() {
        if (slice != nil) {
            slice = nil
        }
        
        sliceComposite.reset()
        
        shouldDispalyNextMedia = true
        stopTimer()
        nextMediaIndex = 0
        
        layoutTimelineViews()
        
        editingDelegate?.changeInUploadValidity()
    }
    
    func deleteSelectedTimelineBlock() {
        if (selectedTimelineBlockIndex == nil) {
            logger.message(type: .error, message: "Attempted to delete selected media from camera, but no media selected.")
            return
        }
        
        deleteTimelineBlock(index: selectedTimelineBlockIndex!)
        
        editingDelegate?.changeInUploadValidity()
    }
    
    func deleteTimelineBlock(index: Int) {
        sliceComposite.deleteBlock(index: index)
        selectedTimelineBlockIndex = nil
        layoutTimelineViews()
        scrollToTimelineEnd()
    }
    
    private func isEditingAllowed() -> Bool {
        return (editingDelegate != nil)
    }

    private func removeAllSubviewsFromTimeline() {
        let subviews = timelineScrollView.subviews
        
        for subview in subviews {
            if (subview.tag == SliceTimelineBlock.size) {
                subview.removeFromSuperview()
            }
        }
        
        timelineScrollView.contentSize = self.frame.size
        timelineScrollView.contentOffset = CGPoint.zero
        
        selectedTimelineBlockIndex = nil
    }
    
    private func loadSliceIntoTimeline() {
        removeAllSubviewsFromTimeline()
        sliceComposite.initFromSlice(slice: slice!)
        
        layoutTimelineViews()
        
        shouldDispalyNextMedia = true
        stopTimer()
        nextMediaIndex = 0
        
        if (sliceComposite.isAllMediaLoaded() == true) {
            displayNextMedia()
        } else {
            loadNextTimelineBlockMedia()
        }
    }
    
    private func incrementMediaIndex() {
        nextMediaIndex += 1
        
        if (nextMediaIndex == sliceComposite.blocks.count) {
            nextMediaIndex = 0
        }
    }
    
    private func displayBlockBorders(highlightBlockIndex: Int?) {
        if (isTimelinePanning == true) {
            return
        }
        
        var blockIndex: Int = 0
        
        for subview in timelineScrollView.subviews {
            if (subview.tag == SliceTimelineBlock.size) {
                subview.layer.borderWidth = 0
                
                if (subview.gestureRecognizers != nil) {
                    for gesture in (subview.gestureRecognizers)! {
                        if let panGestureRecognizer = gesture as? UIPanGestureRecognizer {
                            subview.removeGestureRecognizer(panGestureRecognizer)
                        }
                    }
                }
                
                if (isEditingAllowed() == true && blockIndex == sliceComposite.blocks.count) {
                    if (highlightBlockIndex != nil) {
                        subview.tintColor = UIColor.white
                    } else {
                        subview.tintColor = styleMgr.colorPrimary
                    }
                }
                
                blockIndex += 1
            }
        }
        
        if (highlightBlockIndex != nil) {
            if let blockView = getViewForTimelineBlock(atIndex: highlightBlockIndex!) {
                blockView.layer.borderColor = styleMgr.colorOffWhite.cgColor
                blockView.layer.borderWidth = 2
                
                if (isEditingAllowed() == true) {
                    let gestureRecognizer = UIPanGestureRecognizer(
                        target: self,
                        action: #selector(didPanTimelineBlock(sender:))
                    )
                    blockView.addGestureRecognizer(gestureRecognizer)
                }
                
                ensureBlockIsVisible(blockIndex: highlightBlockIndex!)
            }
        }
    }
    
    func ensureBlockIsVisible(blockIndex: Int) {
        if (timelineScrollView.isScrollEnabled == false) {
            return
        }
        
        let blockPosition: CGFloat = CGFloat(getPositionForTimelineBlock(atIndex: blockIndex))
        let blockSize: CGFloat = CGFloat(SliceTimelineBlock.size)
        var newOffset: CGFloat?
        
        if (blockPosition < timelineScrollView.contentOffset.x) {
            newOffset = blockPosition
        } else if ((blockPosition + blockSize) > (timelineScrollView.contentOffset.x + timelineScrollView.frame.width)) {
            newOffset = blockPosition + blockSize
        }
        
        if (newOffset != nil) {
            if (newOffset! > timelineScrollView.contentSize.width - timelineScrollView.frame.width - blockSize) {
                newOffset = timelineScrollView.contentSize.width - timelineScrollView.frame.width - blockSize
            }
            UIView.animate(withDuration: 0.3, animations: {() -> Void in
                self.timelineScrollView.contentOffset.x = newOffset!
            })
        }
    }
    
    func displayNextMedia() {
        if (sliceComposite.blocks[nextMediaIndex].isMediaLoaded() == true) {
            if (sliceComposite.blocks[nextMediaIndex].sliceMedia.image != nil) {
                delegate?.displayMediaFromTimelineBlock(image: sliceComposite.blocks[nextMediaIndex].sliceMedia.getImageWithEffects())
                shouldDispalyNextMedia = false
                if (isEditingAllowed() == false || showPreview == true) {
                    startTimer(duration: sliceComposite.blocks[nextMediaIndex].sliceMedia.duration)
                }
                displayBlockBorders(highlightBlockIndex: nextMediaIndex)
                
                incrementMediaIndex()
            }
        } else {
            stopTimer()
            shouldDispalyNextMedia = true
        }
    }
    
    private func displayMedia(atIndex: Int) {
        if (atIndex >= 0 && atIndex < sliceComposite.blocks.count) {
            if (sliceComposite.blocks[atIndex].isMediaLoaded()) {
                nextMediaTimer?.invalidate()
                nextMediaIndex = atIndex
                displayNextMedia()
            }
        }
    }
    
    private func checkIfShouldDisplayNextMedia() {
        if (shouldDispalyNextMedia == true) {
            displayNextMedia()
        }
    }
    
    private func addBlockToTimeline(atIndex: Int) {
        let position = getPositionForTimelineBlock(atIndex: atIndex)
        let button: UIButton = UIButton(type: .custom)
        
        button.tag = SliceTimelineBlock.size
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.cornerRadius = CGFloat(SliceTimelineBlock.size / 2)
        button.clipsToBounds = true
        
        if (sliceComposite.blocks[atIndex].isMediaLoaded()) {
            if (sliceComposite.blocks[atIndex].sliceMedia.image != nil) {
                button.setImage(sliceComposite.blocks[atIndex].sliceMedia.getImageWithEffects(), for: .normal)
            }
        } else {
            button.isUserInteractionEnabled = false
            button.backgroundColor = styleMgr.colorLightGrey
        }
        
        button.addTarget(self, action: #selector(didPressDisplayMediaForBlock(_:)), for: .touchUpInside)

        timelineScrollView.addSubview(button)
        
        button.frame = CGRect(
            x: position,
            y: 2,
            width: SliceTimelineBlock.size,
            height: SliceTimelineBlock.size
        )
    }
    
    private func scrollToTimelineEnd() {
        timelineScrollView.contentOffset = CGPoint(
            x: timelineScrollView.contentSize.width - timelineScrollView.frame.width,
            y: CGFloat(0)
        )
    }
    
    func addCameraIconToEndOfTimeline(position: Int) {
        let image = UIImage(named: "Camera")
        
        let button: UIButton = UIButton(type: .system)
        
        button.setImage(image, for: .normal)
        button.tag = SliceTimelineBlock.size
        
        button.addTarget(self, action: #selector(didPressCameraButton(_:)), for: .touchUpInside)
        
        timelineScrollView.addSubview(button)
        
        button.frame = CGRect(
            x: position,
            y: 0,
            width: SliceTimelineBlock.size,
            height: SliceTimelineBlock.size
        )
    }
    
    private func stylizeTimelineView() {
        timelineScrollView.addBorderForTimeline()
    }
    
    private func layoutTimelineViews() {
        if (isTimelinePanning == true) {
            return
        }
        
        removeAllSubviewsFromTimeline()
        
        stylizeTimelineView()
        
        var index: Int = 0
        
        for _ in sliceComposite.blocks {
            addBlockToTimeline(atIndex: index)
            
            index = index + 1
        }
        
        if (isEditingAllowed() == true) {
            addCameraIconToEndOfTimeline(position: getPositionForTimelineBlock(atIndex: index))
        }
        
        timelineScrollView.contentSize = CGSize(
            width: CGFloat(getPositionForTimelineBlock(atIndex: index + 1)),
            height: timelineScrollView.frame.height
        )
        
        timelineScrollView.isScrollEnabled = timelineScrollView.contentSize.width > timelineScrollView.frame.width
        timelineScrollView.isUserInteractionEnabled = true
    }
    
    private func loadNextTimelineBlockMedia() {
        sliceComposite.loadNextMedia(completion: {(success, isAllMediaLoaded, loadedIndex) -> Void in
            if (success == true && loadedIndex != nil) {
                self.setLoadedMediaIntoBlock(blockIndex: loadedIndex!)
            }
            
            if (success == true && isAllMediaLoaded == false) {
                self.loadNextTimelineBlockMedia()
            }
        })
    }
    
    private func setLoadedMediaIntoBlock(blockIndex: Int) {
        if let blockButton = self.getViewForTimelineBlock(atIndex: blockIndex) {
            if (sliceComposite.blocks[blockIndex].sliceMedia.image != nil) {
                blockButton.setImage(sliceComposite.blocks[blockIndex].sliceMedia.getImageWithEffects(), for: .normal)
                blockButton.isUserInteractionEnabled = true
                
                checkIfShouldDisplayNextMedia()
            }
        }
    }
    
    private func getPositionForTimelineBlock(atIndex: Int) -> Int {
        return (atIndex * SliceTimelineBlock.size) + (atIndex * 2)
    }
    
    private func getIndexForTimelineBlock(atX: CGFloat) -> Int {
        return Int(floor(atX / CGFloat(SliceTimelineBlock.size + 2)))
    }
    
    private func getViewForTimelineBlock(atIndex: Int) -> UIButton? {
        let subviews = timelineScrollView.subviews
        
        for subview in subviews {
            if (subview.tag == SliceTimelineBlock.size) {
                if (getIndexForTimelineBlock(atX: subview.center.x) == atIndex) {
                    if let button = subview as? UIButton {
                        return button
                    }
                }
            }
        }
        
        return nil
    }
    
    private func setupProgressView() {
        if (progressView == nil) {
            let clippingView = UIView()
            clippingView.addBorderForTimeline()
            clippingView.layer.borderWidth = 0
            clippingView.frame = self.frame
            self.view.insertSubview(clippingView, belowSubview: timelineScrollView)
            
            progressView = UIView()
            progressView?.backgroundColor = styleMgr.colorPrimary
            clippingView.insertSubview(progressView!, belowSubview: clippingView)
        }
        
        progressView?.frame = CGRect(
            x: -frame.width,
            y: 0,
            width: frame.width,
            height: frame.height
        )
    }
    
    private func startTimer(duration: Int) {
        let timeInterval = TimeInterval(duration)
        nextMediaTimer = Timer.scheduledTimer(
            timeInterval: timeInterval,
            target: self,
            selector: #selector(displayNextMedia),
            userInfo: nil,
            repeats: false
        )
        
        setupProgressView()
        UIView.animate(withDuration: timeInterval, animations: {() -> Void in
            self.progressView?.frame = CGRect(
                x: 0,
                y: 0,
                width: self.frame.width,
                height: self.frame.height
            )
        })
    }
    
    private func stopTimer() {
        nextMediaTimer?.invalidate()
        setupProgressView()
    }
    
    func didPressDisplayMediaForBlock(_ button: UIButton) {
        let index = getIndexForTimelineBlock(atX: button.center.x)
        logger.message(type: .information, message: "Tapped timeline block to display media at index: \(index) with current selection: \(selectedTimelineBlockIndex).")
        if (selectedTimelineBlockIndex == index) {
            selectedTimelineBlockIndex = nil
        } else {
            selectedTimelineBlockIndex = index
        }
        displayMedia(atIndex: index)
    }
    
    func didPanTimelineBlock(sender: UIPanGestureRecognizer) {
        if (sender.state == .began) {
            logger.message(type: .information, message: "Timeline block at index \(selectedTimelineBlockIndex) started pan gesture.")
            isTimelinePanning = true
            sender.view?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } else if (sender.state == .ended || sender.state == .cancelled || sender.state == .failed) {
            logger.message(type: .information, message: "Pan gesture ended or was cancelled.")
            sender.view?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            isTimelinePanning = false
            let index = getIndexForTimelineBlock(atX: sender.location(in: timelineScrollView).x)
            if (index == sliceComposite.blocks.count) {
                selectedTimelineBlockIndex = index - 1
            } else {
                selectedTimelineBlockIndex = getIndexForTimelineBlock(atX: sender.location(in: timelineScrollView).x)
            }
        } else if (sender.state == .changed && selectedTimelineBlockIndex != nil) {
            let newIndex = getIndexForTimelineBlock(atX: sender.location(in: timelineScrollView).x)
            
            if (newIndex >= 0 && newIndex < sliceComposite.blocks.count && sender.view != nil && newIndex != selectedTimelineBlockIndex) {
                let viewToSwap = getViewForTimelineBlock(atIndex: newIndex)
                
                if (viewToSwap != nil) {
                    UIView.animate(
                        withDuration: 0.2,
                        animations: { () -> Void in
                            let selectedCenter = sender.view!.center
                            sender.view!.center = viewToSwap!.center
                            viewToSwap!.center = selectedCenter
                            self.sliceComposite.swapBlocksAt(indexA: self.selectedTimelineBlockIndex!, indexB: newIndex)
                            self.selectedTimelineBlockIndex = newIndex
                    }
                    )
                }
            }
            
            if (timelineScrollView.isScrollEnabled == true) {
                let scrollBuffer = CGFloat(SliceTimelineBlock.size)
                let scrollSpeed = CGFloat(3)
                
                if (sender.location(in: self.view).x < timelineScrollView.frame.origin.x + CGFloat(scrollBuffer)) {
                    timelineScrollView.contentOffset.x -= scrollSpeed
                    if (timelineScrollView.contentOffset.x < 0) {
                        timelineScrollView.contentOffset.x = 0
                    }
                } else if (sender.location(in: self.view).x > timelineScrollView.frame.width - CGFloat(scrollBuffer)) {
                    timelineScrollView.contentOffset.x += scrollSpeed
                    if (timelineScrollView.contentOffset.x > timelineScrollView.contentSize.width - timelineScrollView.frame.width) {
                        timelineScrollView.contentOffset.x = timelineScrollView.contentSize.width - timelineScrollView.frame.width
                    }
                }
            }
        }
    }
    
    func didPressCameraButton(_ button: UIButton) {
        selectedTimelineBlockIndex = nil
    }
}
