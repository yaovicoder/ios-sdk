//
//  AccountExtentsion.swift
//  NANJFrameworks
//
//  Created by MinaWorks on 4/21/18.
//

import Foundation
import TrustKeystore

extension Account {
    func toNANJWallet() -> NANJWallet {
        let wallet: NANJWallet = NANJWallet()
        if let address = UserDefaults.standard.string(forKey: self.address.eip55String) {
            wallet.address = address
        }
        wallet.addressETH = self.address.eip55String
        wallet.addEtherWallet(wallet: Wallet(type: .privateKey(self)))
        return wallet
    }
}

extension Wallet {
    func toNANJWallet() -> NANJWallet {
        let wallet: NANJWallet = NANJWallet()
        if let address = UserDefaults.standard.string(forKey: self.address.eip55String) {
            wallet.address = address
        }
        wallet.addressETH = self.address.eip55String
        wallet.addEtherWallet(wallet: self)
        return wallet
    }
}

extension Array {
    subscript (safe index: Int) -> Element? {
        get {
            return (0 <= index && index < count) ? self[index] : nil
        }
        set (value) {
            if value == nil {
                return
            }
            
            if !(count > index) {
                print("WARN: index:\(index) is out of range, so ignored. (array:\(self))")
                return
            }
            
            self[index] = value!
        }
    }
}
