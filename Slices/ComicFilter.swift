import UIKit

class ComicFilter: SliceFilter {
    func getFilteredOutput(coreImage: CIImage) -> CIImage {
        let comicFilter = CIFilter(name: "CIComicEffect")
        comicFilter?.setValue(coreImage, forKey: kCIInputImageKey)
        
        if let filteredOutput = comicFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
            return filteredOutput
        }
        
        logger.message(
            type: .error,
            message: "Error applying filter: \(String(describing: type(of: self)))"
        )
        
        return coreImage
    }
}
