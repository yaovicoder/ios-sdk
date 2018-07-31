//
//  GetNANJRateRequest.swift
//  APIKit
//
//  Created by MinaWorks on 7/26/18.
//

import UIKit
import APIKit

class NANJRateRequest: Request {
    typealias Response = Double?
    
    var baseURL: URL {
        return URL(string: NANJConfig.nanjServer)!
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var headerFields: [String : String] {
        return [
            "Client-ID" : NANJConfig.nanjWalletAppId,
            "Secret-Key" : NANJConfig.nanjWalletSecretKey
        ]
    }
    
    var path: String {
        return "/coins/markets"
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Double? {
        guard let dict = object as? NSDictionary, let data = dict["data"] as? NSDictionary,
            let current_price = data["current_price"] as? Double else { return nil }
        return current_price
    }
}
