import UIKit

class InstantFilter: SliceFilter {
    func getFilteredOutput(coreImage: CIImage) -> CIImage {
        let instantFilter = CIFilter(name: "CIPhotoEffectInstant")
        instantFilter?.setValue(coreImage, forKey: kCIInputImageKey)
        
        if let filteredOutput = instantFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
            return filteredOutput
        }
        
        logger.message(
            type: .error,
            message: "Error applying filter: \(String(describing: type(of: self)))"
        )
        
        return coreImage
    }
}
