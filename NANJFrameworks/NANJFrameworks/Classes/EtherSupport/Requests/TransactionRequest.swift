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
    private var _address: String?
    private var _page: Int?
    private var _offset: Int?
    
    init(_ address: String, _ page: Int, _ offset: Int) {
        _address = address
        _page = page
        _offset = offset
    }
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
            "address" : _address ?? "",
            "startblock" : 0,
            "endblock" : "999999999",
            "sort" : "asc",
            "apikey" : "WR5V2SAEJSPVVYPKJRFQI1HVBWT22T5XUJ",
            "page" : _page ?? 1,
            "offset" : _offset ?? 1
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
