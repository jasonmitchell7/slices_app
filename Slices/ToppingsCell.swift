import UIKit

class ToppingsCell: UICollectionViewCell, SliceTimelineDelegate {
    
    @IBOutlet weak var sliceMediaView: SliceMediaView!
    @IBOutlet weak var btnUsername: UIButton!
    @IBOutlet weak var userMediaView: UserMediaView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var timelineView: UIView!
    
    public weak var navController: UINavigationController?
    private var sliceTimeline: SliceTimelineView?
    
    var slice: Slice? {
        didSet{
            loadContent()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        loadContent()
    }
    
    func loadContent() {
        setupSliceTimeline()
        
        if (slice != nil) {
            btnUsername.setTitle(slice!.user.username, for: .normal)
            lblDescription.text = slice!.title
            
            if (userMediaView != nil) {
                userMediaView.user = slice!.user
            } else {
                logger.message(type: .debug, message: "Attempted to load user content on Topping Cell before view was created.")
            }
            
            if (sliceMediaView != nil) {
                if (navController != nil) {
                    sliceMediaView.setupGestureRecognizers(navigationController: navController!,
                                                           canReactToSlice: true,
                                                           canMoveToSingleSliceView: true)
                } else {
                    logger.message(type: .debug, message: "Could not add gestures to Slice Media View on Topping cell because of nil navigation controller.")
                }
                
                sliceMediaView.slice = slice
                sliceTimeline?.slice = slice
            } else {
                logger.message(type: .debug, message: "Attempted to load slice content on Topping Cell before view was created.")
            }
        } else {
            logger.message(type: .debug, message: "Attempted to load content on Topping Cell before Slice was set.")
        }
    }
    
    @IBAction func didPressUsername(_ sender: UIButton) {
        // TODO: Segue to user view.
    }
    
    private func setupSliceTimeline() {
        if (sliceTimeline == nil) {
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
