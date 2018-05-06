//
//  NANJWallet.swift
//  NANJFramworks
//
//  Created by Long Lee on 4/15/18.
//

import UIKit
import TrustCore

public protocol NANJWalletDelegate {
    
    /// Callback Transaction when send NANJ completed.
    ///
    /// - Parameter transaction: transaction success.
    func didSendNANJCompleted(transaction: NANJTransaction?)
    
    /// Callback list Transaction when get completed.
    ///
    /// - Parameter transactions: list Transaction.
    func didGetTransactionList(transactions: Array<NANJTransaction>?)
    
    /// Callback amount NANJ of wallet.
    ///
    /// - Parameters:
    ///    - wallet: wallet get amount.
    ///    - amount: current amount of NANJ
    ///    - error: error when get not complete.
    func didGetAmountNANJ(wallet: NANJWallet, amount: Double, error: Error?)
    
    /// Callback amount ETH of wallet.
    ///
    /// - Parameters:
    ///    - wallet: wallet get amount.
    ///    - amount: current amount of ETH
    ///    - error: error when get not complete.
    func didGetAmountETH(wallet: NANJWallet, amount: Double, error: Error?)
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
    public func sendNANJ(with address: String, amount: Double) {
        //return by delegate
        
    }
    
    /// Get your NAJI amount
    ///
    public func getAmountNANJ() {
        let contract: Address? = Address(string: NANJContract.address)
        guard let address = self.etherWallet?.address, let __contract = contract else { return }
        TokensBalanceService().getBalance(for: address, contract: __contract) {result in
            //guard let `self` = self else {return}
            //self.delegate?.didGetAmountNANJ(wallet: self, amount: 0.0, error: result.error)
            print(result.value ?? "")
            print("Get NANJ value complete")
        }
    }
    
    
    /// Get your ETH amount
    ///
    public func getAmountETH() {
        guard let address = self.etherWallet?.address else { return }
        TokensBalanceService().getEthBalance(for: address) { result in
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
    public func getTransactionList() {
        //Return by delegate
        //Ex
        self.delegate?.didGetTransactionList(transactions: nil)
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
