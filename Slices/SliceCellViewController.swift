import UIKit

class SliceCellViewController: UITableViewCell, SliceTimelineDelegate {
    
    @IBOutlet weak var sliceMediaView: SliceMediaView!
    @IBOutlet weak var userMediaView: UserMediaView!
    @IBOutlet weak var toppingsView: UIView!
    @IBOutlet weak var sliceInfoView: UIView!
    @IBOutlet weak var btnUsername: UIButton!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var timelineView: UIView!

    weak var navController: UINavigationController?
    var toppingsCollectionView: ToppingsCollectionView?
    var sliceTimeline: SliceTimelineView?
    
    var slice: Slice? {
        didSet {
            if (slice != nil) {
                loadSlice()
            }
        }
    }
    
    @IBAction func didPressUsername(_ sender: UIButton) {
        // TODO: Segue to user view.
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        slice = nil
        sliceMediaView.slice = nil
        sliceTimeline?.slice = nil
        userMediaView.user = nil
    }
    
//    func showSliceInfo(show: Bool) {
//        if (show == true) {
//            sliceInfoView.isHidden = false
//            sliceInfoView.fadeIn(duration: 1.0)
//        }
//        else {
//            sliceInfoView.fadeOut(duration: 1.0, completion: {(success) -> Void in
//                self.sliceInfoView.isHidden = true
//            })
//        }
//    }
    
    func loadSlice() {
        setupSliceTimeline()
        
        if (slice != nil) {
            logger.message(type: .debug, message: "Loaded Slice \(slice!.sliceID!) into cell.")
            
            btnUsername.setTitle(slice!.user.username, for: .normal)
            lblLocation.text = slice!.locationString
            lblDescription.text = slice!.title
            lblDescription.sizeToFit()
            
            userMediaView.user = slice!.user
            sliceMediaView.slice = slice
            sliceTimeline?.slice = slice
            
            if (navController != nil) {
                sliceMediaView.setupGestureRecognizers(navigationController: navController!, canReactToSlice: true, canMoveToSingleSliceView: true)
            } else {
                logger.message(type: .error, message: "Could not setup gestures on Slice Media View from Slice Cell because of nil navigation controller")
            }
            
//            showSliceInfo(show: false)
            loadToppings()
        } else {
            logger.message(type: .error, message: "Tried to load Slice on Slice Cell view, but Slice was nil.")
        }
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
    
    private func loadToppings() {
//        resizeViews()
        if (slice != nil) {
            if (slice!.toppingsCount > 0) {
                loadToppingsCollectionView()
                
                return
            }
        }
    }
    
    private func loadToppingsCollectionView() {
        logger.message(type: .information, message: "Showing Toppings Collection View...")
        if (toppingsCollectionView == nil) {
            toppingsCollectionView = ToppingsCollectionView()
            self.addSubview(toppingsCollectionView!)
        }
        toppingsCollectionView?.frame = toppingsView.frame
        toppingsCollectionView?.bounds = toppingsView.bounds
        toppingsCollectionView?.slice = slice
        toppingsCollectionView?.isHidden = false
        toppingsCollectionView?.isUserInteractionEnabled = true
    }
    
//    private func resizeViews() {
//        let viewWidth = self.frame.width
//        
//        if (slice!.toppingsCount > 0) {
//            toppingsView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: Slice.toppingsDisplayHeight)
//        } else {
//            toppingsView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: 0)
//        }
//        toppingsView.bounds = toppingsView.frame
//        
//        sliceMediaView.frame = CGRect(x: 0, y: toppingsView.frame.height, width: viewWidth, height: viewWidth)
//        sliceMediaView.bounds = sliceMediaView.frame
//        self.frame = CGRect(x:0,
//                            y: self.frame.origin.y,
//                            width: viewWidth,
//                            height: toppingsView.frame.height + sliceMediaView.frame.height)
//        self.bounds = self.frame
//        sliceInfoView.frame = CGRect(x: 0, 
//                                     y: self.frame.height - sliceInfoView.frame.height,
//                                     width: sliceInfoView.frame.width,
//                                     height: sliceInfoView.frame.height)
//        sliceInfoView.bounds = sliceInfoView.frame
//    }
    
    func displayMediaFromTimelineBlock(image: UIImage) {
        sliceMediaView.image = image
    }
}
