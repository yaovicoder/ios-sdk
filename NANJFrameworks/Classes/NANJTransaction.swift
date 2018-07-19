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
    public let blockHash: String?
    public let blockNumber: String?
    public let from: String?
    public let to: String?
    public let gas: String?
    public let gasUsed: String?
    public let gasPrice: String?
    public let txHash: String?
    public let value: String?
    public let nonce: Int?
    public let confirmations: String?
    public let timeStamp: String?
    public let tokenSymbol: String?
    
    init(transaction: Dictionary<String, Any>) {
        let blockHash = transaction["blockHash"] as? String ?? ""
        let blockNumber = transaction["blockNumber"] as? String ?? ""
        let gas = transaction["gas"] as? String ?? "0"
        let gasUsed = transaction["gasUsed"] as? String ?? "0"
        let gasPrice = transaction["gasPrice"] as? String ?? "0"
        let hash = transaction["hash"] as? String ?? ""
        let value = transaction["value"] as? String ?? "0"
        let nonce = transaction["nonce"] as? String ?? "0"
        let confirmations = transaction["confirmations"] as? String ?? "0"
        let from = transaction["from"] as? String ?? ""
        let to = transaction["to"] as? String ?? ""
        let timeStamp = transaction["timeStamp"] as? String ?? ""
        
        self.blockHash = blockHash
        self.blockNumber = BigInt(blockNumber.drop0x, radix: 16)?.description ?? ""
        self.from = from
        self.to = to
        self.gas = gas//BigInt(gas.drop0x, radix: 16)?.description ?? ""
        self.gasPrice = gasPrice//BigInt(gasPrice.drop0x, radix: 16)?.description ?? ""
        self.gasUsed = gasUsed
        self.txHash = hash
        self.value = EtherNumberFormatter.full.string(from: BigInt.init(value) ?? 0, decimals: NANJConfig.DECIMALS)
        self.nonce = Int(BigInt(nonce.drop0x, radix: 16)?.description ?? "-1") ?? -1
        self.confirmations = confirmations
        self.timeStamp = timeStamp
        self.tokenSymbol = transaction["tokenSymbol"] as? String ?? ""
    }
    
    public func getURLOnEtherscan() -> URL? {
        if let txHash = self.txHash {
            return URL(string: String(format: "%@/tx/%@", NANJConfig.rpcServer.rpcEtherScanURL.absoluteString, txHash))
        }
        return nil
    }
    
    public func getFee() -> String? {
        guard let gasUsed = self.gasUsed, let gasPrice = self.gasPrice else { return nil }
        let bigUsed = (BigInt.init(gasUsed) ?? 0)
        let bigPrice = (BigInt.init(gasPrice) ?? 0)
        let fee: Double = Double(bigUsed) / Double(bigPrice)
        return String(format: "%f", fee)
    }
}
