import SwiftyJSON
import Alamofire

class Conversation: NSObject {
    var id: Int!
    var title: String!
    var users = [SliceUser]()
    
    enum ConvoLoadStatus{
        case notLoaded
        case loading
        case loaded
    }
    
    var loadStatus: ConvoLoadStatus = ConvoLoadStatus.notLoaded
    
    func createConversationFromJSON(_ jsonDict: [String : JSON], completion: @escaping () -> Void){
            
        self.id = jsonDict["id"]!.int!
        self.title = jsonDict["title"]!.string!
        
        let participants = jsonDict["participants"]!.array!
            
        for participant in participants{
            let user = participant.dictionary!
            
            print("Participant JSON: \(user)")
                
            let newUser = SliceUser()
            newUser.requestUserInfo(user["user_id"]!.int!, isRequestingSelf: false, completion: {(success) -> Void in
                newUser.convoContributions = user["contributions"]!.int!
                self.users.append(newUser)
                
                print("user count = \(self.users.count) and participant count = \(participants.count)")
                if (self.users.count == participants.count){completion()}
            })
        }
    }
    
    func requestUserPhotos(_ completion: (_ success: Bool) -> Void){
        
    }
    
    func requestLeaveConversation(_ completion: @escaping (_ success: Bool) -> Void){
        let url = ApiHelper.BASE_URL + "/leave_convo"
    
        let params: [String : String]? = ["convo_id": String(id)]
        
        Alamofire.request(url, method: .post, parameters: params, headers: apiHelper.authTokenHeader()).responseJSON { response in
            switch response.result{
            case .success(let data):
                let json = JSON(data)
                
                print("\(json)")
                
                completion(true)
                
            case .failure(let error):
                print("Leave conversation request failed with error: \(error)")
                
                completion(false)
            }
        }

    }
    
    func sendReceiveNoticiationChange(_ receiveNotifications: Bool, completion: @escaping (_ success: Bool) -> Void){
        let url = ApiHelper.BASE_URL + "/change_convo_notifications"
        
        let recNotifs = (receiveNotifications) ? "1" : "0"
        
        let params: [String : String]? = ["convo_id": String(id), "rec_notifs": recNotifs]
        
        Alamofire.request(url, method: .post, parameters: params, headers: apiHelper.authTokenHeader()).responseJSON { response in
            switch response.result{
            case .success(let data):
                let json = JSON(data)
                
                print("\(json)")
                
                completion(true)
                
            case .failure(let error):
                print("Conversation notification change request failed with error: \(error)")
                
                completion(false)
            }
        }
    
    }
    
}
