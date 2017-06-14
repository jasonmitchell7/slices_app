import UIKit
import SwiftyJSON
import Alamofire

class Slice: NSObject {
    static let maxSliceDuration = TimeInterval(20)
    static let sliceMediaSize: Int = 375
    static let toppingsDisplayHeight = CGFloat(112)
    static let minTitleLength: Int = 3
    static let maxTitleLength: Int = 80
    
    var createdDate: Date!
    var expirationDate: Date!
    var sliceID: Int!
    var title: String!
    var locationString: String!
    var videoFailedLoad: Bool! = false
    var user: SliceUser!
    var parentID: Int?
    var toppings = [Slice]()
    var toppingsCount: Int = 0
    
    var mediaList = [SliceMedia]()

    func requestToppings(_ completion: @escaping (_ success: Bool) -> Void){
        
        toppings = [Slice]()
        
        let url = ApiHelper.BASE_URL + "/get_toppings?slice_id=\(sliceID!)"
        
        Alamofire.request(url, method: .get, parameters: nil, headers: apiHelper.authTokenHeader()).responseJSON { response in
            switch response.result{
            case .success(let data):
                let json = JSON(data)
                
                let errorMessage = json["message"].string
                
                if (errorMessage != nil)
                {
                    logger.message(type: .error, message: "Error in toppings request: \(errorMessage)")
                    
                    completion(false)
                    return
                }
                else{
                    
                    let jsonArray = json.array
                    
                    for item in jsonArray!{
                        let jsonDict = item.dictionary!
                        
                        let newSlice = Slice()
                        newSlice.user = SliceUser()
                        
                        newSlice.buildFromJSON(jsonDict)
                        self.toppings.append(newSlice)
                    }
                    
                    completion(true)
                }
                
            case .failure(let error):
                logger.message(type: .error, message: "Toppings request failed with error: \(error)")
                
                completion(false)
            }
        }
    }
    
    func buildFromJSON(_ jsonDict: [String : JSON]){
        self.user = SliceUser()
        
        self.user.userId = jsonDict["user_id"]!.int!
        self.user.username = jsonDict["username"]!.string!
        self.user.photoId = jsonDict["user_photo_id"]!.string
        self.title = jsonDict["title"]!.string!
        self.locationString = jsonDict["location_string"]!.string as String!
        self.sliceID = jsonDict["id"]!.int!
        //newSlice.expirationDate = stringToDateShort(jsonDict["expiration"]!.string!)
        self.createdDate = stringToDateLong(jsonDict["created_at"]!.string!)
        let week:TimeInterval = 7*TimeInterval(86400)
        self.expirationDate = self.createdDate.addingTimeInterval(week)
        
        if let _toppingsCount = jsonDict["toppings_count"]!.int {
            toppingsCount = _toppingsCount
        }
        
        if let mediaListJSONArray = jsonDict["media_list"]?.array {
            for item in mediaListJSONArray {
                let jsonDict = item.dictionary!
                
                let media = SliceMedia()
                media.buildFromJSON(jsonDict)
                self.mediaList.append(media)
            }
        } else {
            logger.message(type: .error, message: "Slice JSON had no media list.")
        }
    }
    
    func requestSliceMediaList(completion: @escaping (_ success: Bool) -> Void) {
        mediaList.removeAll()
        
        let url = ApiHelper.BASE_URL + "/get_slice_media_list?slice_id=\(sliceID!)"
        
        Alamofire.request(url, method: .get, parameters: nil, headers: apiHelper.authTokenHeader()).responseJSON { response in
            switch response.result{
            case .success(let data):
                let json = JSON(data)
                
                let errorMessage = json["message"].string
                
                if (errorMessage != nil)
                {
                    logger.message(type: .error, message: "Error in media list request: \(errorMessage)")
                    
                    completion(false)
                    return
                }
                else{
                    
                    let jsonArray = json.array
                    
                    for item in jsonArray!{
                        let jsonDict = item.dictionary!
                        
                        let media = SliceMedia()
                        media.buildFromJSON(jsonDict)
                        self.mediaList.append(media)
                    }
                    
                    self.mediaList.sort {
                        $0.seq < $1.seq
                    }
                    
                    completion(true)
                }
                
            case .failure(let error):
                logger.message(type: .error, message: "Media list failed with error: \(error)")
                
                completion(false)
            }
        }
    }
    
    func resizeSlicePhoto(sourceImage: UIImage) -> UIImage {
        let targetWidth = UIScreen.main.bounds.width
        let scaleFactor =  targetWidth / sourceImage.size.width
        let targetHeight = sourceImage.size.height * scaleFactor
        
        UIGraphicsBeginImageContext(CGSize(width: targetWidth, height: targetHeight))
        sourceImage.draw(in: CGRect(x: 0, y: 0, width: targetWidth, height: targetHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func publishSlice(completion:@escaping (_ success: Bool) -> Void) {
        if (sliceID == nil || mediaList.count == 0) {
            completion(false)
        }
        
        let url = ApiHelper.BASE_URL + "/publish_slice"
        
        let params: [String : Any] = ["slice_id": sliceID!]
        
        logger.message(type: .debug, message: "Publishing Slice with params: \(params).")
        
        Alamofire.request(url, method: .post, parameters: params, headers: apiHelper.authTokenHeader()).responseJSON { response in
            switch response.result{
            case .success(let data):
                let json = JSON(data)
                
                logger.message(type: .debug, message: "Successfully published Slice: \(json)")
                
                completion(true)
                
            case .failure(let error):
                logger.message(type: .error, message: "Could not publish Slice: \(error)")
                completion(false)
            }
        }
    }
}
