//
//  KeychainAccess.swift
//  Jupp
//
//  Created by dasdom on 16.08.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import Foundation

public class KeychainAccess {
    private class func secClassGenericPassword() -> String {
        return NSString(format: kSecClassGenericPassword) as String
    }
    
    private class func secClass() -> String {
        return NSString(format: kSecClass) as String
    }
    
    private class func secAttrService() -> String {
        return NSString(format: kSecAttrService) as String
    }
    
    private class func secAttrAccount() -> String {
        return NSString(format: kSecAttrAccount) as String
    }
    
    private class func secValueData() -> String {
        return NSString(format: kSecValueData) as String
    }
    
    private class func secReturnData() -> String {
        return NSString(format: kSecReturnData) as String
    }
    
    public class func setPassword(_ password: String, account: String, service: String = "keyChainDefaultService") {
        let secret: Data = password.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        let objects: [Any] = [secClassGenericPassword(), service, account, secret]
        
        let keys: [NSCopying] = [secClass() as NSCopying, secAttrService() as NSCopying, secAttrAccount() as NSCopying, secValueData() as NSCopying]
        
        let query = NSDictionary(objects: objects, forKeys: keys)
        
        SecItemDelete(query as CFDictionary)
        
        SecItemAdd(query as CFDictionary, nil)
    }
    
    public class func passwordForAccount(_ account: String, service: String = "keyChainDefaultService") -> String? {
        let queryAttributes = NSDictionary(objects: [secClassGenericPassword(), service, account, true], forKeys: [secClass() as NSCopying, secAttrService() as NSCopying, secAttrAccount() as NSCopying, secReturnData() as NSCopying])
        
        var dataTypeRef : AnyObject?
        let status = SecItemCopyMatching(queryAttributes, &dataTypeRef)
        
        if dataTypeRef == nil {
            return nil
        }
        var retrievedData: Data?
        if (status == errSecSuccess) {
            retrievedData = dataTypeRef as? Data
        }
        else{
            print("Error retreiving password from keychain.")
        }
        //let retrievedData : NSData = dataTypeRef!.takeRetainedValue() as! NSData
        let password = NSString(data: retrievedData!, encoding: String.Encoding.utf8.rawValue)
        
        return (password as! String)
    }
    
    public class func deletePasswordForAccount(_ password: String, account: String, service: String = "keyChainDefaultService") {
        let secret: Data = password.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        let objects: [Any] = [secClassGenericPassword(), service, account, secret]
        
        let keys: [NSCopying] = [secClass() as NSCopying, secAttrService() as NSCopying, secAttrAccount() as NSCopying, secValueData() as NSCopying]
        
        let query = NSDictionary(objects: objects, forKeys: keys)
        
        SecItemDelete(query as CFDictionary)
    }
}
