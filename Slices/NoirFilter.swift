import UIKit

class NoirFilter: SliceFilter {
    func getFilteredOutput(coreImage: CIImage) -> CIImage {
        let noirFilter = CIFilter(name: "CIPhotoEffectNoir")
        noirFilter?.setValue(coreImage, forKey: kCIInputImageKey)
        
        if let filteredOutput = noirFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
            return filteredOutput
        }
        
        logger.message(
            type: .error,
            message: "Error applying filter: \(String(describing: type(of: self)))"
        )
        
        return coreImage
    }
}
