//
//  ChatMessageCell.swift
//  firebase_login
//
//  Created by Qichen Huang on 2018-01-11.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.text = "SAMPLE TEXT FOR NOW"
        tv.textColor = .white
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.backgroundColor = .clear
        return tv
    }()
    
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 0, g: 137, b: 249)
        view.layer.cornerRadius = 16
        //view.layer.masksToBounds = true
        return view
    }()
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubbleView)
        addSubview(textView)
        
        bubbleWidthAnchor = bubbleView.anchor(top: self.topAnchor, left: nil, bottom: nil, right: self.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 8, widthConstant: 200, heightConstant: 0)["width"]
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
       
        _ = textView.anchor(top: self.topAnchor, left: bubbleView.leftAnchor, bottom: nil, right: bubbleView.rightAnchor, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        //self.frame.height wrong!!! every properties are reuseable!
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
