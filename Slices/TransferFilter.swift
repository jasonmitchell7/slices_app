import UIKit

class TransferFilter: SliceFilter {
    func getFilteredOutput(coreImage: CIImage) -> CIImage {
        let transferFilter = CIFilter(name: "CIPhotoEffectTransfer")
        transferFilter?.setValue(coreImage, forKey: kCIInputImageKey)
        
        if let filteredOutput = transferFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
            return filteredOutput
        }
        
        logger.message(
            type: .error,
            message: "Error applying filter: \(String(describing: type(of: self)))"
        )
        
        return coreImage
    }
}
