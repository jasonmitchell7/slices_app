import UIKit

class ProcessFilter: SliceFilter {
    func getFilteredOutput(coreImage: CIImage) -> CIImage {
        let processFilter = CIFilter(name: "CIPhotoEffectProcess")
        processFilter?.setValue(coreImage, forKey: kCIInputImageKey)
        
        if let filteredOutput = processFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
            return filteredOutput
        }
        
        logger.message(
            type: .error,
            message: "Error applying filter: \(String(describing: type(of: self)))"
        )
        
        return coreImage
    }
}
