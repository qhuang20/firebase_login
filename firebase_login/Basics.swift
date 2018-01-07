//
//  Extensions.swift
//  firebase_login
//
//  Created by Qichen Huang on 2017-12-31.
//  Copyright © 2017 Qichen Huang. All rights reserved.
//


import UIKit

extension UIColor {
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
}

extension UIView {
    
    func anchorTo(top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil) {
        
        anchorWithConstantsTo(top: top, left: left, bottom: bottom, right: right, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
    }
    
    func anchorWithConstantsTo(top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0) {
        
        _ = anchor(top: top, left: left, bottom: bottom, right: right, topConstant: topConstant, leftConstant: leftConstant, bottomConstant: bottomConstant, rightConstant: rightConstant)
    }
    
    func anchor(top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0, widthConstant: CGFloat = 0, heightConstant: CGFloat = 0) -> [String: NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchors: [String: NSLayoutConstraint] = [:]
        
        if let top = top {
            anchors["top"] = topAnchor.constraint(equalTo: top, constant: topConstant)
        }
        
        if let left = left {
            anchors["left"] = leftAnchor.constraint(equalTo: left, constant: leftConstant)
        }
        
        if let bottom = bottom {
            anchors["bottom"] = bottomAnchor.constraint(equalTo: bottom, constant: -bottomConstant)
        }
        
        if let right = right {
            anchors["right"] = rightAnchor.constraint(equalTo: right, constant: -rightConstant)
        }
        
        if widthConstant > 0 {
            anchors["width"] = widthAnchor.constraint(equalToConstant: widthConstant)
        }
        
        if heightConstant > 0 {
            anchors["height"] = heightAnchor.constraint(equalToConstant: heightConstant)
        }
        
        anchors.forEach { (key, anchor) in
            anchor.isActive = true
        }
        
        return anchors
    }
    
    //center
    func anchorTo(centerX: NSLayoutXAxisAnchor? = nil, centerY: NSLayoutYAxisAnchor? = nil, xConstant: CGFloat = 0, yConstant: CGFloat = 0, widthConstant: CGFloat = 0, heightConstant: CGFloat = 0) -> [String: NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchors: [String: NSLayoutConstraint] = [:]
        
        if let centerX = centerX {
            anchors["centerX"] = centerXAnchor.constraint(equalTo: centerX, constant: xConstant)
        }
        
        if let centerY = centerY {
            anchors["centerY"] = centerYAnchor.constraint(equalTo: centerY, constant: yConstant)
        }
        
        if widthConstant > 0 {
            anchors["width"] = widthAnchor.constraint(equalToConstant: widthConstant)
        }
        
        if heightConstant > 0 {
            anchors["height"] = heightAnchor.constraint(equalToConstant: heightConstant)
        }
        
        anchors.forEach { (key, anchor) in
            anchor.isActive = true
        }
        
        return anchors
        
    }
    
}


