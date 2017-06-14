import UIKit

class CameraParentSliceView: NibLoadingView, SliceTimelineDelegate {
    @IBOutlet weak var sliceMediaView: SliceMediaView!
    @IBOutlet weak var btnUsername: UIButton!
    @IBOutlet weak var userMediaView: UserMediaView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var timelineView: UIView!
    
    var sliceTimeline: SliceTimelineView?

    var slice: Slice? {
        didSet {
            loadContent()
        }
    }
    
    private func loadContent() {
        logger.message(type: .information, message: "Loading content into Camera Parent Slice View.")
        setupSliceTimeline()
        
        if (slice != nil && btnUsername != nil && lblDescription != nil) {
            btnUsername.setTitle(slice!.user.username, for: UIControlState.normal)
            lblDescription.text = slice!.title
        }
        
        if (slice != nil && userMediaView != nil) {
            userMediaView.user = slice!.user
        }
        
        if (slice != nil && sliceMediaView != nil && sliceTimeline != nil) {
            logger.message(type: .information, message: "Setup in Single Slice View completed, displaying Slice.")
            
            sliceMediaView!.slice = slice!
            sliceTimeline!.slice = slice!
        }
    }
    
    
    private func setupSliceTimeline() {
        if (sliceTimeline == nil && timelineView != nil) {
            sliceTimeline = SliceTimelineView()
            timelineView.addSubview(sliceTimeline!)
            sliceTimeline?.frame.origin = CGPoint.zero
            sliceTimeline?.frame.size = timelineView.frame.size
            sliceTimeline?.delegate = self
        }
    }
    
    func displayMediaFromTimelineBlock(image: UIImage) {
        sliceMediaView.image = image
    }
}
