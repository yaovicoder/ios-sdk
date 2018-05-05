// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustCore

enum RefreshType {
    case balance
    case ethBalance
}

class WalletSession {
    let account: Wallet
    let config: Config
    let chainState: ChainState

    var sessionID: String {
        return "\(account.address.description.lowercased())-\(config.chainID)"
    }

    init(
        account: Wallet,
        config: Config
    ) {
        self.account = account
        self.config = config
        self.chainState = ChainState(config: config)
        self.chainState.start()
    }

    func refresh() {

    }

    func stop() {
        chainState.stop()
    }
}
