//
//  NANJConfig.swift
//  NANJFrameworks
//
//  Created by Long Lee on 5/6/18.

import Foundation

struct NANJConfig {
    static let rpcServer: RPCServer = RPCServer.rinkeby //Test net.
    static let apiServer: String = "http://api-rinkeby.etherscan.io"
    static let rinkbyServer: String = "https://rinkeby.etherscan.io/"
    static let apiRinkebyKey: String = "WR5V2SAEJSPVVYPKJRFQI1HVBWT22T5XUJ"
    
    static let NANJ_SERVER: String = "https://nanj-demo.herokuapp.com/api"
    static let TX_RELAY_ADDRESS: String = "0x81031e97729515a7458e547e68efec7747665629"
    static let META_NANJCOIN_MANAGER: String = "0x17b8b16c20db3eb7100ef9c36cc904cace0aa20b"
    static let NANJCOIN_ADDRESS: String = "0x39d575711bbca97d554f57801de3090afe74dc12"
    static let WALLET_OWNER: String = "0x0000000000000000000000000000000000000000"
    static let PAD: String = "0000000000000000000000000000000000000000000000000000000000000000"
}

struct NANJContract {
    static let contract: String = "0x39d575711BBCa97D554f57801de3090aFE74dC12"
    static let address: String = "0x39d575711BBCa97D554f57801de3090aFE74dC12"
    static let name: String = "ESNJCOIN"
    static let symbol: String = "ESNJ"
    static let decimals: Int = 8
}
