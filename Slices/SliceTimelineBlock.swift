import UIKit

class SliceTimelineBlock {
    static let size: Int = 40
    
    var sliceMedia: SliceMedia!
    var mediaUploadedSuccessfully: Bool = false
    
    init(image: UIImage) {
        self.sliceMedia = SliceMedia()
        self.sliceMedia.image = image
    }
    
    init(media: SliceMedia) {
        self.sliceMedia = media
    }
    
    func isMediaLoaded() -> Bool {
        return (sliceMedia.image != nil || sliceMedia.videoURL != nil)
    }
    
    func isMediaUploaded() -> Bool {
        return (mediaUploadedSuccessfully == true || sliceMedia.url != nil)
    }
}
