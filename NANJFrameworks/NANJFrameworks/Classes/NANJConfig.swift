//
//  NANJConfig.swift
//  NANJFrameworks
//
//  Created by Long Lee on 5/6/18.

import Foundation

public struct NANJConfig {
    static let rpcServer: RPCServer = RPCServer.ropsten //Test net.
    static let apiServerTransaction: String = "https://api-ropsten.etherscan.io"
    static let apiServerTransactionKey: String = "YourApiKeyToken"
    static let rinkbyServer: String = "https://rinkeby.etherscan.io/"
    
    static let NANJ_SERVER: String = "https://staging.nanjcoin.com/api"

    static let TX_RELAY_ADDRESS: String = "0x7e861e36332693f271c66bdab40cda255a50d005"
    static var META_NANJCOIN_MANAGER: String = "0x8801307aec8ed852ea23d3d4e69f475f4f2dcb6e"
    static var NANJCOIN_ADDRESS: String = "0xf7afb89bef39905ba47f3877e588815004f7c861"
    static let WALLET_OWNER: String = "0x0000000000000000000000000000000000000000"
    static let PAD: String = "0000000000000000000000000000000000000000000000000000000000000000"
    
    static var APP_HASH: String = ""
    static var NANJWALLET_APP_ID: String = ""
    static var NANJWALLET_SECRET_KEY: String = ""
    static var NANJ_COIN_NAME: String = ""
    static var SYMBOL: String = "ESNJ"
    static var DECIMALS: Int = 8

}
