//
//  NANJApiManager.swift
//  NANJFrameworks
//
//  Created by MinaWorks on 6/3/18.
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
    
    func postNANJRelayTx(params: NSDictionary, completion: @escaping (String?, String?) -> Void ) {
        let request: NANJRelayTxRequest = NANJRelayTxRequest(dict: params)
        Session.send(request) { result in
            switch result {
            case .success(let (txHash, error)):
                completion(txHash, error)
                break
            case .failure(let error):
                completion(nil, error.localizedDescription)
                break
            }
        }
    }
    
    func getNANJAdress(ethAdress: String, completion: @escaping(String?)-> Void) {
        guard let address = Address(eip55: ethAdress) else {
            completion("Get NANJ Adress failed.")
            return
        }
        let function = Function(name: "getWallet", parameters: [.address])
        let encoder = ABIEncoder()
        try! encoder.encode(function: function, arguments: [address])
        let encoded =  encoder.data
        
        let request = EtherServiceRequest(
            batch: BatchFactory().create(CallRequest(to: NANJConfig.metaNanjCoinManager, data: encoded.hexEncoded))
        )
        Session.send(request) { result in
            switch result {
            case .success(let object):
                completion(object)
            case .failure(let error):
                NSLog("Error \(error)")
                completion(nil)
            }
        }
    }
    
    func getNANJRate(completion: @escaping(Double?)-> Void) {
        let requestNANJ = NANJRateRequest()
        Session.send(requestNANJ) { result in
            switch result {
            case .success(let object):
                if let nanjRate = object {
                    completion(nanjRate)
                } else {
                    completion(nil)
                }
            case .failure(_):
                completion(nil)
            }
        }
    }
    
}
