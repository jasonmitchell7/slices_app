import UIKit

class VibranceFilter: SliceFilter {
    func getFilteredOutput(coreImage: CIImage) -> CIImage {
        let vibranceFilter = CIFilter(name: "CIVibrance")
        vibranceFilter?.setValue(coreImage, forKey: kCIInputImageKey)
        
        if let filteredOutput = vibranceFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
            return filteredOutput
        }
        
        logger.message(
            type: .error,
            message: "Error applying filter: \(String(describing: type(of: self)))"
        )
        
        return coreImage
    }
}
