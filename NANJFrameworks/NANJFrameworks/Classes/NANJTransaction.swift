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
    
    public func getURLOnEtherscan() -> URL? {
        
        return nil
    }
}
