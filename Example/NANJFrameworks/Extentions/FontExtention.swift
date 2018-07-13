//
//  FontExtention.swift
//  NDE
//
//  Created by MinaWorks on 2/23/18.
//  Copyright © 2018 NDE Labs. All rights reserved.
//

import UIKit

extension UIFont {
    class func SFFont(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont(name: "SF UI Display-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    class func SFFontBold(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont(name: "SF UI Display-Bold", size: fontSize) ?? UIFont.boldSystemFont(ofSize: fontSize)
    }
    
    class func ArialFont(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Arial-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    class func ArialFontBold(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Arial-Bold", size: fontSize) ?? UIFont.boldSystemFont(ofSize: fontSize)
    }
    
    class func AppleChancery(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Apple Chancery", size: fontSize) ?? UIFont.SFFont(ofSize: fontSize)
    }
    
}
