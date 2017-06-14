import UIKit.UIImage

class SliceMask {
    static let tagValue: Int = 72
    
   enum Position {
        case face
        case hat
        case forehead
        case eyes
        case leftEye
        case rightEye
        case nose
        case moustache
        case mouth
        case chin
    }
    
    struct MaskPiece {
        var position: Position
        var image: UIImage
        var alpha: CGFloat
        
        init(position: Position, image: UIImage, alpha: CGFloat) {
            self.position = position
            self.image = image
            self.alpha = alpha
        }
    }

    var icon: UIImage
    var name: String
    var pieces: [MaskPiece]
    
    init(name: String, icon: UIImage, pieces: [MaskPiece]) {
        self.name = name
        self.icon = icon
        self.pieces = pieces
    }
}
