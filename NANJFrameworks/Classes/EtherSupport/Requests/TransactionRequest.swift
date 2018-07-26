//
//  TransactionRequest.swift
//  NANJFrameworks
//
//  Created by MinaWorks on 5/10/18.
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
        return URL(string: NANJConfig.NANJ_SERVER)!
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        return "/tx/list/\(String(describing: _address!))"
    }
    
    var headerFields: [String : String] {
        return [
            "Client-ID" : NANJConfig.NANJWALLET_APP_ID,
            "Secret-Key" : NANJConfig.NANJWALLET_SECRET_KEY
        ]
    }
    
    
    var queryParameters: [String : Any]? {
        return [
            "order_by" : "desc",
            "page" : _page ?? 1,
            "limit" : _offset ?? 20
        ]
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> [NANJTransaction]? {
        guard let dict = object as? Dictionary<String, Any> else {
            return nil
        }
        print(dict)
        //
        if let status:Int = dict["statusCode"] as? Int {
            if status == 200 {
                //Success
                if let data: Dictionary<String, Any> = dict["data"] as? Dictionary<String, Any>{
                    if let items: Array<Dictionary<String, Any>> = data["items"] as? Array<Dictionary<String, Any>> {
                        return items.map({ dict -> NANJTransaction in
                            return NANJTransaction(transaction: dict)
                        })
                    }
                }
            }
            else {
                //Error
                return []
            }
        }
        return nil
    }
}
