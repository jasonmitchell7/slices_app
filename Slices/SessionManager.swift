import UIKit
import Alamofire
import SwiftyJSON

var sessionMgr: SessionManager = SessionManager()

class SessionManager: NSObject {
    
    let defaults = UserDefaults.standard
    
    func checkLoggedIn(_ completion: @escaping (_ wasLoggedIn: Bool) -> Void) {
        
        print("Checking if logged in...")
        // Check if the user is currently logged in.
        if defaults.object(forKey: "userLoggedIn") == nil {
            print("User not logged in...")
            
            loadLoginStoryboard()
            completion(false)
        }
        else if checkSessionExpired() {
            doLogout({ () -> Void in
                self.loadLoginStoryboard()
                completion(false)

            })
        }
        else{
            self.getUserInfo({(userSuccess) -> Void in
                if (userSuccess){
                    completion(true)
                }
                else{
                    print("Failed to grab user during expired session auto login attempt.")
                    completion(false)
                    self.loadLoginStoryboard()
                }
            })
        }
    }
    
    func getUserInfo(_ completion: @escaping (_ success: Bool) -> Void){
        if currentUser == nil{
            currentUser = SliceUser()
        }
        currentUser?.requestUserInfo(0, isRequestingSelf: true, completion: {(requestSuccess) -> Void in
            completion(requestSuccess)
            locationMgr.setupLocationManager()
        })

    }
    
    func checkSessionExpired() -> Bool {
        // Check if the API token has expired.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let userTokenExpiryDate: String? = KeychainAccess.passwordForAccount("Auth_Token_Expiry", service: "KeyChainService")
        
        if userTokenExpiryDate == nil{
            return true
        }
        
        let dateFromString: Date? = dateFormatter.date(from: userTokenExpiryDate!)
        let now = Date()
        
        let comparision = now.compare(dateFromString!)
        
        if comparision != ComparisonResult.orderedAscending{
            return true
        }
        
        return false
    }
    
    func loadLoginStoryboard(){
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "InitialController")  
        
        UIApplication.shared.keyWindow?.rootViewController?.present(controller, animated: true, completion: nil)
    }
    
    func doLogout(_ completion:() -> Void){
        // Clear flag from NSUserDefaults
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "userLoggedIn")
        defaults.synchronize()
        
        // TODO: Add Remove Data Array
        
        // Clear the API auth token from keychain
        if let userToken = KeychainAccess.passwordForAccount("Auth_Token", service: "KeyChainService"){
            KeychainAccess.deletePasswordForAccount(userToken, account: "Auth_Token", service: "KeyChainService")
        }
        
        // Clear the API auth expiry from keychain
        if let userTokenExpiryDate = KeychainAccess.passwordForAccount("Auth_Token_Expiry", service: "KeyChainService"){
            KeychainAccess.deletePasswordForAccount(userTokenExpiryDate, account: "Auth_Token_Expiry", service: "KeyChainService")
        }
        
        // Present the login storyboard to the user
        //loadLoginStoryboard()
        
        // Remove the current user information from memory.
        currentUser = nil
        
        completion()
    }
    
    func requestPushNotificationPermission(){
        // Register for Push Notifications
        print("register for notifications?")
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func makeSignInRequest(_ userEmail: String, userPassword: String, completion: @escaping (_ success: Bool, _ errorMessage: String?) -> Void){
        
        // Encrypt password with 64-bit key from API
        let encryptedPassword = AESCrypt.encrypt(userPassword, password: apiHelper.API_AUTH_PASSWORD)
        
        
        let url = ApiHelper.BASE_URL + "/signin"
        
        let params: [String : String] = ["email": userEmail,"password": encryptedPassword!]

        logger.message(type: .information, message: "Attempting login with \(userEmail) and \(userPassword) as \(encryptedPassword!).")
        
        logger.message(type: .information, message: "Signin Request Header: \(apiHelper.basicAuthHeader())")
        
        print(params)
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: apiHelper.basicAuthHeader()).responseJSON { response in
            switch response.result{
            case .success(let data):
                let json = JSON(data)
                
                logger.message(type: .information, message: "JSON Returned from signin attempt: \(json)")
                
                let errorMessage = json["message"].string
                
                if (errorMessage != nil)
                {
                    logger.message(type: .error, message: "Signin attemp failed with error message: \(errorMessage)")
                    completion(false, errorMessage!)
                    return
                }
                
                if let authtoken = json["api_authtoken"].string {
                    self.saveApiTokenInKeychain(authtoken, authTokenExpiry: json["authtoken_expiry"].string, completion: {(saveApiSuccess) -> Void in
                        completion(saveApiSuccess, nil)
                    })
                }
                else {
                    let error = "Error: Did not receive authtoken during sign-in request."
                    logger.message(type: .error, message: "Did not receive error message during sign in attempt.")
                    completion(false, error)
                }
                
            case .failure(let error):
                logger.message(type: .error, message: "Login request failed with error: \(error)")
                completion(false, nil)
            }
            
        }
    }
    
    func saveApiTokenInKeychain(_ apiAuthToken: String!, authTokenExpiry: String!, completion: @escaping (_ success: Bool) -> Void){
        
        print("Saving auth token: \(apiAuthToken)")
        
        KeychainAccess.setPassword(apiAuthToken, account: "Auth_Token", service: "KeyChainService")
        KeychainAccess.setPassword(authTokenExpiry, account: "Auth_Token_Expiry", service: "KeyChainService")
        
        updateUserLoggedInFlag({(updateSuccess) -> Void in
            completion(updateSuccess)
        })
        
    }
    
    func updateUserLoggedInFlag(_ completion: @escaping (_ success: Bool) -> Void){
        // Update flag in NSUserDefaults for quicker transition when opening app next time.
        let defaults = UserDefaults.standard
        defaults.set("loggedIn", forKey: "userLoggedIn")
        defaults.synchronize()
        
        currentUser = SliceUser()
        
        currentUser?.requestUserInfo(0, isRequestingSelf: true, completion: { (success) -> Void in
            self.requestPushNotificationPermission()
            completion(success)
        })
        
//        requestCurrentUser({ (success) -> Void in
//            self.requestPushNotificationPermission()
//            completion(success)
//        })
    }
    
}
