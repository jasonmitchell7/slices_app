import Foundation

let apiHelper = ApiHelper()

struct ApiHelper {
    static let API_AUTH_NAME = "ENTER_YOUR_AUTH_NAME_HERE"
    static let API_AUTH_PASSWORD = "ENTER_YOUR_AUTH_PASSWORD_HERE"
    static let BASE_URL = "ENTER_YOUR_URL_HERE"
    
    func basicAuthHeader() -> [String:String]{
        let basicAuthString = "\(API_AUTH_NAME):\(API_AUTH_PASSWORD)"
        let utf8str = basicAuthString.data(using: String.Encoding.utf8)
        let base64creds = utf8str?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        return ["Authorization": "Basic \(base64creds!)"]
    }
    
    func authTokenHeader() -> [String:String]{
        let userToken = KeychainAccess.passwordForAccount("Auth_Token", service: "KeyChainService") as String!
        
        return ["Authorization": "Token token=\(userToken!)"]
        
    }
}
