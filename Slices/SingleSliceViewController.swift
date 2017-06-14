import UIKit

class SingleSliceViewController: UIViewController, SliceTimelineDelegate {
    
    var slice: Slice? {
        didSet {
            loadContent()
        }
    }
    
    @IBOutlet weak var sliceMediaView: SliceMediaView!
    @IBOutlet weak var btnUsername: UIButton!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var userMediaView: UserMediaView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var toppingsView: UIView!
    @IBOutlet weak var timelineView: UIView!
    
    private var toppingsCollectionView: ToppingsCollectionView?
    private var noToppingsView: UIView?
    private var sliceTimeline: SliceTimelineView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = false
    }
    
    private func loadContent() {
        logger.message(type: .information, message: "Loading content into Single Slice View.")
        setupSliceTimeline()
        
        if (slice != nil && btnUsername != nil && lblLocation != nil && lblDescription != nil) {
            btnUsername.setTitle(slice!.user.username, for: UIControlState.normal)
            lblLocation.text = slice!.locationString
            lblDescription.text = slice!.title
        }
        
        if (slice != nil && userMediaView != nil) {
            userMediaView.user = slice!.user
        }
        
        if (slice != nil && sliceMediaView != nil && sliceTimeline != nil) {
            logger.message(type: .information, message: "Setup in Single Slice View completed, displaying Slice.")
            
            sliceMediaView!.slice = slice!
            sliceTimeline!.slice = slice!
            
            if (navigationController != nil) {
                sliceMediaView.setupGestureRecognizers(navigationController: navigationController!,
                                                       canReactToSlice: true,
                                                       canMoveToSingleSliceView: false)
            } else {
                logger.message(type: .error, message: "Could not setup gestures on Slice Media View from Single Slice View because of nil navigation controller.")
            }
        }
        
        if (slice != nil && toppingsView != nil) {
            loadToppings()
        }
    }
    
    private func loadToppings() {
        if (slice!.toppingsCount > 0) {
            loadToppingsCollecitonView()
                
            return
        }
        
        loadNoToppingsView()
    }
    
    private func loadToppingsCollecitonView() {
        logger.message(type: .information, message: "Showing Toppings Collection View...")
        if (toppingsCollectionView == nil) {
            toppingsCollectionView = ToppingsCollectionView()
            view.addSubview(toppingsCollectionView!)
            toppingsCollectionView?.frame = toppingsView.frame
            toppingsCollectionView?.bounds = toppingsView.bounds
            toppingsCollectionView?.slice = slice
        }
        noToppingsView?.isHidden = true
        toppingsCollectionView?.isHidden = false
        toppingsCollectionView?.isUserInteractionEnabled = true
    }
    
    private func loadNoToppingsView() {
        logger.message(type: .information, message: "Showing No Toppings view...")
        if (noToppingsView == nil) {
            noToppingsView = NoToppingsView()
            view.addSubview(noToppingsView!)
            noToppingsView?.frame = toppingsView.frame
            noToppingsView?.bounds = toppingsView.bounds
        }
        noToppingsView?.isHidden = false
        toppingsCollectionView?.isHidden = true
        toppingsCollectionView?.isUserInteractionEnabled = false
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
