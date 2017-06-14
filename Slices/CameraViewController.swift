import UIKit
import AVFoundation

class CameraViewController: SlicesViewControllerWithNav, LongTextEntryDelegate, SlicesThreeButtonAlertDelegate {
    @IBOutlet weak var imgMain: UIImageView!
    @IBOutlet weak var viewPreview: UIView!
    @IBOutlet weak var lblInstructions: UILabel!
    @IBOutlet weak var timelineView: UIView!
    @IBOutlet weak var optionsView: UIView!
    
    
    @IBOutlet weak var stackViewBG: UIView!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var trashButton: UIButton!
    @IBOutlet weak var parentSliceButton: UIButton!
    @IBOutlet weak var filtersButton: UIButton!
    @IBOutlet weak var masksButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    
    var parentSlice: Slice? {
        didSet {
            parentSliceView.slice = parentSlice
            parentSliceButton.isEnabled = (parentSlice != nil)
        }
    }
    
    // MARK: Stored properties for CaptureSession extension.
    var photoOutput = AVCapturePhotoOutput()
    var captureDevice: AVCaptureDevice?
    var audioDevice: AVCaptureDevice?
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var videoOutput: AVCaptureMovieFileOutput?
    var tempVideoURL: URL?
    var currentInput: AVCaptureDeviceInput?
    
    var currentCameraPosition = AVCaptureDevicePosition.front
    var currentFlashMode = AVCaptureFlashMode.off
    
    // MARK: Stored properties for ActivityIndicator extension.
    var actInd = ActivityIndicatorWithText(text: "")
    
    // MARK: Stored properties for Keyboard extension.
    var startingViewFrame: CGRect!
    let tabBarHeight = CGFloat(49) // Make this not hard coded later.
    
    // MARK: Stored properties for Upload extension.
    var enterTitleModal: LongTextEntryView?
    
    // MARK: Stored properties for SliceTimeline.
    var sliceTimeline: SliceTimelineView?
    
    // MARK: Stored Properties for the SlicesThreeButtonAlertModal
    var slicesThreeButtonAlertModal: SlicesThreeButtonAlertView?
    
    // MARK: Stored subviews.
    var filtersView = CameraFiltersView()
    var parentSliceView = CameraParentSliceView()
    var maskView = CameraMasksView()
    
    // MARK: Functions.
    override func viewDidLoad() {
        super.viewDidLoad()

        imgMain.contentMode = UIViewContentMode.scaleAspectFill
        imgMain.clipsToBounds = true
        
        stackViewBG.addBorderForTimeline()
        
        hideCapturedMedia(hide: true)
        registerGestureRecognizers()
        addKeyboardObservers()
        
        maskView.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        startingViewFrame = self.view.frame
        
        setupSliceTimeline()
        
        showCameraView()
        
        hideAllOptionsViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    func showCameraView() {
        grabCam()
        startCaptureSession()
        showInstructions(text: "Tap = Photo \n Hold = Video", completion: {(success) -> Void in
            self.showInstructions(text: "Swipe to the side to \n change the camera!")
        })
    }
    
    
    func hideCapturedMedia(hide: Bool) {
        logger.message(type: .information, message: "Hide captured media: \(hide)")
        
        imgMain.isHidden = hide
        imgMain.isUserInteractionEnabled = !hide
        viewPreview.isHidden = !hide
        viewPreview.isUserInteractionEnabled = hide
        
        saveButton.isHidden = hide
        saveButton.isUserInteractionEnabled = !hide
        
        trashButton.isHidden = hide
        trashButton.isUserInteractionEnabled = !hide
        
        filtersButton.isEnabled = !hide
        masksButton.isEnabled = !hide
        parentSliceButton.isEnabled = (parentSlice != nil)
        
        if (hide == true) {
            hideAllOptionsViews()
        }
    }

    
    func showInstructions(text: String, completion: ((Bool) -> Void)? = nil) {
        if helpMgr.shouldShowHelp(forSetting: .camera) {
            lblInstructions.text = text
            lblInstructions.fadeInAndOut(duration: 3, completion: completion)
        }
    }
    
    @IBAction func didPressSave(_ sender: UIButton) {
        if let image = imgMain.image {
            saveImage(image: image)
        }
    }
    
    @IBAction func didPressTrash(_ sender: UIButton) {
        if (slicesThreeButtonAlertModal != nil) {
            logger.message(type: .error, message: "Already displaying a three button modal from the camera.")
        }
        
        slicesThreeButtonAlertModal = SlicesThreeButtonAlertView()
        slicesThreeButtonAlertModal?.setup(
            title: "Really?!?",
            description: "Are you sure you wish to delete your captured media? It will be lost forever. :'(",
            cancelText: "Cancel",
            firstButtonText: "Delete Selected",
            secondButtonText: "Delete All",
            fullFrame: self.view.frame,
            blurBackground: true
        )
        slicesThreeButtonAlertModal?.delegate = self
        
        UIApplication.shared.keyWindow?.addSubview(slicesThreeButtonAlertModal!)
    }
    
    func threeButtonAlertCancelSelected() {
        slicesThreeButtonAlertModal = nil
    }
    
    func threeButtonAlertFirstButtonSelected() {
        sliceTimeline?.deleteSelectedTimelineBlock()
        
        slicesThreeButtonAlertModal = nil
    }
    
    func threeButtonAlertSecondButtonSelected() {
        sliceTimeline?.createEmptyTimelineForEditing()
        
        slicesThreeButtonAlertModal = nil
    }
    
    @IBAction func didPressParentSlice(_ sender: UIButton) {
        showParentSliceOptions()
    }
    
    @IBAction func didPressFilters(_ sender: UIButton) {
        showFilterOptions()
    }
    
    @IBAction func didPressMasks(_ sender: UIButton) {
        showMaskOptions()
    }
    
    @IBAction func didPressText(_ sender: UIButton) {
    }
    
    @IBAction func didPressUpload(_ sender: UIButton) {
        startUploadOfCurrentMedia()
    }
    
    func getSliceOrToppingString() -> String {
        return parentSlice == nil ? "Slice" : "Topping"
    }
}
