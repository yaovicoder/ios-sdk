//
//  GetAuthoriseRequest.swift
//  APIKit
//
//  Created by MinaWorks on 7/13/18.
//

import UIKit
import APIKit

class GetAuthoriseRequest: Request {
    typealias Response = NSDictionary?
    
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
        return "/authorise"
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> NSDictionary? {
        guard let dict = object as? NSDictionary else { return nil }
        return dict
    }
}
