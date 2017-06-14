import UIKit
import Alamofire
import SwiftyJSON

func uploadSlice(_ sliceComposite: SliceComposite, parentID: Int?, conversationID: Int?, completion:@escaping (_ success: Bool, _ errorMessage: String?) -> Void){
    
    if (sliceComposite.blocks.isEmpty) {
        completion(false, "Could not upload Slice with no media.")
        return
    }
    
    if (sliceComposite.title.characters.count < Slice.minTitleLength || sliceComposite.title.characters.count > Slice.maxTitleLength) {
        completion(false, "Could not upload because Slice has an invalid title.")
        return
    }
    
    if (currentUser == nil){
        completion(false, "Nil user found when attempting to upload Slice.")
        return
    }
    
    if (sliceComposite.sliceID == nil) {
        currentUser!.postSlice(
            title: sliceComposite.title,
            parentID: parentID,
            completion: {(success, errorMessage, sliceID) -> Void in
                if (success == false) {
                    logger.message(type: .error, message: "Failed to post Slice during Slice upload.")
                    completion(success, errorMessage)
                } else if (success == true && sliceID == nil) {
                    logger.message(type: .error, message: "Server returned nil Slice ID on upload attempt.")
                    completion(success, "Server returned nil Slice ID on upload attempt.")
                } else {
                    sliceComposite.sliceID = sliceID
                    uploadAllSliceMedia(sliceComposite: sliceComposite, completion: {(success, errorMessage) -> Void in
                        completion(success, errorMessage)
                    })
                }
            }
        )
    } else {
        
    }
}

func uploadAllSliceMedia(sliceComposite: SliceComposite, completion:@escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
    if (sliceComposite.sliceID == nil) {
        logger.message(type: .error, message: "Attempted to upload Slice media, but Slice ID was nil.")
        completion(false, "Slice ID was nil for Slice Media.")
        return
    }
    
    logger.message(type: .information, message: "Starting upload of all media for slice: \(sliceComposite.sliceID!).")
    
    for (index, media) in sliceComposite.blocks.enumerated() {
        if (media.isMediaUploaded() == false) {
            uploadMedia(media.sliceMedia.getImageWithEffects(), sliceID: sliceComposite.sliceID, completion: {(success, errorMessage) -> Void in
                if (success == false) {
                    logger.message(type: .error, message: "Failed to upload media with params at index \(index) for slice ID: \(sliceComposite.sliceID!) and error: \(errorMessage).")
                    completion(false, "Failed to upload all media.")
                }
                
                if (success == true) {
                    media.mediaUploadedSuccessfully = true
                    
                    let remainingMedia = sliceComposite.getCountOfMediaNotUploaded()
                    
                    if (remainingMedia == 0) {
                        logger.message(type: .information, message: "All media uploaded successfull for slice ID: \(sliceComposite.sliceID!)")
                        completion(true, nil)
                    } else {
                        logger.message(
                            type: .information,
                            message: "Media \(index) uploaded successfully, \(remainingMedia) media remaining for slice ID: \(sliceComposite.sliceID!)"
                        )
                    }
                }
            })
        } else if (sliceComposite.getCountOfMediaNotUploaded() == 0) {
            logger.message(type: .information, message: "All media uploaded successfull for slice ID: \(sliceComposite.sliceID!)")
            completion(true, nil)
        }
    }
}

func uploadMedia(_ image: UIImage, sliceID: Int?, completion:@escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
    var squareImage: UIImage = image.cropImageToSquare()
    
    if let resizedImage = squareImage.resizeImage(toTargetSize: Slice.sliceMediaSize) {
        squareImage = resizedImage
    }
    
    let mediaData: Data = UIImagePNGRepresentation(squareImage)!
    
    let url = ApiHelper.BASE_URL + "/upload_media"
    
    let type = (sliceID == nil) ? "photo_user" : "photo_slice"
    
    var params: [String : String] = ["type": type]
    
    if (sliceID != nil) {
        params["slice_id"] = String(sliceID!)
    }
    
    logger.message(type: .information, message: "Starting upload of \(type)\((sliceID == nil) ? "" : " for slice \(sliceID!)").)")
 
    Alamofire.upload(
        multipartFormData: { multiPartFormData in
            for (key, value) in params {
                multiPartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            
            multiPartFormData.append(mediaData, withName: "media", fileName: type + ".png", mimeType: "image/png")
        },
        to: url,
        method: .post,
        headers: apiHelper.authTokenHeader(),
        encodingCompletion: { encodingResult in
            switch encodingResult {
            case.success(let upload, _, _):
                upload.responseJSON { response in
                    logger.message(type: .information, message: "Completed upload of \(type)\((sliceID == nil) ? "" : " for slice \(sliceID!)").)")
                    completion(true, nil)
                }
            case .failure(let encodingError):
                logger.message(type: .error, message: "Could not upload \(type)\((sliceID == nil) ? "" : " for slice \(sliceID!)").)")
                completion(false, encodingError.localizedDescription)
            }
        }
    )

}


