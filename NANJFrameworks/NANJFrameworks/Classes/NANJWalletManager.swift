//
//  NANJWalletManager.swift
//  NANJFramworks
//
//  Created by Long Lee on 4/15/18.
//

import UIKit

public protocol NANJWalletManagerDelegate {
    func didCreateWallet(wallet: NANJWallet?, error: Error?)
    func didImportWallet(wallet: NANJWallet?, error: Error?)
    func didGetWalletList(wallets: Array<NANJWallet?>, error: Error?)
    func didGetWalletFromQRCode(wallet: NANJWallet?)
    func didGetNANJRate(rate: Double)
}

public class NANJWalletManager: NSObject {
    
    public static let shared : NANJWalletManager = NANJWalletManager()
    
    public var delegate: NANJWalletManagerDelegate?
    
    public func createWallet() {
        //Return value with delegate
        //Ex
        self.delegate?.didCreateWallet(wallet: nil, error: nil)
    }
    
    public func importWallet(with private: String?, with json: NSDictionary) {
        //Return value with delegate
        
    }
    
    public func removeWallet(wallet: NANJWallet) -> Bool {
        
        return false
    }
    
    public func enableWallet(wallet: NANJWallet) -> Bool {
        
        return false
    }
    
    public func getCurrentWallet() -> NANJWallet? {
        
        return nil
    }
    
    public func getWalletList() {
        //Return value with delegate
        
    }
    
    public func getWalletFromQRCode() {
        //Return value with delegate
        
    }
    
    public func getNANJRate(){
        //Return value with delegate

    }

}
