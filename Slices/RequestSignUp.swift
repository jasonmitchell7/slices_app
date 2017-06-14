import Alamofire
import SwiftyJSON

func requestSignUp(_ username: String, email:String, newPassword:String, birthdate: Date, completion: @escaping (_ success: Bool, _ errorMessage: String?) -> Void){
    
    // Encrypt password with 64-bit key from API
    let encryptedPassword = AESCrypt.encrypt(newPassword, password: ApiHelper.API_AUTH_PASSWORD)
    
    let url = ApiHelper.BASE_URL + "/signup"
    
    let formatter = DateFormatter()
    formatter.dateFormat = "dd-MM-yyyy"
    let formattedBirthdate = formatter.string(from: birthdate)
    
    let params: [String : Any]? = ["username": username,
                                   "email": email,
                                   "password": encryptedPassword!,
                                   "birthdate": formattedBirthdate]
    
    logger.message(type: .debug, message: "Sending sign up request with: \(params)")
    
    Alamofire.request(url, method: .post, parameters: params, headers: apiHelper.basicAuthHeader()).responseJSON { response in
        switch response.result{
        case .success(let data):
            let json = JSON(data)
            
            let errorMessage = json["message"].string
            
            if (errorMessage != nil)
            {
                logger.message(type: .error, message: "Request failed with error: \(errorMessage)")
                completion(false, "Request failed with error: \(errorMessage)")
            }
            
            completion(true, nil)
            
        case .failure(let error):
            logger.message(type: .error, message: "Request failed with error: \(error)")
            completion(false, "Request failed with error: \(error)")
        }
    }
}
