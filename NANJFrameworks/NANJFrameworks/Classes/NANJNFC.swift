//
//  NANJNFCVC.swift
//  NANJFramworks
//
//  Created by Long Lee on 4/15/18.
//

import UIKit
import CoreNFC

@objc public protocol NANJNFCDelegate {
    @objc optional func didScanNFC(address: String?) -> Void;
    @objc optional func didCloseScan();
}

public class NANJNFC: NSObject, NFCNDEFReaderSessionDelegate {
    
    public var delegate: NANJNFCDelegate?
    
    @available(iOS 11.0, *)
    fileprivate lazy var session: NFCNDEFReaderSession = {
        return NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
    }()
    
    public func startScan() {
        if #available(iOS 11.0, *) {
            if NFCNDEFReaderSession.readingAvailable {
                self.startNFCSession()
            } else {
                //Device not support

            }
        } else {

        }
    }
    
    public func stopScan() {
        if #available(iOS 11.0, *) {
            self.session.invalidate()
        }
    }
    
    //MARK: - Private Function
    @available(iOS 11.0, *)
    fileprivate func startNFCSession() {
        self.session.begin()
    }
    
    
    //MARK: - NFC Delegate
    @available(iOS 11.0, *)
    public func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        var __address: String?
        for message in messages {
            for record in message.records {
                if let address = self.payloadString(payload: record) {
                    __address = address
                }
            }
        }
        self.delegate?.didScanNFC?(address: __address)
        if __address != nil {
            self.stopScan()
        }
    }
    
    @available(iOS 11.0, *)
    public func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        self.delegate?.didCloseScan?()
    }
    
}

extension NANJNFC {
    @available(iOS 11.0, *)
    fileprivate func payloadString(payload: NFCNDEFPayload) -> String? {
        let typeStr: String? = String(data: payload.type, encoding: .utf8)
        let length = payload.payload.count

        if length == 0 {
            return nil
        }
        
        if typeStr == "T" {
            if (length < 1) {
                return nil;
            }
            var payloadBytes: Array<UInt8> = payload.payload.bytes
            let codeLength: UInt8 = UInt8((payloadBytes[0]) & 0x7f)
            if length < 1 + Int(codeLength) {
                return nil
            }
            //Get lang code and text.
            var bytes: Array<UInt8> = []
            _ = payloadBytes.enumerated().map { (index, value) -> UInt8 in
                if index != 0 {
                    bytes.append(value)
                }
                return UInt8(value)
            }
        
            let dataCodeLenght = NSData(bytes: bytes, length: Int(codeLength))
            let langCode = String.init(data: dataCodeLenght as Data, encoding: .utf8)

            var bytesText: Array<UInt8> = []
            _ = payloadBytes.enumerated().map { (index, value) -> UInt8 in
                if index > codeLength {
                    bytesText.append(value)
                }
                return UInt8(value)
            }
            let __dataText = NSData(bytes: bytesText, length: Int(length - 1 - Int(codeLength)))
            let address = String.init(data: __dataText as Data, encoding: .utf8)
        
            if CryptoAddressValidator.isValidAddress(address) {
               return address
            }
            return nil
        } else {
            let address: String? = String(data: payload.payload, encoding: .utf8)
            if CryptoAddressValidator.isValidAddress(address) {
                return address
            }
        }
        return nil
    }
    
}
