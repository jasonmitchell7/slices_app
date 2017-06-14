import UIKit

class SliceComposite {
    var blocks: [SliceTimelineBlock] = [SliceTimelineBlock]()
    var title: String = ""
    var sliceID: Int?
    
    func reset() {
        blocks.removeAll()
        title = ""
    }
    
    func initFromSlice(slice: Slice) {
        reset()
        
        sliceID = slice.sliceID
        
        for media in slice.mediaList {
            addBlock(withMedia: media)
        }
    }
    
    func addBlock(withImage: UIImage) {
        blocks.append(SliceTimelineBlock(image: withImage))
        blocks.last?.sliceMedia.seq = blocks.count - 1
    }
    
    func addBlock(withMedia: SliceMedia) {
        blocks.append(SliceTimelineBlock(media: withMedia))
    }
    
    func deleteBlock(index: Int) {
        if (index < 0 || index >= blocks.count) {
            logger.message(type: .error, message: "Slice composite attempted to delete block with out of range index.")
            return
        }
        
        blocks.remove(at: index)
        
        if (index < blocks.count) {
            for seqUpdateIndex in index..<blocks.count {
                if (blocks[seqUpdateIndex].sliceMedia.seq > 0) {
                    blocks[seqUpdateIndex].sliceMedia.seq -= 1
                }
            }
        }
    }
    
    func swapBlocksAt(indexA: Int, indexB: Int) {
        if (indexA >= 0 && indexA < blocks.count && indexB >= 0 && indexB < blocks.count) {
            let storedMedia = blocks[indexA].sliceMedia
            blocks[indexA].sliceMedia = blocks[indexB].sliceMedia
            blocks[indexB].sliceMedia = storedMedia
            
            let storedSeq = blocks[indexA].sliceMedia.seq
            blocks[indexA].sliceMedia.seq = blocks[indexB].sliceMedia.seq
            blocks[indexB].sliceMedia.seq = storedSeq
        } else {
            logger.message(type: .error, message: "Index out of range while attempting to swap blocks in SliceComposite.")
        }
    }
    
    func getLoadedMediaBlockCount() -> Int{
        var count = 0
        
        for block in blocks {
            if (block.isMediaLoaded() == true) {
                count += 1
            }
        }
        
        return count
    }
    
    func getCountOfMediaNotUploaded() -> Int {
        var count = 0
        
        for block in blocks {
            if (block.isMediaUploaded() == false) {
                count += 1
            }
        }
        
        return count
    }
    
    func getNextUnloadedMediaBlockIndex() -> Int? {
        for (index, block) in blocks.enumerated() {
            if (block.isMediaLoaded() == false) {
                return index
            }
        }
        
        return nil
    }
    
    func isAllMediaLoaded() -> Bool {
        return (getLoadedMediaBlockCount() == blocks.count)
    }
    
    func loadNextMedia(completion: @escaping (_ success: Bool, _ isAllMediaLoaded: Bool, _ blockIndex: Int?) -> Void) {
        if let blockIndex = getNextUnloadedMediaBlockIndex() {
            if (blocks[blockIndex].sliceMedia.url != nil) {
                blocks[blockIndex].sliceMedia.requestMediaContent(completion: {(success, errorMessage) -> Void in
                    if (success == true) {
                        if (blockIndex == (self.blocks.count - 1)) {
                            completion(true, true, blockIndex)
                        } else {
                            completion(true, false, blockIndex)
                        }
                    } else {
                        logger.message(
                            type: .error,
                            message: "Could not load media in Slice Composite for index \(blockIndex) and url \(self.blocks[blockIndex].sliceMedia.url)."
                        )
                        completion(false, true, nil)
                    }
                })
            }
        } else {
            logger.message(type: .error, message: "Attempted to load media in Slice Composite, but there were no blocks without loaded media.")
            completion(false, true, nil)
        }
    }
}
