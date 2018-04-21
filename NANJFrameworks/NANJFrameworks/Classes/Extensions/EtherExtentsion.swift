//
//  AccountExtentsion.swift
//  NANJFrameworks
//
//  Created by Long Lee on 4/21/18.
//

import Foundation
import TrustKeystore

extension Account {
    func toNANJWallet() -> NANJWallet {
        let wallet: NANJWallet = NANJWallet()
        wallet.address = self.address.eip55String
        wallet.addEtherWallet(wallet: Wallet(type: .privateKey(self)))
        return wallet
    }
}

extension Wallet {
    func toNANJWallet() -> NANJWallet {
        let wallet: NANJWallet = NANJWallet()
        wallet.address = self.address.eip55String
        wallet.addEtherWallet(wallet: self)
        return wallet
    }
}
