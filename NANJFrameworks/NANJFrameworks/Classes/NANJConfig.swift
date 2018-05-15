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
}

struct NANJContract {
    static let contract: String = "0x39d575711BBCa97D554f57801de3090aFE74dC12"
    static let address: String = "0x39d575711BBCa97D554f57801de3090aFE74dC12"
    static let name: String = "ESNJCOIN"
    static let symbol: String = "ESNJ"
    static let decimals: Int = 8
}
