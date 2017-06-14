import Photos

var albumMgr: SliceAlbum = SliceAlbum()

class SliceAlbum {
    
    static let albumName = "Slices"

    var assetCollection: PHAssetCollection!
    
    init() {
        getAssetCollection()
    }
    
    func fetchAssetCollectionForAlbum() -> PHAssetCollection! {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title  =%@", SliceAlbum.albumName )
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let firstObject = collection.firstObject as PHAssetCollection!{
            return firstObject
        }
        else {
            return nil
        }
    }
    
    func getAssetCollection() {
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
        
        PHPhotoLibrary.shared().performChanges({PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: SliceAlbum.albumName)
        })
        { success, _ in
            if (success == true) {
                self.assetCollection = self.fetchAssetCollectionForAlbum()
            }
        }
    }
    
    func saveImage(_ image: UIImage, completion: @escaping (_ success: Bool) -> Void) {
        
        if (assetCollection == nil) {
            getAssetCollection()
        }
        
        if (assetCollection == nil) {
            print("Could not capture custom photo album from library.", terminator: "")
            completion(false)
            return
        }
        
        let squareImage = image.cropImageToSquare()
        
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: squareImage)
            let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            let enumeration: NSArray = [assetPlaceholder!]
            albumChangeRequest!.addAssets(enumeration)
        }, completionHandler: { (success, err) -> Void in
            completion(success)
        })
    }
    
    func saveVideo(_ videoURL: URL, completion: @escaping (_ savedURL: URL) -> Void ){
        
        cropVideoToSquare(videoURL, completion:{ (savedURL) -> Void in
            completion(savedURL)
        })

    }
    
    
    func cropVideoToSquare(_ sourceURL: URL, completion: @escaping (_ savedURL: URL) -> Void){
        let videoAsset: AVAsset = AVAsset(url: sourceURL)
        
        let clipVideoTrack = videoAsset.tracks(withMediaType: AVMediaTypeVideo).first!
        
        let composition = AVMutableComposition()
        composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSize(width: clipVideoTrack.naturalSize.height, height: clipVideoTrack.naturalSize.height)
        videoComposition.frameDuration = CMTimeMake(1,60)
        
        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30))

        let transform: CGAffineTransform = clipVideoTrack.preferredTransform.translatedBy(x: (clipVideoTrack.preferredTransform.tx - clipVideoTrack.preferredTransform.ty) / 2, y: 0)
        
        transformer.setTransform(transform, at: kCMTimeZero)
        
        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]
        
        let exporter = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPresetMediumQuality)
        exporter!.videoComposition = videoComposition
        exporter!.outputURL = URL(fileURLWithPath: NSTemporaryDirectory() + "tempSquare" + Date().description + ".mp4")
        exporter!.outputFileType = AVFileTypeQuickTimeMovie
        
        exporter!.exportAsynchronously(completionHandler: { () -> Void in
            DispatchQueue.main.async(execute: {
                self.completeSaveVideo(exporter!, completion:{ (savedURL) -> Void in
                completion(savedURL)
                })
            })
        })
    }
    
    func completeSaveVideo(_ session: AVAssetExportSession, completion: @escaping (_ savedURL: URL) -> Void ) {
        if assetCollection == nil {
            print("Could not capture custom photo album from library.", terminator: "")
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: session.outputURL!)
            let assetPlaceholder = assetChangeRequest!.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            let enumeration: NSArray = [assetPlaceholder!]
            albumChangeRequest!.addAssets(enumeration)
            }, completionHandler:{ success, error in
                completion(session.outputURL!)
        })
    }

}
