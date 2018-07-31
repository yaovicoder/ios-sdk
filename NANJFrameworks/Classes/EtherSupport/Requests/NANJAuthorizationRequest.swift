//
//  GetAuthoriseRequest.swift
//  APIKit
//
//  Created by MinaWorks on 7/13/18.
//

import UIKit
import APIKit

class NANJAuthorizationRequest: Request {
    typealias Response = NSDictionary?
    
    var baseURL: URL {
        return URL(string: NANJConfig.nanjServer)!
    }
    
    var method: HTTPMethod {
        return .post
    }
    
    var headerFields: [String : String] {
        return [
            "Client-ID" : NANJConfig.nanjWalletAppId,
            "Secret-Key" : NANJConfig.nanjWalletSecretKey
        ]
    }
    
    var path: String {
        return "/authorise"
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> NSDictionary? {
        guard let dict = object as? NSDictionary else { return nil }
        return dict
    }
}
