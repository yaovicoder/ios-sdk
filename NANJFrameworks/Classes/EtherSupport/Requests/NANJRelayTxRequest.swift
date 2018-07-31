//
//  NANJRelayTxRequest.swift
//  NANJFrameworks
//
//  Created by MinaWorks on 6/3/18.
//

import UIKit
import APIKit

class NANJRelayTxRequest: Request {
    typealias Response = (String?, String?) //TxHash, Error message
    
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
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> (String?, String?) {
        print(object)
        guard let dict = object as? Dictionary<String, Any> else {
            return (nil, "Can't read response from server.")
        }
        if let txHash: String = dict["txHash"] as? String {
            return (txHash, nil)
        }
        //Message from server
        if let __message = dict["message"] as? String {
            return (nil, __message)
        }
        return (nil, "Can't read response from server.")
    }
}
