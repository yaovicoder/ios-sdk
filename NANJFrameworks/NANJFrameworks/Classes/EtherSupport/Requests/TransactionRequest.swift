//
//  TransactionRequest.swift
//  NANJFrameworks
//
//  Created by Long Lee on 5/10/18.
//

import Foundation
import APIKit

struct TransactionRequest: Request {
    typealias Response = [NANJTransaction]?
    private var _address: String?
    private var _page: Int?
    private var _offset: Int?
    
    init(_ address: String, _ page: Int, _ offset: Int) {
        _address = address
        _page = page
        _offset = offset
    }
    var baseURL: URL {
        return URL(string: NANJConfig.apiServerTransaction)!
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
            "startblock" : "0",
            "endblock" : "999999999",
            "sort" : "desc",
            "apikey" : NANJConfig.apiServerTransactionKey,
            "page" : _page ?? 1,
            "offset" : _offset ?? 20
        ]
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> [NANJTransaction]? {
        guard let dict = object as? Dictionary<String, Any> else {
            return nil
        }
        print(dict)
        //
        let status: Int = (Int)(dict["status"] as? String ?? "0")!
        if status == 1 {
            //Success
            if let result: Array<Dictionary<String, Any>> = dict["result"] as? Array<Dictionary<String, Any>> {
                return result.map({ dict -> NANJTransaction in
                    return NANJTransaction(transaction: dict)
                })
            }
        } else {
            //Error
            return []
        }
        return nil
    }
}
