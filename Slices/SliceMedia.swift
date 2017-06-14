import UIKit
import SwiftyJSON

class SliceMedia {
    var url: String?

    var duration: Int = 2
    var seq: Int = 0
    var type: String?

    var image: UIImage?
    var videoURL: URL?
    
    var filters: [String] = [String]() {
        didSet {
            logger.message(type: .information, message: "Set new filters: \(filters)")
            imageWithEffects = nil
        }
    }
    
    var maskName: String? {
        didSet {
            logger.message(type: .information, message: "Set new mask: \(maskName)")
            imageWithEffects = nil
        }
    }
    
    private var imageWithEffects: UIImage?
    
    func buildFromJSON(_ jsonDict: [String : JSON]){
        url = jsonDict["url"]!.string!
        
        if let jsonDuration = jsonDict["duration"]?.int {
            duration = jsonDuration
        }

        if let jsonSeq = jsonDict["seq"]?.int {
            seq = jsonSeq
        }
        
        type = jsonDict["type"]?.string
    }
    
    func requestMediaContent(completion: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
        if (url == nil) {
            completion(false, "Attempted media request with nil URL.")
            return
        }
        
        logger.message(type: .debug, message: "Requesting media for URL: \(url!)")
        
        requestPhoto(url: url!, completion: { (requestedImage) -> Void in
            if (requestedImage != nil) {
                logger.message(type: .debug, message: "Successfully received media for URL: \(self.url!)")
                self.image = requestedImage!
                completion(true, nil)
            } else {
                completion(false, "Received nil image from media request for ID: \(self.url!)")
            }
            
        })
    }
    
    func getImageWithEffects() -> UIImage {
        if (image == nil) {
            return UIImage(named: "UnknownUser")!
        } else {
            if (imageWithEffects == nil) {
                imageWithEffects = MaskManager.applyMask(to: image!, maskName: maskName).getFilteredImage(filterList: filters)
            }
            
            return imageWithEffects!
        }
    }
}
