import UIKit
import AVFoundation

@IBDesignable class SliceMediaView: UIImageView {
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var playOnLoad: Bool = false
    
    private var navController: UINavigationController?
    private var doubleTapGestureRecognizer: UITapGestureRecognizer?
    
//    var slice: Slice? {
//        didSet{
//            loadSlice()
//        }
//    }
    var slice: Slice?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentMode = .center
        self.backgroundColor = styleMgr.colorLight
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
        self.backgroundColor = styleMgr.colorLight
    }
    
    private func loadSlice() {
//        if (slice != nil) {
//            showActivityIndicator(show: true)
//        
//            slice!.mediaList[0].requestMediaContent(completion: {(success, errorMessage) -> Void in
//                if (self.slice!.isVideo == true) {
//                    if let url = self.slice!.videoURL {
//                        self.createAVPlayer(url: url)
//                    }
//                    else {
//                        logger.message(type: .error, message: "Video Slice had null URL.")
//                    }
//                
//                    self.showActivityIndicator(show: false)
//                }
//                else {
//                    self.image = self.slice!.mediaList[0].image
//                    self.showActivityIndicator(show: false)
//                }
//            })
//        }
//        else {
//            image = nil
//            cleanupPlayer()
//        }
        
    }
    
    public func setupGestureRecognizers(navigationController: UINavigationController, canReactToSlice: Bool, canMoveToSingleSliceView: Bool) {
        navController = navigationController
        
        if (canReactToSlice == true) {
            setupReactionGesture()
        }
        
        if (canMoveToSingleSliceView == true) {
            setupViewSingleSliceGesture()
        }
        
        self.isUserInteractionEnabled = true
    }
    
    private func setupReactionGesture() {
        logger.message(type: .information, message: "Added Reaction Gesture to Slice Media View.")
        doubleTapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                action: #selector(reactToSlice(gestureRecognizer:)))
        doubleTapGestureRecognizer!.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTapGestureRecognizer!)
    }
    
    private func setupViewSingleSliceGesture() {
        logger.message(type: .information, message: "Added View Single Slice Gesture to Slice Media View.")
        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                          action: #selector(moveToSingleSlice(gestureRecognizer:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        
        if (doubleTapGestureRecognizer != nil) {
            tapGestureRecognizer.require(toFail: doubleTapGestureRecognizer!)
        }
    
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func reactToSlice(gestureRecognizer: UITapGestureRecognizer) {
        logger.message(type: .information, message: "Reacting to Slice.")
        if (navController != nil) {
            if (slice != nil) {
                let cameraViewController = CameraViewController(nibName: "CameraView", bundle: nil)
                cameraViewController.parentSlice = slice
                navController?.pushViewController(cameraViewController, animated: true)
            } else {
                logger.message(type: .error, message: "Could not load camera from Single Slice View because Slice was nil.")
            }
            
        } else {
            logger.message(type: .error, message: "Could not load camera from Single Slice View because navigation controller was nil.")
        }
    }
    
    func moveToSingleSlice(gestureRecognizer: UITapGestureRecognizer) {
        logger.message(type: .information, message: "Moving to Single Slice View.")
        if (navController != nil && slice != nil) {
            let singleSliceViewController = SingleSliceViewController(nibName: "SingleSliceView", bundle: nil)
            navController!.pushViewController(viewController: singleSliceViewController, animated: true, completion: {() -> Void in
                singleSliceViewController.slice = self.slice!
            })
        } else {
            logger.message(type: .error, message: "Could not push to Single Slice View with navigation controler: \(navController == nil ? "NIL" : "NOT NIL") and \(slice == nil ? "NIL" : "NOT NIL").")
        }
    }
    
    func cleanupPlayer() {
        playOnLoad = false
        
        if (playerLayer != nil) {
            playerLayer!.removeFromSuperlayer()
            playerLayer = nil
        }
        
        if (player != nil) {
            player = nil
        }
    }
    
    func showActivityIndicator(show: Bool) {
        if (show == true) {
            self.addSubview(activityIndicator)
            activityIndicator.frame = CGRect(x: self.frame.origin.x + (self.frame.width / 2) - (activityIndicator.frame.width / 2),
                                             y: self.frame.origin.y + (self.frame.height / 2) - (activityIndicator.frame.height / 2),
                                             width: activityIndicator.frame.width,
                                             height: activityIndicator.frame.height)
            activityIndicator.bounds = activityIndicator.frame
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        }
        else {
            activityIndicator.removeFromSuperview()
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        }
    }
    
    func createAVPlayer(url: URL) {
        if (player == nil) {
            logger.message(type: .debug, message: "Creating AVPlayer for Slice: \(slice!.sliceID)")
            player = AVPlayer(url: url)
            
            playerLayer = AVPlayerLayer(player: player)
            playerLayer!.frame = self.bounds
            playerLayer!.videoGravity = AVLayerVideoGravityResizeAspect
            self.layer.addSublayer(playerLayer!)
            
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(replayVideo),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                   object: nil)
        }
        else {
            logger.message(type: .debug, message: "Playing Slice: \(slice!.sliceID)")
            player!.replaceCurrentItem(with: AVPlayerItem(url: url))
        }
        
        if (playOnLoad == true) {
            play()
        }
    }
    
    func replayVideo(notification: NSNotification) {
        if (player != nil) {
            let seconds: Int64 = 0
            let preferredTimeScale: Int32 = 1
            let seekTime: CMTime = CMTimeMake(seconds, preferredTimeScale)
            
            player!.seek(to: seekTime)
            play()
        }
    }
    
    func play() {
        playOnLoad = true
        player?.play()
    }
    
    func pause() {
        playOnLoad = false
        player?.pause()
    }
}
