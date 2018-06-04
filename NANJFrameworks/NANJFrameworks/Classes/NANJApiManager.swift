//
//  NANJApiManager.swift
//  NANJFrameworks
//
//  Created by Long Lee on 6/3/18.
//

import UIKit
import APIKit
import JSONRPCKit
import TrustCore

class NANJApiManager: NSObject {
    
    static let shared: NANJApiManager = NANJApiManager()
    
    private override init() {
        super.init()
        
    }
    
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
    
    func getNANJAdress(ethAdress: String, completion: @escaping(String?)-> Void) {
        guard let address = Address(eip55: ethAdress) else {
            completion("GET Error")
            return
        }
        let function = Function(name: "getWallet", parameters: [.address])
        let encoder = ABIEncoder()
        try! encoder.encode(function: function, arguments: [address])
        let encoded =  encoder.data
        
        let request = EtherServiceRequest(
            batch: BatchFactory().create(CallRequest(to: NANJConfig.NANJCOIN_ADDRESS, data: encoded.hexEncoded))
        )
        Session.send(request) { result in
            switch result {
            case .success(let object):
                print(object)
                completion(object)
            case .failure(let error):
                NSLog("getPrice error \(error)")
                completion(nil)
            }
        }
    }
    
}
