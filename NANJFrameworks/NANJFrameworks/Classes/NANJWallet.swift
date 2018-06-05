//
//  NANJWallet.swift
//  NANJFramworks
//
//  Created by Long Lee on 4/15/18.
//

import UIKit
import TrustCore
import TrustKeystore
import BigInt
import JSONRPCKit
import APIKit

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
    
    public func sendNANJ(toAddress address: String, amount: String) {
        //Step 1: Create/Encode function transfer
        //Step 2: Create/Encode function forwardTo
        //Step 3: Sign data forwardTo
        //Step 4: Push API with signature
        
        //STEP1: Data Tranfer
        guard let address = Address(string: address.trimmed) else {
            print("Address error")
            self.delegate?.didSendNANJError!(error: "Address invaild")
            return
        }
        guard let value = EtherNumberFormatter.full.number(from: amount, decimals: NANJContract.decimals) else {
            print("Amount error")
            self.delegate?.didSendNANJError!(error: "Amount invaild")
            return
        }
        let sendEncoded = ERC20Encoder.encodeTransfer(to: address, tokens: value.magnitude)
        
        //STEP2: Data forwardTo
        //        Address(addressETH), Address(nanjAddress), Address(NANJCOIN_ADDRESS),
        guard let addressNANJ = Address(string: self.address),
              let addressETH = self.etherWallet?.address,
              let addressNANJCOIN = Address(string: NANJConfig.NANJCOIN_ADDRESS) else { return}
        let valueZero: BigUInt = {
            return 0
        }()
        let functionForward = Function(name: "forwardTo",
                                parameters: [.address, .address, .address, .uint(bits: 256), .dynamicBytes])
        let encoder = ABIEncoder()
        try! encoder.encode(function: functionForward, arguments: [addressETH, addressNANJ, addressNANJCOIN, valueZero, sendEncoded])
        //print(encoder.data.hexEncoded)
        let forwardEncoded = encoder.data
        
        //STEP3: Sign forwardEncoded data
        //--- NANJ WALLET MANAGER
        
        var _privateKey: String = ""
            //Get Private key
        if let account = EtherKeystore.shared.getAccount(for: addressETH) {
            do {
                let result = try EtherKeystore.shared.exportPrivateKey(account: account).dematerialize()
                _privateKey = result.hexString
            } catch {
                //Error
            }
        }

        //STEP2: SIGN FUNCTION ENCODE
        print("* * * * * * * * * * * * STEP 2 * * * * * * * * * * * *")
        let signature = EthereumCrypto.sign(hash: forwardEncoded, privateKey: _privateKey.data(using: .utf8)!)
        
        let dataR = signature[..<32]
        let signR = dataR.hexEncoded
        print("R: ", signR)
        
        let dataS = signature[32..<64]
        let signS = dataS.hexEncoded
        print("S: ", signS)
        
        let signV = signature[64] + 27
        print("V: ", signV)
        
        print("\n")
        
        //STEP3: CREATE TX_HASH INPUT WITH TX_RELAY, WALLET OWNER,
        //              PAD, NANJCOIN ADDRESS
        print("* * * * * * * * * * * * STEP 3 * * * * * * * * * * * *")
        let txHashInput = String(format: "0x1900%@%@%@%@%@",
                                 NANJConfig.TX_RELAY_ADDRESS.drop0x,
                                 NANJConfig.WALLET_OWNER.drop0x,
                                 NANJConfig.PAD,
                                 NANJConfig.META_NANJCOIN_MANAGER.drop0x,
                                 forwardEncoded.hexEncoded.drop0x
        )
        print("Hash Input: ", txHashInput)
        print("\n")
        
        //STEP4: SHA3 TX_HASH
        print("* * * * * * * * * * * * STEP 4 * * * * * * * * * * * *")
        let txHashData = txHashInput.data(using: .utf8)?.sha3(.keccak256)
        let txHash: String = txHashData?.hexEncoded  ?? "TX HASH ERROR"
        print("txHash: ", txHash)
        print("\n")
        
        //STEP5: CREATE JSON DATA
        print("* * * * * * * * * * * * STEP 5 * * * * * * * * * * * *")
        let para:NSMutableDictionary = NSMutableDictionary()
        para.setValue(forwardEncoded.hexEncoded, forKey: "data")
        para.setValue(NANJConfig.META_NANJCOIN_MANAGER, forKey: "dest")
        para.setValue(txHash, forKey: "hash")
        para.setValue(NANJConfig.PAD, forKey: "nonce")
        para.setValue(signR, forKey: "r")
        para.setValue(signS, forKey: "s")
        para.setValue(signV, forKey: "v")
        let jsonData = try! JSONSerialization.data(withJSONObject: para, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)!
        print(jsonString)
        print("\n")
        
        //STEP6: PUSH TO API CREATE https://nanj-demo.herokuapp.com/api/relayTx
        print("* * * * * * * * * * * * STEP 6 * * * * * * * * * * * *")
        NANJApiManager.shared.createNANJWallet(params: para) {[weak self] txHash in
            guard let `self` = self else {return}
            if txHash == nil || txHash?.count == 0 {
                self.delegate?.didSendNANJError?(error: "Send NANJ failed.")
            } else {
                self.delegate?.didSendNANJCompleted?(transaction: NANJTransaction(transaction: [:]))
            }
        }
    }
    
    /// Get your NAJI amount
    ///
    public func getAmountNANJ() {
        let contract: Address? = Address(string: NANJContract.address)
        guard let address = Address(string: self.address), let __contract = contract else { return }
        TokensBalanceService().getBalance(for: address, contract: __contract) {result in
            //guard let `self` = self else {return}
            guard let __value = result.value else {
                self.delegate?.didGetAmountNANJ?(wallet: self, amount: 0.0, error: result.error)
                return
            }
            //let amount = EtherNumberFormatter.full.string(from: __value, decimals: NANJContract.decimals)
            
            if let amount: Decimal = EtherNumberFormatter.full.decimal(from: __value, decimals: NANJContract.decimals) {
                print(amount.description)
                self.delegate?.didGetAmountNANJ?(wallet: self, amount: amount.description.doubleValue, error: nil)
            }
            
            //self.delegate?.didGetAmountNANJ?(wallet: self, amount: amount, error: nil)
            print(result.value ?? "")
            print("Get NANJ value complete")
        }
    }
    
    /// Get your ETH amount
    ///
    public func getAmountETH() {
        guard let address = self.etherWallet?.address else { return }
        TokensBalanceService().getEthBalance(for: address) { result in
            guard let __value = result.value else {
                self.delegate?.didGetAmountETH?(wallet: self, amount: "0.0", error: result.error)
                return
            }
            self.delegate?.didGetAmountETH?(wallet: self, amount: __value.amountFull, error: nil)
            print(result.value ?? "")
            print("Get ETH value complete")
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
                print("Get Nonce error")
                print(error)
                break
            }
        }

    }
}
