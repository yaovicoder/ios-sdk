//
//  UIButtonExtensions.swift
//  NDE
//
//  Created by JustinDo on 1/29/18.
//  Copyright © 2018 iKite Labs. All rights reserved.
//

import UIKit

public extension UIButton {
    
    @IBInspectable
    public var spaceTitle: CGFloat {
        get {
            return titleEdgeInsets.right
        }
        set {
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: newValue)
        }
    }
    
}
