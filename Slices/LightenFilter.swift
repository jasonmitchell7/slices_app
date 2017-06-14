import UIKit

class LightenFilter: SliceFilter {
    func getFilteredOutput(coreImage: CIImage) -> CIImage {
        let lightenFilter = CIFilter(name: "CIExposureAdjust")
        lightenFilter?.setValue(coreImage, forKey: kCIInputImageKey)
        lightenFilter?.setValue(1.0, forKey: kCIInputEVKey)
        
        if let filteredOutput = lightenFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
            return filteredOutput
        }
        
        logger.message(
            type: .error,
            message: "Error applying filter: \(String(describing: type(of: self)))"
        )
        
        return coreImage
    }
}
