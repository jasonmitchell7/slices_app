import UIKit.UIImage

protocol SliceFilter {
    func getFilteredOutput(coreImage: CIImage) -> CIImage
}
