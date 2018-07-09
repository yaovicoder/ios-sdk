//
//  NANJWalletManagerTests.swift
//  NANJFrameworks_Example
//
//  Copyright © 2018 NANJ. All rights reserved.
//

import XCTest

import NANJFrameworks

class NANJWalletManagerTests: XCTestCase, NANJWalletManagerDelegate {

    //Create Wallet
    private var createWalletExpectation: XCTestExpectation!
    private var wallet: NANJWallet?
    private var err: Error?
    
    //Import Wallet
    private var importWalletExpectation: XCTestExpectation!
    private var walletImport: NANJWallet?
    private var errImport: Error?
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        self.wallet = nil
        self.err = nil
        super.tearDown()
    }
    
    func testInitialization() {
        let manager = NANJWalletManager.shared
        XCTAssertNotNil(manager)
    }
    
    func testCreateWallet() {
        createWalletExpectation = expectation(description: "nanj.create.wallet")
        let manager = NANJWalletManager.shared
        manager.delegate = self
        manager.createWallet(password: "password")
        wait(for: [createWalletExpectation], timeout: 100.0)
        
    }
    
    func testImportWalletWithPrivateKey() {
        importWalletExpectation = expectation(description: "nanj.import.wallet")
        let manager = NANJWalletManager.shared
        manager.delegate = self
        manager.importWallet(privateKey: "privateKey")
        
        wait(for: [importWalletExpectation], timeout: 100.0)
    }
    
    func testImportWalletWithKeystore() {
        
    }

    func testExportPrivateKey() {
        
    }
    
    func testExportKeystore() {
        
    }
    
    //MARK: - NANJWalletManagerDelegate
    func didCreatingWallet(wallet: NANJWallet?) {
        
    }
    
    func didCreateWallet(wallet: NANJWallet?, error: Error?) {
        self.err = error;
        self.wallet = wallet
        if err != nil {
            XCTAssertNil(wallet)
        } else {
            XCTAssertNotNil(wallet)
            XCTAssertNotNil(wallet?.address)
            XCTAssertNotNil(wallet?.addressETH)
        }

        createWalletExpectation.fulfill()
    }
    
}
