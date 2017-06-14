//
//  HTTPHelper.swift
//  Selfie
//
//  Created by Subhransu Behera on 18/11/14.
//  Modified by Jason Mitchell 2016.
//  Copyright (c) 2014 subhb.org. All rights reserved.
//

import Foundation
import SwiftyJSON

enum HTTPRequestAuthType {
    case httpBasicAuth
    case httpTokenAuth
}

enum HTTPRequestContentType {
    case httpJsonContent
    case httpMultipartContent
}

let httpHelper = HTTPHelper()

struct HTTPHelperDeprecated {
    static let API_AUTH_NAME = apiHelper.API_AUTH_NAME
    static let API_AUTH_PASSWORD = apiHelper.API_AUTH_PASSWORD
    static let BASE_URL = apiHelper.BASE_URL
    
    func buildRequest(_ path: String!, method: String, authType: HTTPRequestAuthType,
        requestContentType: HTTPRequestContentType = HTTPRequestContentType.httpJsonContent, requestBoundary:String = "") -> NSMutableURLRequest {
            // 1. Create the request URL from path
            let requestURL = URL(string: "\(HTTPHelper.BASE_URL)/\(path!)")
            let request = NSMutableURLRequest(url: requestURL!)
            
            // Set HTTP request method and Content-Type
            request.httpMethod = method
            
            // 2. Set the correct Content-Type for the HTTP Request. This will be multipart/form-data for photo upload request and application/json for other requests in this app
            switch requestContentType {
            case .httpJsonContent:
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            case .httpMultipartContent:
                let contentType = "multipart/form-data; boundary=\(requestBoundary)"
                request.addValue(contentType, forHTTPHeaderField: "Content-Type")
            }
            
            // 3. Set the correct Authorization header.
            switch authType {
            case .httpBasicAuth:
                // Set BASIC authentication header
                let basicAuthString = "\(HTTPHelper.API_AUTH_NAME):\(HTTPHelper.API_AUTH_PASSWORD)"
                let utf8str = basicAuthString.data(using: String.Encoding.utf8)
                let base64EncodedString = utf8str?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                
                request.addValue("Basic \(base64EncodedString!)", forHTTPHeaderField: "Authorization")
            case .httpTokenAuth:
                // Retreieve Auth_Token from Keychain
                if let userToken = KeychainAccess.passwordForAccount("Auth_Token", service: "KeyChainService") as String? {
                    // Set Authorization header
                    request.addValue("Token token=\(userToken)", forHTTPHeaderField: "Authorization")
                }
            }
            
            return request
    }
    
    
    func sendRequest(_ request: URLRequest, completion:@escaping (Data?, Error?) -> Void) -> () {
        // Create a NSURLSession task
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if error != nil {
                DispatchQueue.main.async(execute: { () -> Void in
                    completion(data, error)
                }); return
            }
            
            DispatchQueue.main.async(execute: { () -> Void in
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        completion(data, nil)
                    } else {
                        logger.message(type: .error, message: "HttpResponse from HTTPHelper-sendRequest: \(httpResponse.statusCode)")
                        
                        completion(data, nil)
                    }
                }
            })
        }
        // start the task
        task.resume()
    }
    
    func uploadMediaRequest(_ path: String, data: Data, type: String, sliceID: Int?) -> NSMutableURLRequest {
        let boundary = "---------------------------14737809831466499882746641449"
        let request = buildRequest(path, method: "POST", authType: HTTPRequestAuthType.httpTokenAuth,
            requestContentType:HTTPRequestContentType.httpMultipartContent, requestBoundary:boundary) as NSMutableURLRequest
        
        let bodyParams : NSMutableData = NSMutableData()
        
        // build and format HTTP body with data
        // prepare for multipart form uplaod
        
        let boundaryString = "--\(boundary)\r\n"
        let boundaryData = boundaryString.data(using: String.Encoding.utf8) as Data!
        bodyParams.append(boundaryData!)
        
        // set the parameter name
        let imageMetaData = "Content-Disposition: attachment; name=\"media\"; filename=\"\(currentUser?.username)\"\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)
        bodyParams.append(imageMetaData!)
        
        // set the request content type
        let fileContentType = "Content-Type: application/octet-stream\r\n\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)
        bodyParams.append(fileContentType!)
        
        // add the actual image data
        bodyParams.append(data)
        
        let imageDataEnding = "\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)
        bodyParams.append(imageDataEnding!)
        
        let boundaryData2 = boundaryString.data(using: String.Encoding.utf8) as Data!
        
        bodyParams.append(boundaryData2!)
        
        // pass the media type
        let formData = "Content-Disposition: form-data; name=\"type\"\r\n\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)
        bodyParams.append(formData!)
        
        let formData2 = type.data(using: String.Encoding.utf8, allowLossyConversion: false)
        bodyParams.append(formData2!)
        
        if (sliceID != nil) {
            let closingFormData = "\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)
            bodyParams.append(closingFormData!)
            
            // pass the slice id
            let formDataSlice = "Content-Disposition: form-data; name=\"slice_id\"\r\n\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)
            bodyParams.append(formDataSlice!)
            
            let formData3 = String(sliceID!).data(using: String.Encoding.utf8, allowLossyConversion: false)
            bodyParams.append(formData3!)
        }
        
        let closingFormData = "\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)
        bodyParams.append(closingFormData!)
        
        bodyParams.append(boundaryData!)
        
        let closingData = "--\(boundary)--\r\n"
        let boundaryDataEnd = closingData.data(using: String.Encoding.utf8) as Data!
        
        bodyParams.append(boundaryDataEnd!)
        
        request.httpBody = bodyParams as Data
        return request
    }
    
    func uploadVideoRequest(_ path: String, data: Data, title: String) -> NSMutableURLRequest {
        let boundary = "---------------------------14737809831466499882746641449"
        let request = buildRequest(path, method: "POST", authType: HTTPRequestAuthType.httpTokenAuth,
            requestContentType:HTTPRequestContentType.httpMultipartContent, requestBoundary:boundary) as NSMutableURLRequest
        
        let bodyParams : NSMutableData = NSMutableData()
        
        // build and format HTTP body with data
        // prepare for multipart form uplaod
        
        let boundaryString = "--\(boundary)\r\n"
        let boundaryData = boundaryString.data(using: String.Encoding.utf8) as Data!
        bodyParams.append(boundaryData!)
        
        // set the parameter name
        let imageMeteData = "Content-Disposition: attachment; name=\"image\"; filename=\"photo\"\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)
        bodyParams.append(imageMeteData!)
        
        // set the content type
        let fileContentType = "Content-Type: application/octet-stream\r\n\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)
        bodyParams.append(fileContentType!)
        
        // add the actual image data
        bodyParams.append(data)
        
        let imageDataEnding = "\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)
        bodyParams.append(imageDataEnding!)
        
        //let boundaryString2 = "--\(boundary)\r\n"
        let boundaryData2 = boundaryString.data(using: String.Encoding.utf8) as Data!
        
        bodyParams.append(boundaryData2!)
        
        // pass the caption of the image
        let formData = "Content-Disposition: form-data; name=\"title\"\r\n\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)
        bodyParams.append(formData!)
        
        let formData2 = title.data(using: String.Encoding.utf8, allowLossyConversion: false)
        bodyParams.append(formData2!)
        
        let closingFormData = "\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)
        bodyParams.append(closingFormData!)
        
        let closingData = "--\(boundary)--\r\n"
        let boundaryDataEnd = closingData.data(using: String.Encoding.utf8) as Data!
        
        bodyParams.append(boundaryDataEnd!)
        
        request.httpBody = bodyParams as Data
        return request
    }
    
    func getErrorMessage(_ error: Error) -> String {
        var errorMessage : NSString
        let nsError = error as NSError
        
        // return correct error message
        if nsError.domain == "HTTPHelperError" {
            let userInfo = nsError.userInfo as NSDictionary!
            errorMessage = userInfo?.value(forKey: "message") as! NSString
        } else {
            errorMessage = nsError.description as NSString
        }
        
        return errorMessage as String
    }
}
