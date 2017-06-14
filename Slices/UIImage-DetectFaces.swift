import UIKit

extension UIImage {
    func detectFaces() -> [CIFaceFeature] {
        let faces = [CIFaceFeature]()
        
        guard let coreImage = CIImage(image: self) else {
            logger.message(type: .error, message: "Failed Core Image cast while detecting faces.")
            return faces
        }
        
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(
            ofType: CIDetectorTypeFace,
            context: nil,
            options: accuracy
        )
        
        if let detectedFaces = faceDetector?.features(in: coreImage) as? [CIFaceFeature] {
            return detectedFaces
        }
        
        logger.message(type: .information, message: "Failed to detect faces.")
        return faces
    }
    
    func doesImageHaveFaces() -> Bool {
        return !detectFaces().isEmpty
    }
}

// Debug function.
extension UIImageView {
    func drawBoxesAroundFaces() {        
        self.removeFaceBoxes()
        
        if (self.image == nil) {
            return
        }
        
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -self.image!.size.height)
        
        let scale = min(self.frame.width / self.image!.size.width, self.frame.height / self.image!.size.height)
        let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
        
        let offsetX = (self.frame.width - self.image!.size.width * scale) / 2
        let offsetY = (self.frame.height - self.image!.size.height * scale) / 2
        
        let faces = self.image!.detectFaces()
        
        for face in faces {
            var faceViewBounds = face.bounds.applying(transform).applying(scaleTransform)
            
            faceViewBounds.origin.x += offsetX
            faceViewBounds.origin.y += offsetY
            
            let faceBox = UIView(frame: faceViewBounds)
            
            faceBox.tag = SliceMask.tagValue
            faceBox.layer.borderWidth = 3
            faceBox.layer.borderColor = UIColor.red.cgColor
            faceBox.backgroundColor = UIColor.clear
            self.addSubview(faceBox)
        }
    }
    
    func removeFaceBoxes() {
        for subview in self.subviews {
            if (subview.tag == SliceMask.tagValue) {
                subview.removeFromSuperview()
            }
        }
    }
}
