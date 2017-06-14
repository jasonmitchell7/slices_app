import Alamofire
import SwiftyJSON

func sendChangeEmailRequest(newEmail: String, completion: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
    let url = ApiHelper.BASE_URL + "/change_email"
    
    let params: [String : Any]? = ["new_email": newEmail]
    
    logger.message(type: .debug, message: "Sending change email request with: \(params)")
    
    Alamofire.request(url, method: .post, parameters: params, headers: apiHelper.authTokenHeader()).responseJSON { response in
        switch response.result{
        case .success(let data):
            let json = JSON(data)
            
            let status = json["status"].int
            let errorMessage = json["message"].string
            
            if (errorMessage != nil && status != 200)
            {
                logger.message(type: .error, message: "Request failed with error: \(errorMessage)")
                completion(false, "Request failed with error: \(errorMessage)")
                return
            }
            
            logger.message(type: .information, message: "Change email request succeeded.")
            completion(true, nil)
            
        case .failure(let error):
            logger.message(type: .error, message: "Request failed with error: \(error)")
            completion(false, "Request failed with error: \(error)")
        }
    }
}

func sendResendConfirmationCodeRequest(completion: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
    let url = ApiHelper.BASE_URL + "/resend_confirm_email"
    
    logger.message(type: .debug, message: "Sending resend email confirmation request.")
    
    Alamofire.request(url, method: .post, parameters: nil, headers: apiHelper.authTokenHeader()).responseJSON { response in
        switch response.result{
        case .success(let data):
            let json = JSON(data)
            
            let status = json["status"].int
            let errorMessage = json["message"].string
            
            if (errorMessage != nil && status != 200)
            {
                logger.message(type: .error, message: "Request failed with error: \(errorMessage)")
                completion(false, "Request failed with error: \(errorMessage)")
                return
            }
            
            logger.message(type: .information, message: "Resend confirmation request succeeded.")
            completion(true, nil)
            
        case .failure(let error):
            logger.message(type: .error, message: "Request failed with error: \(error)")
            completion(false, "Request failed with error: \(error)")
        }
    }
}

func sendConfirmEmailRequest(code: String, completion: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
    let url = ApiHelper.BASE_URL + "/confirm_email"
    
    let params: [String : Any]? = ["code": code]
    
    logger.message(type: .debug, message: "Sending confirm email request with: \(params)")
    
    Alamofire.request(url, method: .post, parameters: params, headers: apiHelper.authTokenHeader()).responseJSON { response in
        switch response.result{
        case .success(let data):
            let json = JSON(data)
            
            let status = json["status"].int
            let errorMessage = json["message"].string
            
            if (errorMessage != nil && status != 200)
            {
                logger.message(type: .error, message: "Request failed with error: \(errorMessage)")
                completion(false, "Request failed with error: \(errorMessage)")
                return
            }
            
            currentUser?.emailConfirmed = true
            
            logger.message(type: .information, message: "Confirm email succeeded.")
            completion(true, nil)
            
        case .failure(let error):
            logger.message(type: .error, message: "Request failed with error: \(error)")
            completion(false, "Request failed with error: \(error)")
        }
    }
}
