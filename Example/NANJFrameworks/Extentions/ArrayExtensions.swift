//
//  ArrayExtensions.swift
//  VideoPlayer
//
//  Created by Manh Pham on 10/19/17.
//  Copyright © 2017 MTCT. All rights reserved.
//

import Foundation

extension Array {
    func take(count:Int) -> ArraySlice<Element> {
        return self[0..<count]
    }
    
    func drop(count:Int) -> ArraySlice<Element> {
        return self[count..<self.count]
    }
    
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
    
    func chunks(_ chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
    
    static func filterNils(from array: [Element?]) -> [Element] {
        return array.filter { $0 != nil }.map { $0! }
    }
    
}
