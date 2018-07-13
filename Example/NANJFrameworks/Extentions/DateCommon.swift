import UIKit

class DateCommon: NSObject {
    static func convertDateToStringWithFormat(date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM yyyy HH:mm:ss"
        formatter.locale = NSLocale.current
        return formatter.string(from: date)
    }
    
    static func convertDateFromTimestamp(_ time: Double) -> Date {
        return Date(timeIntervalSince1970: time)
    }
    
    static func convertTimestampToStringWith(_ time: Double) -> String {
        let date = DateCommon.convertDateFromTimestamp(time)
        return DateCommon.convertDateToStringWithFormat(date: date, format: "E, d MMM yyyy HH:mm:ss")
    }
}
