import UIKit.UIImage

extension UIImage {
    func getFilteredImage(filterList: [String]) -> UIImage {
        if let openGLContext = EAGLContext(api: .openGLES3) {
            let context = CIContext(eaglContext: openGLContext)
            
            guard let downScaledImage: UIImage = self.resizeImage(toTargetSize: Slice.sliceMediaSize) else {
                return self
            }
            
            if let img: CIImage = CIImage(image: downScaledImage) {
                var coreImage: CIImage = img
                
                for filterKey in filterList {
                    if let filter = FilterManager.filterList[filterKey] {
                        coreImage = filter.getFilteredOutput(coreImage: coreImage)
                    } else {
                        logger.message(type: .error, message: "Could not find filter named: \(filterKey).")
                    }
                }
                
                if let filteredOutput = context.createCGImage(coreImage, from: coreImage.extent) {
                    return UIImage(cgImage: filteredOutput)
                } else {
                    logger.message(type: .error, message: "Could not create CGImage from filter chain.")
                    return self
                }
            }
            
            logger.message(type: .error, message: "Could not create core image to apply filters.")
            return self
        } else {
            logger.message(type: .error, message: "Could not get OpenGL context to apply filters.")
            return self
        }
    }
}
