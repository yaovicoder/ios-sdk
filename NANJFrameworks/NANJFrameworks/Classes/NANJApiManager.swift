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
                completion(txHash)
                break
            case .failure(let error):
                completion(nil)
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
            batch: BatchFactory().create(CallRequest(to: NANJConfig.META_NANJCOIN_MANAGER, data: encoded.hexEncoded))
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
    
    func getNANJRate(completion: @escaping(Double?)-> Void) {
        let requestNANJ = GetNANJToUSDRequest()
        let requestYEN = GetUSDToYENRequest()
        Session.send(requestNANJ) { result in
            switch result {
            case .success(let object):
                if let nanjRate = object {
                    Session.send(requestYEN) { resultYEN in
                        switch resultYEN {
                        case .success(let objectYEN):
                            if let usdToYEN = objectYEN {
                                completion(nanjRate*usdToYEN)
                            } else {
                                completion(nil)
                            }
                        case .failure(_):
                            completion(nil)
                        }
                    }
                } else {
                    completion(nil)
                }
            case .failure(_):
                completion(nil)
            }
        }
    }
    
}
