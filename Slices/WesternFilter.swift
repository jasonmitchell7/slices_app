import UIKit

class WesternFilter: SliceFilter {
    func getFilteredOutput(coreImage: CIImage) -> CIImage {
        let sepiaFilter = CIFilter(name: "CISepiaTone")
        sepiaFilter?.setValue(coreImage, forKey: kCIInputImageKey)
        sepiaFilter?.setValue(0.2, forKey: kCIInputIntensityKey)
        
        if let sepiaOutput = sepiaFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
            let exposureFilter = CIFilter(name: "CIExposureAdjust")
            exposureFilter?.setValue(sepiaOutput, forKey: kCIInputImageKey)
            exposureFilter?.setValue(0.9, forKey: kCIInputEVKey)
            
            if let filteredOutput = exposureFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
                return filteredOutput
            }
        }
        
        logger.message(
            type: .error,
            message: "Error applying filter: \(String(describing: type(of: self)))"
        )
        
        return coreImage
    }
}
