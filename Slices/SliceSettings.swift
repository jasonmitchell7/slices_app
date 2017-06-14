import SwiftyJSON
import Alamofire

class SliceSettings: NSObject {
    var requireAcceptance: (value: Bool, name: String) = (value: true, name: "Require follow acceptance")
    var allowFeatured: (value: Bool, name: String) = (value: true, name: "Allow Slices to be featured")
    var allowNearby:  (value: Bool, name: String) = (value: true, name: "Slices visible to people nearby")
    var receiveAlerts: (value: Bool, name: String) = (value: true, name: "Receive notifications")
    var notifyOnFollowed: (value: Bool, name: String) = (value: true, name: "Notify when followed")
    var notifyOnAccepted:  (value: Bool, name: String) = (value: true, name: "Notify when follow was accepted")
    var notifyOnNewTopping:  (value: Bool, name: String) = (value: true, name: "Notify on new Topping")
    var notifyOnConvoActivity: (value: Bool, name: String) = (value: true, name: "Notify on conversation activity")
    var notifyOnUnpublishedActivity: (value: Bool, name: String) = (value: true, name: "Notify on unpublished Slice activty")
    var notifyOnFeatured: (value: Bool, name: String) = (value: true, name: "Notify when featured")
    var notifyOnExpireSoon: (value: Bool, name: String) = (value: true, name: "Notify before Slice expires")
    
    public func getSettingsSectionsList() -> [String] {
        return ["Privacy", "Notifications"]
    }

    public func getSettingsList() -> [[(Bool, String)]] {
        var newArray: [[(Bool, String)]] = [[(Bool, String)]]()
        
        newArray.append(getPrivacySettingsList())
        
        if (receiveAlerts.value == true) {
            newArray.append(getNotifcationSettingsList())
        } else {
            newArray.append(getNotificationSetting())
        }
        
        return newArray
    }
    
    public func getPrivacySettingsCount() -> Int {
        return getPrivacySettingsList().count
    }
    
    public func getNotificationSettingsCount() -> Int {
        if (receiveAlerts.value == true) {
            return getNotifcationSettingsList().count
        }
        
        return getNotificationSetting().count
    }
    
    private func getPrivacySettingsList() -> [(Bool, String)] {
        var newArray: [(Bool, String)] = [(Bool, String)]()
        
        newArray.append(requireAcceptance)
        newArray.append(allowFeatured)
        newArray.append(allowNearby)
        
        return newArray
    }
    
    private func getNotificationSetting() -> [(Bool, String)] {
        var newArray: [(Bool, String)] = [(Bool, String)]()
        
        newArray.append(receiveAlerts)
        
        return newArray
    }
    
    private func getNotifcationSettingsList() -> [(Bool, String)] {
        var newArray: [(Bool, String)] = [(Bool, String)]()

        newArray.append(receiveAlerts)
        newArray.append(notifyOnFollowed)
        newArray.append(notifyOnAccepted)
        newArray.append(notifyOnNewTopping)
        newArray.append(notifyOnConvoActivity)
        // Multi-User Slices are a future addition, and might not make it into the MVP.
        // newArray.append(notifyOnUnpublishedActivity)
        newArray.append(notifyOnFeatured)
        newArray.append(notifyOnExpireSoon)
        
        return newArray
    }
    
    func requestSettingsInfo( _ completion: @escaping (_ success: Bool) -> Void){
        let url = ApiHelper.BASE_URL + "/request_settings_info"
        
        Alamofire.request(url, method: .get, parameters: nil, headers: apiHelper.authTokenHeader()).responseJSON { response in
            print("\(response.result)")
            switch response.result{
            case .success(let data):
                print("\(data)")
                let json = JSON(data)
                
                print("\(json)")
                
                let errorMessage = json["message"].string
                
                if (errorMessage != nil)
                {
                    print("Error in settings info request: \(errorMessage)")
                    
                    completion(false)
                    return
                }
                else{
                    if (json == nil){
                        print("Error: Recieved null json object when requesting settings info.")
                        
                        completion(false)
                        return
                    }
                    
                    self.parseJSON(json, completion:{ (parseSuccess) -> Void in
                        completion(parseSuccess)
                    })
                }
                
            case .failure(let error):
                print("Settings info request failed with error: \(error)")
                completion(false)
            }
            
        }
    }
    
    func parseJSON(_ json:JSON, completion: (_ succes: Bool) -> Void){
        requireAcceptance.value = json["require_acceptance"].boolValue
        allowFeatured.value = json["allow_featured"].boolValue
        allowNearby.value = json["allow_nearby"].boolValue
        notifyOnFollowed.value = json["notify_on_followed"].boolValue
        notifyOnAccepted.value = json["notify_on_accepted"].boolValue
        notifyOnNewTopping.value = json["notify_on_new_topping"].boolValue
        notifyOnConvoActivity.value = json["notify_on_convo_activity"].boolValue
        notifyOnUnpublishedActivity.value = json["notify_on_unpublished_activity"].boolValue
        notifyOnFeatured.value = json["notify_on_featured"].boolValue
        notifyOnExpireSoon.value = json["notify_on_expire_soon"].boolValue
        receiveAlerts.value = json["receive_notification_alerts"].boolValue
        
        completion(true)
    }

    func updateSettingsInfo(_ completion: (_ success: Bool) -> Void){
        
        let url = ApiHelper.BASE_URL + "/update_settings_info"

        let params: [String : Int]? = ["require_acceptance": requireAcceptance.value.toInt()!,
                                      "allow_featured": allowFeatured.value.toInt()!,
                                      "allow_nearby": allowNearby.value.toInt()!,
                                      "notify_on_followed": notifyOnFollowed.value.toInt()!,
                                      "notify_on_accepted": notifyOnAccepted.value.toInt()!,
                                      "notify_on_new_topping": notifyOnNewTopping.value.toInt()!,
                                      "notify_on_convo_activity": notifyOnConvoActivity.value.toInt()!,
                                      "notify_on_unpublished_activity": notifyOnUnpublishedActivity.value.toInt()!,
                                      "notify_on_featured": notifyOnFeatured.value.toInt()!,
                                      "notify_on_expire_soon": notifyOnExpireSoon.value.toInt()!,
                                      "receive_notification_alerts": receiveAlerts.value.toInt()!]
        
        Alamofire.request(url, method: .post, parameters: params, headers: apiHelper.authTokenHeader()).responseJSON { response in
            switch response.result{
            case .success(let data):
                let json = JSON(data)
                
                print("\(json)")
                
                
            case .failure(let error):
                print("Updating settings failed with error: \(error)")
                
            }
        }
    }
    
    func updateValueForSetting(value: Bool, name: String) {
        switch (name) {
        case requireAcceptance.name:
            requireAcceptance.value = value
        case allowFeatured.name:
            allowFeatured.value = value
        case allowNearby.name:
            allowNearby.value = value
        case notifyOnFollowed.name:
            notifyOnFollowed.value = value
        case notifyOnAccepted.name:
            notifyOnAccepted.value = value
        case notifyOnNewTopping.name:
            notifyOnNewTopping.value = value
        case notifyOnConvoActivity.name:
            notifyOnConvoActivity.value = value
        case notifyOnFeatured.name:
            notifyOnFeatured.value = value
        case notifyOnExpireSoon.name:
            notifyOnExpireSoon.value = value
        case receiveAlerts.name:
            receiveAlerts.value = value
        default:
            logger.message(type: .error, message: "Attempted to update a setting that does not exist: \(name)")
        }
    }
    
    func getValueForSetting(name: String) -> Bool {
        switch (name) {
        case requireAcceptance.name:
            return requireAcceptance.value
        case allowFeatured.name:
            return allowFeatured.value
        case allowNearby.name:
            return allowNearby.value
        case notifyOnFollowed.name:
            return notifyOnFollowed.value
        case notifyOnAccepted.name:
            return notifyOnAccepted.value
        case notifyOnNewTopping.name:
            return notifyOnNewTopping.value
        case notifyOnConvoActivity.name:
            return notifyOnConvoActivity.value
        case notifyOnFeatured.name:
            return notifyOnFeatured.value
        case notifyOnExpireSoon.name:
            return notifyOnExpireSoon.value
        case receiveAlerts.name:
            return receiveAlerts.value
        default:
            logger.message(type: .error, message: "Attempted to get a setting that does not exist: \(name)")
            return false
        }
    }
    
}
