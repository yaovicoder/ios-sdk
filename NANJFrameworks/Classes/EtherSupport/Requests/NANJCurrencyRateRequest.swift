//
//  NANJCurrencyRateRequest.swift
//  NANJFrameworks
//
//  Created by Minaworks on 9/26/18.
//

import UIKit
import APIKit

class NANJCurrencyRateRequest: Request {
    typealias Response = Double?
    
    fileprivate var currency: String
    
    init(currency: String) {
        self.currency = currency
    }
    
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
        let erc20 = NANJWalletManager.shared.getCurrentERC20Support()?.getName().lowercased() ?? "nanjcoin"
        return "/coin/\(erc20)/currency/\(self.currency)"
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Double? {
        guard let dict = object as? NSDictionary, let data = dict["data"] as? NSDictionary,
            let current_price = data["current_price"] as? Double else { return nil }
        return current_price
    }
}
