import UIKit

class DarkenFilter: SliceFilter {
    func getFilteredOutput(coreImage: CIImage) -> CIImage {
        let darkenFilter = CIFilter(name: "CIExposureAdjust")
        darkenFilter?.setValue(coreImage, forKey: kCIInputImageKey)
        darkenFilter?.setValue(-1.0, forKey: kCIInputEVKey)
        
        if let filteredOutput = darkenFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
            return filteredOutput
        }
        
        logger.message(
            type: .error,
            message: "Error applying filter: \(String(describing: type(of: self)))"
        )
        
        return coreImage
    }
}
