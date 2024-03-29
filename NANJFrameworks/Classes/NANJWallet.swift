//
//  NANJWallet.swift
//  NANJFramworks
//
//  Created by MinaWorks on 4/15/18.
//

import UIKit
import TrustCore
import TrustKeystore
import BigInt
import JSONRPCKit
import APIKit
import CryptoSwift

@objc public protocol NANJWalletDelegate {
    
    /// Callback Transaction when send NANJ completed.
    ///
    /// - Parameter transaction: transaction success.
    @objc optional func didSendNANJCompleted(transaction: NANJTransaction?)
    
    
    /// Callback Transaction when send NANJ error
    ///
    /// - Parameter error: transaction fail
    @objc optional func didSendNANJError(error: String)
    
    /// Callback list Transaction when get completed.
    ///
    /// - Parameter transactions: list Transaction.
    @objc optional func didGetTransactionList(transactions: Array<NANJTransaction>?)
    
    /// Callback amount NANJ of wallet.
    ///
    /// - Parameters:
    ///    - wallet: wallet get amount.
    ///    - amount: current amount of NANJ
    ///    - error: error when get not complete.
    @objc optional func didGetAmountNANJ(wallet: NANJWallet, amount: Double, error: Error?)
    
    /// Callback amount ETH of wallet.
    ///
    /// - Parameters:
    ///    - wallet: wallet get amount.
    ///    - amount: current amount of ETH
    ///    - error: error when get not complete.
    @objc optional func didGetAmountETH(wallet: NANJWallet, amount: String, error: Error?)
}

public class NANJWallet: NSObject {
    
    public weak var delegate: NANJWalletDelegate?
    
    public var address: String = ""
    public var addressETH: String = ""
    public var name: String?
    
    var amountNANJ: Double = 0.0
    var amountETH: Double = 0.0
    
    //
    fileprivate var etherWallet: Wallet?
    
    /// Send NAJI coins to other wallet
    ///
    /// - Parameters:
    ///   - address: wallet target
    ///   - amount: the number of coin that you want to transfer
    
    public func sendNANJ(toAddress address: String, amount: String, message: String = "") {
        
        //STEP1: Data Tranfer
        if amount.doubleValue < Double(NANJWalletManager.shared.getMinimumAmount()) {
            self.delegate?.didSendNANJError?(error: "Amount must be greater than \(NANJWalletManager.shared.getMinimumAmount()).")
            return
        }
        guard let address = Address(string: address.trimmed) else {
            self.delegate?.didSendNANJError!(error: "Address invaild")
            return
        }
        guard let value = EtherNumberFormatter.full.number(from: amount, decimals: NANJConfig.decimals) else {
            self.delegate?.didSendNANJError!(error: "Amount invaild")
            return
        }
        
        //Data Transfer
        let encoderTransfer = ABIEncoder()
        let functionTransfer = Function(name: "transfer", parameters: [.address, .uint(bits: 256), .dynamicBytes])
        try! encoderTransfer.encode(function: functionTransfer, arguments: [address, value.magnitude, message.data(using: .utf8)!])
        let sendEncoded = encoderTransfer.data
        
        //Data forwardTo
        //Address(addressETH), Address(nanjAddress), Address(SMART_CONTRACT_ADDRESS),
        guard let addressNANJ = Address(string: self.address),
              let addressETH = self.etherWallet?.address,
              let addressNANJCOIN = Address(string: NANJConfig.smartContractAddress) else {return}
        let valueZero: BigUInt = {
            return 0
        }()
        
        let functionForward = Function(name: "forwardTo",
                                       parameters: [.address, .address, .address, .uint(bits: 256), .dynamicBytes, .bytes(32)])
        let encoder = ABIEncoder()
        
        let appHash: Array<UInt8> = Array<UInt8>(hex: NANJConfig.appHash)
        
        try! encoder.encode(function: functionForward, arguments: [addressETH, addressNANJ, addressNANJCOIN, valueZero, sendEncoded, Data(bytes: appHash)])
        let forwardEncoded = encoder.data
        
        //   Sign forwardEncoded data
        //--- NANJ WALLET MANAGER
        guard let currentAccount = EtherKeystore.shared.getAccount(for: addressETH) else {
            self.delegate?.didSendNANJError!(error: "Get Account error")
            return
        }
        var _privateKey: String = ""
            //Get Private key
        do {
            let result = try EtherKeystore.shared.exportPrivateKey(account: currentAccount).dematerialize()
            _privateKey = result.hexString
        } catch {
            self.delegate?.didSendNANJError!(error: "Get Private key error")
            return
        }
        
        //  CREATE TX_HASH INPUT WITH TX_RELAY, WALLET OWNER,
        //              PAD, NANJCOIN ADDRESS        
        self.retrieveRelayNonce { (relayNonce, error) in
            if let nonceError =  error  {
                self.delegate?.didSendNANJError?(error: nonceError.localizedDescription)
                return
            }
            
            let pad = relayNonce.serialize().toHexString().paddingStart(64, with: "0")
            
            let txHashInput = String(format: "0x1900%@%@%@%@%@",
                                     NANJConfig.txRelayAddress.drop0x,
                                     NANJConfig.WALLET_OWNER.drop0x,
                                     pad,
                                     NANJConfig.metaNanjCoinManager.drop0x,
                                     forwardEncoded.hexEncoded.drop0x
            )
            
            // SIGN TX_HASH_INPUT
            let __bytesSign = Array<UInt8>(hex: txHashInput)
            let __hashSign = Digest.sha3(__bytesSign, variant: .keccak256)
            let __txHashSignData = EtherKeystore.shared.signHash(Data(bytes: __hashSign), for: currentAccount)
            guard let __txHashSign = __txHashSignData.value  else {
                self.delegate?.didSendNANJError!(error: "Sign data error")
                return
            }
            
            let dataR = __txHashSign[..<32]
            let signR = dataR.hexEncoded
            
            let dataS = __txHashSign[32..<64]
            let signS = dataS.hexEncoded
            
            let signV = __txHashSign[64]// + 27
            
            //STEP4: SHA3 TX_HASH
            let __bytes = Array<UInt8>(hex: txHashInput)
            let __hash = Digest.sha3(__bytes, variant: .keccak256)
            let txHash = __hash.toHexString().add0x
            
            //STEP5: CREATE JSON DATA
            let para:NSMutableDictionary = NSMutableDictionary()
            para.setValue(forwardEncoded.hexEncoded, forKey: "data")
            para.setValue(NANJConfig.metaNanjCoinManager, forKey: "dest")
            para.setValue(txHash, forKey: "hash")
            para.setValue(NANJConfig.PAD, forKey: "nonce")
            para.setValue(signR, forKey: "r")
            para.setValue(signS, forKey: "s")
            para.setValue(signV, forKey: "v")
            
            //STEP6: PUSH TO API CREATE
            NANJApiManager.shared.postNANJRelayTx(params: para) {[weak self] (txHash, error) in
                guard let `self` = self else {return}
                if txHash == nil || txHash?.count == 0 {
                    self.delegate?.didSendNANJError?(error: error ?? "Send NANJ failed.")
                } else {
                    self.delegate?.didSendNANJCompleted?(transaction: NANJTransaction(transaction: ["hash" : txHash!]))
                }
            }
        }
    }
    
    /// Get your NAJI amount
    ///
    public func getAmountNANJ() {
        guard let address = Address(string: self.address), let contract = Address(string: NANJConfig.smartContractAddress) else { return }
        TokensBalanceService().getBalance(for: address, contract: contract) {result in
            //guard let `self` = self else {return}
            guard let __value = result.value else {
                self.delegate?.didGetAmountNANJ?(wallet: self, amount: 0.0, error: result.error)
                return
            }
            if let amount: Decimal = EtherNumberFormatter.full.decimal(from: __value, decimals: NANJConfig.decimals) {
                self.delegate?.didGetAmountNANJ?(wallet: self, amount: amount.description.doubleValue, error: nil)
            }
        }
    }
    
    /// Edit your wallet name. It only store in your device.
    ///
    /// - Parameter name: a new name you want.
    /// - Returns: if edit successful return true and opposite.
    public func editName(name: String) -> Bool{
        return false
    }
    
    /// After get transactions on async function
    /// return list transactions in callback delegate.
    public func getTransactionList(page: Int, offset: Int) {
        //Return by delegate
        //Ex
        self.exeGetTransaction(page: page, offset: offset)
    }
    
    
    /// Get URL Wallet on Etherscan
    ///
    /// - Returns: URL Ether
    public func getURLOnEtherscan() -> URL? {
        
        return nil
    }
    
    public func enableWallet() {
        EtherKeystore.shared.recentlyUsedWallet = self.etherWallet
    }
    
    //MARK: - Support method
    func addEtherWallet(wallet: Wallet) {
        self.etherWallet = wallet
    }
    
    func getEtherWallet() -> Wallet? {
        return self.etherWallet
    }
}

extension NANJWallet {
    fileprivate func exeGetTransaction(page: Int, offset: Int) {
        let request: TransactionRequest = TransactionRequest(self.address, page, offset)
        Session.send(request) {[weak self] result in
            guard let `self` = self else {return}
            switch result {
            case .success(let transactions):
                self.delegate?.didGetTransactionList?(transactions: transactions)
                break
            case .failure(let error):
                self.delegate?.didGetTransactionList?(transactions: nil)
                print(error)
                break
            }
        }
    }
}

extension NANJWallet {
    fileprivate func retrieveRelayNonce(completion: @escaping(BigUInt, Error?)-> Void) {
        let request: RelayNonceRequest = RelayNonceRequest(self.addressETH)
        Session.shared.send(request) { result in
            switch result {
            case .success(let nonce):
                completion(nonce,nil)
                break
            case .failure(let error):
                completion(0, error)
                print(error)
                break
            }
        }
    }
}
