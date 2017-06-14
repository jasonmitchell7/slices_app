import UIKit
import Alamofire
import SwiftyJSON

typealias CompletionHandlerClosureType = () -> Void

var photoCache = [String:UIImage]()
var videoCache = [String:URL]()

func requestPhotoWithID(_ photoID: String!, completion: @escaping (_ requestedPhoto: UIImage?) -> Void){
    
    if photoCache.index(forKey: photoID) != nil{
        completion(photoCache[photoID])

        return
    }
    
    var photo = UIImage(named: "unknownUser")!
    var photoURL: URL!
    
    let url = ApiHelper.BASE_URL + "/get_media_with_id?requested_id=\(photoID!)"
    
    Alamofire.request(url, method: .get, parameters: nil, headers: apiHelper.authTokenHeader()).responseJSON { response in
        switch response.result{
        case .success(let data):
            let json = JSON(data)
            
            let errorMessage = json["message"].string
            
            if (errorMessage != nil)
            {
                print(errorMessage)
                completion(photo)
                return
            }
            
            photoURL = URL(string: json["image_url"].string!)
            
            let request: URLRequest = URLRequest(url: photoURL)

            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
                if (error == nil && data != nil) {
                    let receivedPhoto = UIImage(data: data!)
                    
                    // TODO: Check this to see if it worked...
                    DispatchQueue.main.async {
                        if receivedPhoto != nil{
                            photo = receivedPhoto!
                        
                            photoCache[photoID] = photo
                            
                            completion(photo)
                        }
                        else{
                            completion(photo)
                        }
                    }
                }
                else{
                    if error != nil{
                        print("Error: \(error!.localizedDescription)")
                    }
                    else{
                        print("Error: Received nil data from media request.")
                    }
                    
                    completion(photo)
                }
            })
            
            task.resume()
    
        case .failure(let error):
            print("Request failed with error: \(error)")
        
            completion(photo)
        
        }
    }
}

func requestPhoto(url: String, completion: @escaping (_ requestedPhoto: UIImage?) -> Void){

    // TODO: Change cache to use URL.
//    if photoCache.index(forKey: photoID) != nil{
//        completion(photoCache[photoID])
//        
//        return
//    }
    
    
    // TODO: Change photo when error occurs. (!)
    var photo = UIImage(named: "unknownUser")!
    
    let formattedURL = URL(string: url)
    
    if (formattedURL == nil) {
        logger.message(type: .error, message: "URL not formatted correctly.")
        completion(photo)
        return
    }
    
    let request: URLRequest = URLRequest(url: formattedURL!)
    let session = URLSession.shared
    
    let task = session.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
        if (error == nil && data != nil) {
            let receivedPhoto = UIImage(data: data!)
            
            // TODO: Check this to see if it worked...
            DispatchQueue.main.async {
                if receivedPhoto != nil{
                    photo = receivedPhoto!
                    
//                    photoCache[photoID] = photo
                    
                    completion(photo)
                }
                else{
                    completion(photo)
                }
            }
        }
        else{
            if error != nil{
                logger.message(type: .error, message: "Could not get media from: \(error!.localizedDescription)")
            }
            else {
                logger.message(type: .error, message: "Received nil data from media request.")
            }
            
            completion(photo)
        }
    })
    
    task.resume()
}

//func requestVideo(_ videoID: String!, slice: Slice!, completion: @escaping (_ success: Bool?, _ videoURL: URL?) -> Void){
//    
//    if videoCache.index(forKey: videoID) != nil{
//        completion(true, videoCache[videoID])
//        
//        return
//    }
//    
//    //var video = UIImage(named: "unknownUser")!
//    var videoURL: URL!
//    
//    let url = ApiHelper.BASE_URL + "/get_video_with_id?requested_id=\(videoID!)"
//    
//    Alamofire.request(url, method: .get, parameters: nil, headers: apiHelper.authTokenHeader()).responseJSON { response in
//        switch response.result{
//        case .success(let data):
//            let json = JSON(data)
//            
//            let errorMessage = json["message"].string
//            
//            if (errorMessage != nil){
//            
//                print("Error during request for video: \(errorMessage)")
//                
//                slice.isVideo = false
//                slice.photoImg = UIImage(named: "unknownUser")!
//                completion(false, nil)
//                return
//            }
//            
//            videoURL = URL(string: json["image_url"].string!)
//           
//            var localPath: URL?
//            Alamofire.download(videoURL, to: { (temporaryURL, response) in
//                localPath = getNewVideoPath(videoID)
//                
//                return (localPath!, [.removePreviousFile, .createIntermediateDirectories])
//            }).response { response in
//                    if (response.error == nil){
//                        print("Downloaded video slice to \(localPath!)")
//                        videoCache[videoID] = localPath!
//                        completion(true, localPath!)
//                    }
//                    else{
//                        print("Error download of video: \(errorMessage)")
//                        
//                        slice.isVideo = false
//                        slice.photoImg = UIImage(named: "unknownUser")!
//                        completion(false, nil)
//                    }
//            }
//            
//
//            
//        case .failure(let error):
//            print("Request failed with error: \(error)")
//            
//            slice.isVideo = false
//            slice.photoImg = UIImage(named: "unknownUser")!
//            completion(false, nil)
//            
//        }
//    }
//}


func getNewVideoPath(_ videoID: String!) -> URL!{
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
    let videoURL = URL(fileURLWithPath: documentsPath.appendingPathComponent("SliceVideo_\(videoID).mov"))
    
    do {
        try FileManager.default.removeItem(at: videoURL)
    } catch {}
    
    return videoURL
}

