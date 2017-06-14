import UIKit

extension UIImage {
    func getImageWithMask(maskImage: UIImage, maskFrame: CGRect, maskAlpha: CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(self.size)
        
        self.draw(in: CGRect(
            x: 0,
            y: 0,
            width: self.size.width,
            height: self.size.height
        ))
        
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -self.size.height)
        
        maskImage.draw(
            in: maskFrame.applying(transform),
            blendMode: .normal,
            alpha: maskAlpha
        )
        
        let imageWithMask: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if (imageWithMask != nil) {
            return imageWithMask!
        } else {
            logger.message(type: .error, message: "Could not get image with mask from graphics context.")
            return self
        }
    }
}
