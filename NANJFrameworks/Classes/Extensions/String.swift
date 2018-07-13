// Copyright SIX DAY LLC. All rights reserved.

import Foundation

extension String {
    var hex: String {
        let data = self.data(using: .utf8)!
        return data.map { String(format: "%02x", $0) }.joined()
    }

    var hexEncoded: String {
        let data = self.data(using: .utf8)!
        return data.hexEncoded
    }

    var doubleValue: Double {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.decimalSeparator = "."
        if let result = formatter.number(from: self) {
            return result.doubleValue
        } else {
            formatter.decimalSeparator = ","
            if let result = formatter.number(from: self) {
                return result.doubleValue
            }
        }
        return 0
    }

    var trimmed: String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    var asDictionary: [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
                return [:]
            }
        }
        return [:]
    }

    var drop0x: String {
        if self.count > 2 && self.substring(with: 0..<2) == "0x" {
            return String(self.dropFirst(2))
        }
        return self
    }

    var add0x: String {
        return "0x" + self
    }
}

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }

    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }

    /// SwifterSwift: Returns a string by padding to fit the length parameter size with another string in the start.
    ///
    ///   "hue".paddingStart(10) -> "       hue"
    ///   "hue".paddingStart(10, with: "br") -> "brbrbrbhue"
    ///
    /// - Parameter length: The target length to pad.
    /// - Parameter string: Pad string. Default is " ".
    /// - Returns: The string with the padding on the start.
    public func paddingStart(_ length: Int, with string: String = " ") -> String {
        guard count < length else { return self }
        
        let padLength = length - count
        if padLength < string.count {
            return string[string.startIndex..<string.index(string.startIndex, offsetBy: padLength)] + self
        } else {
            var padding = string
            while padding.count < padLength {
                padding.append(string)
            }
            return padding[padding.startIndex..<padding.index(padding.startIndex, offsetBy: padLength)] + self
        }
    }
}
