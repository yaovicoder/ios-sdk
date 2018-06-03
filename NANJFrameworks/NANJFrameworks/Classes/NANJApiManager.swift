//
//  NANJApiManager.swift
//  NANJFrameworks
//
//  Created by Long Lee on 6/3/18.
//

import UIKit
import APIKit

class NANJApiManager: NSObject {
    
    static let shared: NANJApiManager = NANJApiManager()
    
    func createNANJWallet(params: NSDictionary, completion: @escaping (String?) -> Void ) {
        let request: CreateNANJWalletRequest = CreateNANJWalletRequest(dict: params)
        Session.send(request) { result in
            switch result {
            case .success(let txHash):
                completion("Create success ::D")
                break
            case .failure(let error):
                completion("Get Nonce error :((((")
                print(error)
                break
            }
        }
    }
    
}
