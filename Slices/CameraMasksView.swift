import UIKit

protocol CameraMasksDelegate {
    func didChangeMask(maskName: String?)
}

class CameraMasksView: NibLoadingView {
    let maskViewPadding: Int = 2
    
    var delegate: CameraMasksDelegate?
    
    @IBOutlet weak var availableMasksScrollView: UIScrollView!
    @IBOutlet weak var selectedMaskImageView: UIImageView!
    @IBOutlet weak var faceDetectedImageView: UIImageView!
    
    let faceFoundImage = UIImage(named: "Checkmark")
    let faceNotFoundImage = UIImage(named: "X")
    
    var sliceMedia: SliceMedia? {
        didSet {
            selectedMaskName = sliceMedia?.maskName
            detectFaces()
        }
    }
    
    var selectedMaskName: String? {
        didSet {
            selectedMaskImageView.image = MaskManager.getIconForMask(named: selectedMaskName)
        }
    }

    func setup() {
        layoutAvailableMasks()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didPressSelectedMask(_:)))
        selectedMaskImageView.addGestureRecognizer(gestureRecognizer)
        selectedMaskImageView.isUserInteractionEnabled = true
        selectedMaskImageView.addBorder(size: .small, color: .white, radius: CGFloat(selectedMaskImageView.frame.width / 2))
        faceDetectedImageView.addBorder(size: .small, color: .white, radius: CGFloat(faceDetectedImageView.frame.width / 2))
    }
    
    private func layoutAvailableMasks() {
        var index: Int = 0
        
        for mask in MaskManager.maskList {
            print("\(mask.name)")
            addAvailableMaskToScrollView(
                index: index,
                mask: mask
            )
            
            index += 1
        }
        
        availableMasksScrollView.contentSize = CGSize(
            width: CGFloat(getPositionForMaskView(index: index) + (2 * maskViewPadding)),
            height: availableMasksScrollView.frame.height
        )
        
        availableMasksScrollView.isScrollEnabled = availableMasksScrollView.contentSize.width > availableMasksScrollView.frame.width
        availableMasksScrollView.isUserInteractionEnabled = true
    }
    
    private func addAvailableMaskToScrollView(index: Int, mask: SliceMask) {
        let position = getPositionForMaskView(index: index)
        let button: UIButton = UIButton(type: .custom)
        
        button.tag = SliceTimelineBlock.size
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.cornerRadius = CGFloat(getMaskViewSize() / 2)
        button.clipsToBounds = true
        button.setImage(mask.icon, for: .normal)
        button.accessibilityLabel = mask.name
        button.addBorder(size: .small, color: .white, radius: CGFloat(getMaskViewSize() / 2))
        
        button.addTarget(self, action: #selector(didPressAvailableMask(_:)), for: .touchUpInside)
        
        availableMasksScrollView.addSubview(button)
        
        button.frame = CGRect(
            x: position,
            y: maskViewPadding,
            width: getMaskViewSize(),
            height: getMaskViewSize()
        )
    }
    
    func didPressAvailableMask(_ button: UIButton) {
        selectedMaskName = button.accessibilityLabel
        delegate?.didChangeMask(maskName: selectedMaskName)
    }
    
    func didPressSelectedMask(_ sender: UITapGestureRecognizer) {
        selectedMaskName = nil
        delegate?.didChangeMask(maskName: selectedMaskName)
    }
    
    private func detectFaces() {
        if (sliceMedia?.image != nil) {
            if (sliceMedia!.image!.doesImageHaveFaces()) {
                faceFound()
                
                return
            }
        } else {
            logger.message(type: .debug, message: "Slice media did not have image for face detection.")
        }
        
        faceNotFound()
    }
    
    private func faceFound() {
        faceDetectedImageView.image = faceFoundImage
    }
    
    private func faceNotFound() {
        faceDetectedImageView.image = faceNotFoundImage
    }
    
    private func getPositionForMaskView(index: Int) -> Int {
        return (index * getMaskViewSize()) + (index * maskViewPadding)
    }
    
    private func getMaskViewSize() -> Int {
        return (
            Int(floor(availableMasksScrollView.frame.height)) -
                (2 * maskViewPadding)
        )
    }
}
