import UIKit
import Alamofire
import SwiftyJSON

extension SliceUser {
    
    func getFollowersCountString() -> String {
        return "\(self.followerCount)"
    }
    
    func getAllFollowersCountString() -> String {
        return "\(self.followerCount + self.potentialFollowerCount)"
    }
    
    func getPotentialFollowersCountString() -> String {
        return "\(self.potentialFollowerCount)"
    }
    
    func getFollowingCountString() -> String {
        return "\(self.followingCount)"
    }
    
    func requestFollowers(_ completion: CompletionHandlerClosureType?){
        var followersList = [SliceUser]()
        
        let url = ApiHelper.BASE_URL + "/request_followers"
        
        let params: [String : String]? = ["requested_id": String(userId)]
        
        Alamofire.request(url, method: .post, parameters: params, headers: apiHelper.authTokenHeader()).responseJSON { response in
            switch response.result{
            case .success(let data):
                let json = JSON(data)
                
                logger.message(type: .information, message: "Followers: \(json)")
                
                let errorMessage = json["message"].string
                
                if (errorMessage != nil)
                {
                    logger.message(type: .error, message: "Requesting followers: \(errorMessage)")
                }
                else{
                    
                    let jsonArray = json.array
                    
                    for user in jsonArray!{
                        let jsonDict = user.dictionary!
                        
                        let newFollower = SliceUser()
                        
                        newFollower.username = jsonDict["username"]!.string!
                        newFollower.userId = jsonDict["id"]!.int!
                        newFollower.photoId = jsonDict["photo_id"]!.string
                        newFollower.accepted = jsonDict["accepted"]!.bool!
                        newFollower.followerCount = jsonDict["follower_count"]!.int!
                        newFollower.potentialFollowerCount = jsonDict["potential_follower_count"]!.int!
                        newFollower.followingCount = jsonDict["following_count"]!.int!
                        newFollower.sliceCount = jsonDict["slice_count"]!.int!
                        let tempUserDescription = jsonDict["description"]!.string
                        if (tempUserDescription != nil) {
                            newFollower.userDescription = tempUserDescription!
                        }
                        
                        followersList.append(newFollower)
                    }
                }
                
            case .failure(let error):
                logger.message(type: .error, message: "Requesting followers: \(error)")
            }
            
            self.followers = followersList
            
            if completion != nil{
                completion!()
            }
        }
    }
    
    func requestFollowing(_ completion: CompletionHandlerClosureType?){
        var followingList = [SliceUser]()
        
        let url = ApiHelper.BASE_URL + "/request_following"
        
        let params: [String : String]? = ["requested_id": String(userId)]
        
        Alamofire.request(url, method: .post, parameters: params, headers: apiHelper.authTokenHeader()).responseJSON { response in
            switch response.result{
            case .success(let data):
                let json = JSON(data)
                
                logger.message(type: .information, message: "Following: \(json)")
                
                let errorMessage = json["message"].string
                
                if (errorMessage != nil)
                {
                    logger.message(type: .error, message: "Requesting following: \(errorMessage)")
                }
                else{
                    
                    let jsonArray = json.array
                    
                    for user in jsonArray!{
                        let jsonDict = user.dictionary!
                        
                        let newFollower = SliceUser()
                        
                        newFollower.username = jsonDict["username"]!.string!
                        newFollower.userId = jsonDict["id"]!.int!
                        newFollower.photoId = jsonDict["photo_id"]!.string
                        newFollower.followerCount = jsonDict["follower_count"]!.int!
                        newFollower.potentialFollowerCount = jsonDict["potential_follower_count"]!.int!
                        newFollower.followingCount = jsonDict["following_count"]!.int!
                        newFollower.sliceCount = jsonDict["slice_count"]!.int!
                        let tempUserDescription = jsonDict["description"]!.string
                        if (tempUserDescription != nil) {
                            newFollower.userDescription = tempUserDescription!
                        }
                        
                        followingList.append(newFollower)
                    }
                }
                
            case .failure(let error):
                logger.message(type: .error, message: "Requesting following: \(error)")
            }
            
            self.following = followingList
            
            if completion != nil{
                completion!()
            }
        }
    }
    
    func sendAcceptFollow(_ otherUserID: Int!, completion: @escaping (_ success: Bool?) -> Void){
        let url = ApiHelper.BASE_URL + "/accept_follow"
        
        let params: [String : String]? = ["other_user": String(otherUserID)]
        
        logger.message(type: .debug, message: "Accepting follow.")
        
        Alamofire.request(url, method: .post, parameters: params, headers: apiHelper.authTokenHeader()).responseJSON { response in
            switch response.result{
            case .success(let data):
                let json = JSON(data)
                
                logger.message(type: .information, message: "Accept follow response: \(json)")
                
                let errorMessage = json["message"].string
                
                if (errorMessage != nil && json["status"] != 200)
                {
                    print("Error during follow accept: \(errorMessage)")
                    
                    completion(false)
                }
                else{
                    completion(true)
                }
                
            case .failure(let error):
                print("Failure in follow accept: \(error)")
                completion(false)
            }
        }
    }
    
    func sendDeclineFollow(_ otherUserID: Int!, completion: @escaping (_ success: Bool?) -> Void){
        let url = ApiHelper.BASE_URL + "/decline_follow"
        
        let params: [String : Any]? = ["other_user": otherUserID]
        
        logger.message(type: .debug, message: "Declining follow.")
        
        Alamofire.request(url, method: .post, parameters: params, headers: apiHelper.authTokenHeader()).responseJSON { response in
            switch response.result{
            case .success(let data):
                let json = JSON(data)
                
                logger.message(type: .information, message: "Decline follow response: \(json)")
                
                let errorMessage = json["message"].string
                
                if (errorMessage != nil && json["status"] != 200)
                {
                    print("Error during follow decline: \(errorMessage)")
                    
                    completion(false)
                }
                else{
                    completion(true)
                }
                
            case .failure(let error):
                print("Failure in follow decline: \(error)")
                completion(false)
            }
        }
    }
    
    func requestFollowUser(_ userToFollow: SliceUser!, completion: @escaping (_ success: Bool?, _ errorMessage: String?) -> Void) {
        let url = ApiHelper.BASE_URL + "/follow_user"
        
        let params: [String : Any]? = ["other_user": userToFollow.userId]
        
        Alamofire.request(url, method: .post, parameters: params, headers: apiHelper.authTokenHeader()).responseJSON { response in
            switch response.result{
            case .success(let data):
                let json = JSON(data)
                
                let errorMessage = json["message"].string
                
                if (errorMessage != nil && json["status"].int != 200)
                {
                    completion(false, errorMessage)
                    return
                }
                else{
                    currentUser?.requestFollowing({ () -> Void in
                        completion(true, nil)
                    })
                }
                
            case .failure(let error):
                print("Request failed with error: \(error)")
                completion(false, "\(error)")
            }
        }
    }
    
    func requestUnfollowUser(_ userBeingFollowed: SliceUser!, userFollowing: SliceUser!, completion: @escaping (_ success: Bool?, _ errorMessage: String?) -> Void) {
        let url = ApiHelper.BASE_URL + "/unfollow_user"
        
        let params: [String : Any]? = ["being_followed_id": userBeingFollowed.userId, "user_following_id": userFollowing.userId]
        
        Alamofire.request(url, method: .post, parameters: params, headers: apiHelper.authTokenHeader()).responseJSON { response in
            switch response.result{
            case .success(let data):
                let json = JSON(data)
                
                let errorMessage = json["message"].string
                
                if (errorMessage != nil)
                {
                    completion(false, errorMessage)
                    return
                }
                else{
                    currentUser?.requestFollowing({ () -> Void in
                        currentUser?.requestFollowers({ () -> Void in
                            completion(true, nil)
                        })
                    })
                }
                
            case .failure(let error):
                print("Request failed with error: \(error)")
                completion(false, "\(error)")
            }
        }
    }

}
