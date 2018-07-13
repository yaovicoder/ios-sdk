//
//  CreateNANJWalletRequest.swift
//  NANJFrameworks
//
//  Created by Long Lee on 6/3/18.
//

import UIKit
import APIKit

class CreateNANJWalletRequest: Request {
    typealias Response = String?
    
    var dict: NSDictionary!
    
    init(dict: NSDictionary) {
        self.dict = dict
    }
    
    var baseURL: URL {
        return URL(string: NANJConfig.NANJ_SERVER)!
    }
    
    var method: HTTPMethod {
        return .post
    }
    
    var headerFields: [String : String] {
        return [
            "Client-ID" : NANJConfig.NANJWALLET_APP_ID,
            "Secret-Key" : NANJConfig.NANJWALLET_SECRET_KEY
        ]
    }
    
    var path: String {
        return "/relayTx"
    }
    
    var bodyParameters: BodyParameters? {
        return JSONBodyParameters.init(JSONObject: dict)
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> String? {
        guard let dict = object as? Dictionary<String, Any> else {
            return nil
        }
        if let txHash: String = dict["txHash"] as? String {
            return txHash
        }
        return nil
    }
}
