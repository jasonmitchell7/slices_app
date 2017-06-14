import UIKit.UIImage

class MaskManager {
    private static let basicMoustache = SliceMask(
        name: "Basic Moustache",
        icon: UIImage(named: "BasicMoustache-Icon")!,
        pieces: [
            SliceMask.MaskPiece(
                position: .moustache,
                image: UIImage(named: "BasicMoustache-Moustache")!,
                alpha: 0.8
            )
        ])
    
    private static let _maskList: [SliceMask] = [
        MaskManager.basicMoustache
    ]
    
    public static let maskList = _maskList.sorted(by: {$0.name < $1.name})
    
    public static func applyMask(to: UIImage, maskName: String?) -> UIImage {
        guard let mask = getMask(named: maskName) else {
            return to
        }
        
        if (to.doesImageHaveFaces() == false) {
            return to
        }
        
        var imageWithMasks = to
        
        let faces = imageWithMasks.detectFaces()
        
        for face in faces {
            for piece in mask.pieces {
                var rotatedImage = piece.image
                
                if (face.hasFaceAngle) {
                    rotatedImage = rotatedImage.rotatedBy(radians: CGFloat(-face.faceAngle) * (CGFloat.pi / 180))
                }
                
                logger.message(type: .information, message: "Drawing mask piece: \(piece.position) for \(mask.name).")
                imageWithMasks = imageWithMasks.getImageWithMask(
                    maskImage: rotatedImage,
                    maskFrame: getPieceRect(maskPiece: piece, face: face),
                    maskAlpha: piece.alpha
                )
            }
        }
        
        return imageWithMasks
    }
    
    public static func getIconForMask(named: String?) -> UIImage? {
        guard let mask = getMask(named: named) else {
            return nil
        }
        
        return mask.icon
    }
    
    private static func getMask(named: String?) -> SliceMask? {
        if (named == nil) {
            return nil
        }
        
        for mask in maskList {
            if (mask.name == named) {
                return mask
            }
        }
        
        return nil
    }
    
    private static func getPieceRect(maskPiece: SliceMask.MaskPiece, face: CIFaceFeature) -> CGRect {
        let eyesY = (face.leftEyePosition.y + face.rightEyePosition.y) / CGFloat(2)
        let noseY = (eyesY + face.mouthPosition.y) / CGFloat(2)
        switch (maskPiece.position) {
        case .face:
            return face.bounds
        case .hat:
            return CGRect(
                x: face.bounds.origin.x,
                y: face.bounds.origin.y + face.bounds.height,
                width: face.bounds.width,
                height: face.bounds.height
            )
        case .forehead:
            return CGRect(
                x: face.bounds.origin.x,
                y: face.bounds.origin.y,
                width: face.bounds.width,
                height: face.bounds.height
            )
        case .eyes:
            return CGRect(
                x: (face.leftEyePosition.x + face.rightEyePosition.x) / CGFloat(2),
                y: eyesY,
                width: face.bounds.width,
                height: face.bounds.height * CGFloat(0.2)
            )
        case .leftEye:
            return CGRect(
                x: face.leftEyePosition.x,
                y: face.leftEyePosition.y,
                width: face.bounds.width * CGFloat(0.4),
                height: face.bounds.height * CGFloat(0.2)
            )
        case .rightEye:
            return CGRect(
                x: face.rightEyePosition.x,
                y: face.rightEyePosition.y,
                width: face.bounds.width * CGFloat(0.4),
                height: face.bounds.height * CGFloat(0.2)
            )
        case .nose:
            return CGRect(
                x: (face.leftEyePosition.x + face.rightEyePosition.x) / CGFloat(2),
                y: noseY,
                width: face.bounds.width * CGFloat(0.2),
                height: face.bounds.height * CGFloat(0.4)
            )
        case .moustache:
            if (face.hasMouthPosition) {
                return CGRect(
                    x: face.mouthPosition.x - ((face.bounds.width * CGFloat(0.4)) / CGFloat(2)),
                    y: face.mouthPosition.y,
                    width: face.bounds.width * CGFloat(0.4),
                    height: face.bounds.height * CGFloat(0.2)
                )
            }
            
            return CGRect(
                x: face.bounds.origin.x + (face.bounds.width * CGFloat(0.3)),
                y: face.bounds.origin.y + (face.bounds.height * CGFloat(0.25)),
                width: face.bounds.width * CGFloat(0.4),
                height: face.bounds.height * CGFloat(0.2)
            )
        case .mouth:
            return CGRect(
                x: face.mouthPosition.x,
                y: face.mouthPosition.y,
                width: face.bounds.width * CGFloat(0.4),
                height: face.bounds.height * CGFloat(0.2)
            )
        case .chin:
            return CGRect(
                x: face.mouthPosition.x,
                y: face.bounds.origin.y - face.bounds.height,
                width: face.bounds.width,
                height: face.bounds.height * CGFloat(0.2)
            )
        }
    }
}
