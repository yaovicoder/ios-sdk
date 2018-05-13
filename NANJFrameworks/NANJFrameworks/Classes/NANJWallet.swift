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
    @objc optional func didGetAmountNANJ(wallet: NANJWallet, amount: String, error: Error?)
    
    /// Callback amount ETH of wallet.
    ///
    /// - Parameters:
    ///    - wallet: wallet get amount.
    ///    - amount: current amount of ETH
    ///    - error: error when get not complete.
    @objc optional func didGetAmountETH(wallet: NANJWallet, amount: String, error: Error?)
}

public class NANJWallet: NSObject {
    
    public var delegate: NANJWalletDelegate?
    
    public var address: String = ""
    public var name: String?
    
    var amountNANJ: Double = 0.0
    var amountETH: Double = 0.0
    
    //
    fileprivate var etherWallet: Wallet?
    
    /// Send NAJI coins to other wallet
    ///
    /// - Parameters:
    ///   - address: wallet target
    ///   - amount: the number of coin you want to transfer
    public func sendNANJ(toAddress address: String, amount: String) {
        //Step 1: Create UnconfirmTransaction
        //Step 2: Change unconfirm to TransactionConfirm
        //Step 3: Sign transaction
        //Step 4: Use Send signTransaction
        
        //Data Tranfer
        guard let address = Address(string: address.trimmed) else {
            print("Address error")
            self.delegate?.didSendNANJCompleted?(transaction: nil)
            return
        }
        guard let value = EtherNumberFormatter.full.number(from: amount, decimals: NANJContract.decimals) else {
            print("Amount error")
            self.delegate?.didSendNANJCompleted?(transaction: nil)
            return
        }
        let sendEncoded = ERC20Encoder.encodeTransfer(to: address, tokens: value.magnitude)
        
        //Sign Transaction
        guard let currentAddress = self.etherWallet?.address, let currentAccount = EtherKeystore.shared.getAccount(for: currentAddress) else {
            print("Current account not found")
            self.delegate?.didSendNANJCompleted?(transaction: nil)
            return
        }
        
        let valueZero: BigInt = {
            return 0
        }()
        
        let addressToken: Address? = {
            return Address(string: NANJContract.contract)
        }()
        let requestNonce = EtherServiceRequest(batch: BatchFactory().create(GetTransactionCountRequest(
            address: currentAddress.eip55String,
            state: "latest"
        )))
        Session.send(requestNonce) { result in
            switch result {
            case .success(let count):
                do {
                    let signTransaction = SignTransaction(
                        value: valueZero,
                        account: currentAccount,
                        to: addressToken,
                        nonce: BigInt(count),
                        data: sendEncoded,
                        gasPrice: max(NANJWalletManager.shared.chainState.gasPrice ?? GasPriceConfiguration.default, GasPriceConfiguration.min),
                        gasLimit: GasLimitConfiguration.tokenTransfer,
                        chainID: NANJConfig.rpcServer.chainID
                    )
                    //Sign and Send Transaction
                    let signedTransaction = EtherKeystore.shared.signTransaction(signTransaction)
                    switch signedTransaction {
                    case .success(let data):
                        do {
                            let request =
                                EtherServiceRequest(batch: BatchFactory().create(SendRawTransactionRequest(signedTransaction: data.hexEncoded)))
                            Session.send(request) { result in
                                switch result {
                                case .success:
                                    print(data.sha3(.keccak256).hexEncoded)
                                    self.delegate?.didSendNANJCompleted?(transaction: NANJTransaction(transaction: [:]))
                                    break
                                case .failure(let error):
                                    self.delegate?.didSendNANJCompleted?(transaction: nil)
                                    print(error.localizedDescription)
                                    print(result.error ?? "Error")
                                    break
                                }
                            }
                        }
                        break
                    case .failure(let error):
                        self.delegate?.didSendNANJCompleted?(transaction: nil)
                        print("sign transaction error")
                        print(error.errorDescription ?? "Error")
                        break
                    }
                }
                break
            case .failure(let error):
                self.delegate?.didSendNANJCompleted?(transaction: nil)
                print("Get Nonce error")
                print(error)
                break
            }
        }
    }
    
    /// Get your NAJI amount
    ///
    public func getAmountNANJ() {
        let contract: Address? = Address(string: NANJContract.address)
        guard let address = self.etherWallet?.address, let __contract = contract else { return }
        TokensBalanceService().getBalance(for: address, contract: __contract) {result in
            //guard let `self` = self else {return}
            guard let __value = result.value else {
                self.delegate?.didGetAmountNANJ?(wallet: self, amount: "0.0", error: result.error)
                return
            }
            let amount = EtherNumberFormatter.full.string(from: __value, decimals: NANJContract.decimals)
            self.delegate?.didGetAmountNANJ?(wallet: self, amount: amount, error: nil)
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
        Session.send(request) { result in
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
