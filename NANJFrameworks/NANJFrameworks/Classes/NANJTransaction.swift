//
//  NANJTransaction.swift
//  NANJFramworks
//
//  Created by Long Lee on 4/15/18.
//

import UIKit

public class NANJTransaction: NSObject {
    var hashString: String! = ""
    var status: String! = ""
    var blockHeight: Any?
    var timeStamp: Date?
    var from: String?
    var to: String?
    var amount: Double = 0.0
    var fee: Double = 0.0
    
//    init(object: Any) throws {
//        guard let dictionary = object as? [String: Any] else {
//            return
//        }
////            let rateDictionary = dictionary["rate"] as? [String: Any],
////            let limit = rateDictionary["limit"] as? Int,
////            let remaining = rateDictionary["remaining"] as? Int else {
////                throw ResponseError.unexpectedObject(object)
////            throw
//    }
    
    public func getURLOnEtherscan() -> URL? {
        
        return nil
    }
}
