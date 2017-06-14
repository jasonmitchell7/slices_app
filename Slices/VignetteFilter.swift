import UIKit

class VignetteFilter: SliceFilter {
    func getFilteredOutput(coreImage: CIImage) -> CIImage {
        let vignetteFilter = CIFilter(name: "CIVignette")
        vignetteFilter?.setValue(coreImage, forKey: kCIInputImageKey)
        vignetteFilter?.setValue(20, forKey: kCIInputRadiusKey)
        vignetteFilter?.setValue(0.3, forKey: kCIInputIntensityKey)
        
        if let filteredOutput = vignetteFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
            return filteredOutput
        }
        
        logger.message(
            type: .error,
            message: "Error applying filter: \(String(describing: type(of: self)))"
        )
        
        return coreImage
    }
}
