//
//  TransactionRequest.swift
//  NANJFrameworks
//
//  Created by Long Lee on 5/10/18.
//

import Foundation
import APIKit

struct TransactionRequest: Request {
    typealias Response = [NANJTransaction]
    
    var baseURL: URL {
        return URL(string: NANJConfig.apiServer)!
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        return "/api"
    }
    
    var queryParameters: [String : Any]? {
        return [
            "module" : "account",
            "action" : "tokentx",
            "address" : "0x225358f337d33F9959fAa106800Ac865Eee7d994",
            "startblock" : 0,
            "endblock" : "999999999",
            "sort" : "asc",
            "apikey" : "WR5V2SAEJSPVVYPKJRFQI1HVBWT22T5XUJ",
            "page" : 1,
            "offset" : 3
        ]
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> [NANJTransaction] {
        guard let dictionary = object as? [String: Any] else {
            return [NANJTransaction()]
        }
        print(dictionary)
        return [NANJTransaction()]
    }
}
