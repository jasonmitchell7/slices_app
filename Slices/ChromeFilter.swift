import UIKit

class ChromeFilter: SliceFilter {
    func getFilteredOutput(coreImage: CIImage) -> CIImage {
        let chromeFilter = CIFilter(name: "CIPhotoEffectChrome")
        chromeFilter?.setValue(coreImage, forKey: kCIInputImageKey)
        
        if let filteredOutput = chromeFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
            return filteredOutput
        }
        
        logger.message(
            type: .error,
            message: "Error applying filter: \(String(describing: type(of: self)))"
        )
        
        return coreImage
    }
}
