//
//  GetNANJToUSDRequest.swift
//  NANJFrameworks
//
//  Created by MinaWorks on 6/5/18.
//

import UIKit
import APIKit

class GetNANJToUSDRequest: Request {
    typealias Response = Double?
    
    var baseURL: URL {
        return URL(string: "https://api.coinmarketcap.com/v2/ticker/1")!
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        return "/"
    }
    
    var parameters: Any? {
        return ["convert" : "NANJ"]
    }
    
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Double? {
        guard let dict = object as? Dictionary<String, Any>,
            let data = dict["data"] as? Dictionary<String, Any>,
            let quotes = data["quotes"] as? Dictionary<String, Any>,
            let usd = quotes["USD"] as? Dictionary<String, Any>,
            let usdPrice = usd["price"] as? Double,
            let nanj = quotes["NANJ"] as? Dictionary<String, Any>,
            let nanjPrice = nanj["price"] as? Double
            else {
                return nil
        }
        return usdPrice/nanjPrice
    }
}
