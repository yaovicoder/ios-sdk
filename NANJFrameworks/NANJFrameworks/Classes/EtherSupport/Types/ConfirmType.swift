//
//  ConfirmType.swift
//  NANJFrameworks
//
//  Created by Long Lee on 5/5/18.
//

import Foundation

enum ConfirmType {
    case sign
    case signThenSend
}

enum ConfirmResult {
    case signedTransaction(SentTransaction)
    case sentTransaction(SentTransaction)
}
