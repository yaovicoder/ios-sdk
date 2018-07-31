//
//  RelayNonceRequest.swift
//  APIKit
//
//  Created by Nguyen Tuan on 7/28/18.
//

import Foundation
import BigInt
import APIKit

struct RelayNonceRequest: Request {
    typealias Response = BigUInt
    
    private var _address: String?
    
    init(_ senderAddress: String) {
        _address = senderAddress
    }
    var baseURL: URL {
        return URL(string: NANJConfig.nanjServer)!
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        return "/relayNonce"
    }
    
    
    var headerFields: [String : String] {
        return [
            "Client-ID" : NANJConfig.nanjWalletAppId,
            "Secret-Key" : NANJConfig.nanjWalletSecretKey,
            "Cache-Control": "no-cache"
        ]
    }
    
    
    var queryParameters: [String : Any]? {
        return [
            "sender" : _address ?? "",
            "ts" : (Date().toMillis())!
        ]
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> BigUInt {
        guard let dict = object as? Dictionary<String, Any> else {
            return 0
        }
     
        if let status:Int = dict["statusCode"] as? Int {
            if status == 200 {
                //Success
                if let nonce = dict["data"] {
                    print("Relay Nonce: \(nonce)")
                    let bigIntNonce = BigUInt.init("\(nonce)")
                    return bigIntNonce!
                }
            }
            else {
                //Error
                return 0
            }
        }
        return 0
    }
    
//    func intercept(urlRequest: URLRequest) throws -> URLRequest {
//        urlRequest.
//    }
}

extension Date {
    func toMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
