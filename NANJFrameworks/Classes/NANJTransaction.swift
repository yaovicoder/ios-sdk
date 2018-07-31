//
//  NANJTransaction.swift
//  NANJFramworks
//
//  Created by MinaWorks on 4/15/18.
//

import UIKit
import BigInt
import TrustCore

public class NANJTransaction: NSObject {
    public let id: UInt?
    public let txHash: String?
    public let status: Int?
    public let from: String?
    public let to: String?
    public let value: String?
    public let message: String?
    public let txFee: String?
    public let timestamp: UInt?
    public let tokenSymbol: String?
    
    init(transaction: Dictionary<String, Any>) {
        let id = transaction["id"] as? UInt ?? 0
        let txHash = transaction["TxHash"] as? String ?? ""
        let status = transaction["status"] as? Int ?? 0
        let from = transaction["from"] as? String ?? "0"
        let to = transaction["to"] as? String ?? "0"
        let value = transaction["value"] as? String ?? "0"
        let message = transaction["message"] as? String ?? ""
        let txFee = transaction["tx_fee"] as? String ?? "0"
        let timestamp = transaction["time_stamp"] as? UInt
        
        self.id = id
        self.txHash = txHash
        self.from = from
        self.to = to
        self.status = status
        self.message = message
        self.txFee = EtherNumberFormatter.full.string(from: BigInt.init(txFee) ?? 0, decimals: NANJConfig.decimals)
        self.value = EtherNumberFormatter.full.string(from: BigInt.init(value) ?? 0, decimals: NANJConfig.decimals)
        self.timestamp = timestamp
        self.tokenSymbol = "NANJ"
    }
    
    public func getURLOnEtherscan() -> URL? {
        if let txHash = self.txHash {
            return URL(string: String(format: "%@/tx/%@", NANJConfig.rpcServer.rpcEtherScanURL.absoluteString, txHash))
        }
        return nil
    }
}
