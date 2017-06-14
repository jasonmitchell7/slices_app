import UIKit
import Alamofire
import SwiftyJSON

var currentUser: SliceUser?

class SliceUser: NSObject {
    var username: String!
    var userId: Int!
    var userDescription: String = ""
    var photoId: String?
    var photoURL: URL?
    var photoImg: UIImage?
    var followers: [SliceUser]?
    var following: [SliceUser]?
    var convoContributions = 0
    var sliceCount = 0
    var followingCount = 0
    var potentialFollowerCount = 0
    var followerCount = 0
    var accepted: Bool = true
    var email: String?
    var emailConfirmed = false
    
    func isFollowingUserWithID(_ id: Int!) -> Bool {
        if (following != nil) {
            return following!.contains(where: {id == $0.userId})
        }
        
        logger.message(type: .error, message: "Following was nil in isFollowingUserWithID.")
        return false
    }
    
    func requestUserInfo(_ requestedID: Int, isRequestingSelf: Bool, completion: @escaping (_ success: Bool) -> Void){
        let url = ApiHelper.BASE_URL + "/request_user_info"
        
        let params = [
            "requested_id": requestedID,
            "for_self": (isRequestingSelf ? 1 : 0)
        ]
        
        logger.message(type: .debug, message: "Requesting user info for \(requestedID)\(isRequestingSelf ? "for self." : ".")")
        logger.message(type: .debug, message: "Current authtoken: \(apiHelper.authTokenHeader())")
        
        Alamofire.request(url, method: .post, parameters: params, headers: apiHelper.authTokenHeader()).responseJSON { response in
            logger.message(type: .information, message: "response: \(response)")
            logger.message(type: .information, message: "result: \(response.result)")
                
            switch response.result{
            case .success(let data):
                let json = JSON(data)
                
                logger.message(type: .debug, message: "RequestUserInfo reponse: \(json)")
                
                self.username = json["username"].string!
                self.userId = json["id"].int!
                let tempUserDescription = json["description"].string
                if (tempUserDescription != nil) {
                    self.userDescription = tempUserDescription!
                }
                let photo = json["photo_id"].string
                self.sliceCount = json["slice_count"].int!
                self.followerCount = json["follower_count"].int!
                self.potentialFollowerCount = json["potential_follower_count"].int!
                self.followingCount = json["following_count"].int!
                if (photo != nil && photo != "<null>") {
                    self.photoId = photo!
                }
                
                self.email = json["email"].string
                self.emailConfirmed = (json["is_email_confirmed?"].bool == true) ? true : false
                
                
                completion(true)
                
            case .failure(let error):
                logger.message(type: .error, message: "Request failed with error: \(error)")
                completion(false)
            }
            
        }
    }
    
    func requestUserPhoto(_ completion: @escaping () -> Void){

        if self.photoId == nil {
            
            self.photoImg = UIImage(named: "unknownUser")
            completion()
            
            return
        }

        logger.message(type: .information, message: "Requesting user photo for \(self.username).")
        
        requestPhotoWithID(self.photoId!, completion: { (requestedPhoto) -> Void in
            self.photoImg = requestedPhoto
            
            logger.message(type: .information, message: "Got user photo for \(self.username).")
            
            completion()
        })
    }

    func postSlice(title: String, parentID: Int?, completion: @escaping (_ success: Bool, _ errorMessage: String?, _ sliceID: Int?) -> Void){
        let url = ApiHelper.BASE_URL + "/post_slice"
        
        var params: [String : Any] = ["title": title]
        
        if (parentID != nil) {
            params["parentID"] = parentID!
        }
        
        if (locationMgr.locationString != nil && locationMgr.latitude != nil && locationMgr.longitude != nil) {
            params["location_string"] = locationMgr.locationString!
            params["latitude"] = locationMgr.latitude!
            params["longtitude"] = locationMgr.longitude!
        }
        
        logger.message(type: .debug, message: "Posting Slice with params: \(params).")
        
        Alamofire.request(url, method: .post, parameters: params, headers: apiHelper.authTokenHeader()).responseJSON { response in
            switch response.result{
            case .success(let data):
                let json = JSON(data)
                let jsonDict = json.dictionary!
                
                logger.message(type: .debug, message: "JSON from posting Slice: \(json)")
                
                completion(true, nil, jsonDict["id"]?.int)
                
            case .failure(let error):
                logger.message(type: .error, message: "Posting Slice failed with error: \(error)")
                completion(false, error.localizedDescription, nil)
            }
        }
    }
    
    func requestSlices(_ convoID: Int?, fromUser: Int?, count: Int,  currentView: UIViewController?, completion: @escaping (Bool, [Slice]?) -> Void){
        
        var url = ApiHelper.BASE_URL + "/get_slices?count=\(count)"
        
        if (convoID != nil){
            url = url + "&convo_id=\(convoID!)"
        }
        
        if (fromUser != nil){
            url = url + "&user_id=\(fromUser!)"
        }
        
        Alamofire.request(url, method: .get, parameters: nil, headers: apiHelper.authTokenHeader()).responseJSON { response in
            logger.message(type: .information, message: "\(response.result)")
            switch response.result{
            case .success(let data):
                let json = JSON(data)
                logger.message(type: .debug, message: "Request Slices json: \(json)")
                
                let errorMessage = json["message"].string
                
                if (errorMessage != nil)
                {
                    if (currentView != nil){
                        // Display Modal Alert
                        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Back", style: UIAlertActionStyle.default, handler: nil))
                        currentView?.present(alert, animated: true, completion: nil)
                    }
    
                    logger.message(type: .error, message: "Error in slice request: \(errorMessage)")
    
                    completion(false, nil)
                    return
                }
                else{
                    
                    if (json == nil ){
                        logger.message(type: .error, message: "Recieved null json object when requesting public slices.")
                        
                        completion(false, nil)
                        return
                    }
                    
                    var slices = [Slice]()
                    
                    let jsonArray = json.array
                    
                    for item in jsonArray!{
                        let jsonDict = item.dictionary!
                        
                        if (slices.index(where: {$0.sliceID == jsonDict["id"]!.int!}) == nil){
                            let newSlice = Slice()
                            newSlice.buildFromJSON(jsonDict)
                            slices.append(newSlice)
                        }
                    }
                    
                    completion(true, slices)
                }
                
            case .failure(let error):
                logger.message(type: .error, message: "Request failed with error: \(error)")
                completion(false, nil)
            }
        }
    }
    
    func updateUserDescription(_ newDescription: String!, completion: @escaping (_ success: Bool?) -> Void){
        
        let url = ApiHelper.BASE_URL + "/update_description"
        
        let params: [String : Any]? = ["new_description": newDescription]
        
        Alamofire.request(url, method: .post, parameters: params, headers: apiHelper.authTokenHeader()).responseJSON { response in
            switch response.result{
            case .success(let data):
                let json = JSON(data)
                
                logger.message(type: .debug, message: "UpdateUserDescription json: \(json)")
                currentUser?.userDescription = newDescription
                completion(true)
                
            case .failure(let error):
                logger.message(type: .error, message: "Updating settings failed with error: \(error)")
                completion(false)
            }
        }
    }
}
