//
//  GetUSDToYENRequest.swift
//  NANJFrameworks
//
//  Created by MinaWorks on 6/5/18.
//

import UIKit
import APIKit

class GetUSDToYENRequest: Request {
    
    typealias Response = Double?
    
    var baseURL: URL {
        return URL(string: "http://free.currencyconverterapi.com/api/v5")!
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        return "/convert"
    }
    
    var parameters: Any? {
        return [
            "q" : "USD_JPY",
            "compact" : "y"
        ]
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Double? {
        guard let dict = object as? Dictionary<String, Any>,
            let data = dict["USD_JPY"] as? Dictionary<String, Any>,
            let yen = data["val"] as? Double
            else {
            return nil
        }
        return yen
    }
}
