//
//  NANJTransaction.swift
//  NANJFramworks
//
//  Created by Long Lee on 4/15/18.
//

import UIKit
import BigInt

public class NANJTransaction: NSObject {
    let blockHash: String?
    let blockNumber: String?
    let from: String?
    let to: String?
    let gas: String?
    let gasPrice: String?
    let txHash: String?
    let value: String?
    let nonce: Int?
    
    init(transaction: Dictionary<String, Any>) {
        let blockHash = transaction["blockHash"] as? String ?? ""
        let blockNumber = transaction["blockNumber"] as? String ?? ""
        let gas = transaction["gas"] as? String ?? "0"
        let gasPrice = transaction["gasPrice"] as? String ?? "0"
        let hash = transaction["hash"] as? String ?? ""
        let value = transaction["value"] as? String ?? "0"
        let nonce = transaction["nonce"] as? String ?? "0"
        let from = transaction["from"] as? String ?? ""
        let to = transaction["to"] as? String ?? ""
        
        self.blockHash = blockHash
        self.blockNumber = BigInt(blockNumber.drop0x, radix: 16)?.description ?? ""
        self.from = from
        self.to = to
        self.gas = BigInt(gas.drop0x, radix: 16)?.description ?? ""
        self.gasPrice = BigInt(gasPrice.drop0x, radix: 16)?.description ?? ""
        self.txHash = hash
        self.value = BigInt(value.drop0x, radix: 16)?.description ?? ""
        self.nonce = Int(BigInt(nonce.drop0x, radix: 16)?.description ?? "-1") ?? -1
    }
    
    public func getURLOnEtherscan() -> URL? {
        
        return nil
    }
}
