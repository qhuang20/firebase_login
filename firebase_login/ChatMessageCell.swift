//
//  ChatMessageCell.swift
//  firebase_login
//
//  Created by Qichen Huang on 2018-01-11.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase

class ChatMessageCell: UICollectionViewCell {
    
    var message: Message? {
        didSet {
            guard let message = message else { return }
            textView.text = message.text
            setup(message: message)
        }
    }
    
    private func setup(message: Message) {

        if message.fromId == Auth.auth().currentUser?.uid {
            bubbleView.backgroundColor = ChatMessageCell.blueColor
            textView.textColor = UIColor.white
            profileImageView.isHidden = true
            
            bubbleViewRightAnchor?.isActive = true
            bubbleViewLeftAnchor?.isActive = false
            
        } else {
            bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            textView.textColor = UIColor.black
            profileImageView.isHidden = false
            
            bubbleViewRightAnchor?.isActive = false
            bubbleViewLeftAnchor?.isActive = true
        }
        
        if let messageImageUrl = message.imageUrl {
            messageImageView.loadImageUsingCacheWithUrlString(messageImageUrl)
            messageImageView.isHidden = false
            bubbleView.backgroundColor = UIColor.clear
        } else {
            messageImageView.isHidden = true
        }
        
    }
    
    let textView: UITextView = {
        let tv = UITextView()
        //tv.text = "SAMPLE TEXT FOR NOW"
        tv.textColor = .white
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.backgroundColor = .clear
        tv.isEditable = false
        return tv
    }()
    
    static let blueColor = UIColor(r: 0, g: 137, b: 249)
    
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = blueColor
        view.layer.cornerRadius = 16
        //view.layer.masksToBounds = true
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        //imageView.image = UIImage(named: "nedstark")
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var bubbleViewWidthAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        bubbleView.addSubview(messageImageView)
       
        _ = messageImageView.anchor(top: bubbleView.topAnchor, left: bubbleView.leftAnchor, bottom: bubbleView.bottomAnchor, right: bubbleView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        _ = profileImageView.anchor(top: nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: nil, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 0, widthConstant: 32, heightConstant: 32)
        
        let bubbleAnchors = bubbleView.anchor(top: self.topAnchor, left: nil, bottom: nil, right: self.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 8, widthConstant: 200, heightConstant: 0)
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        bubbleViewWidthAnchor = bubbleAnchors["width"]
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        bubbleViewRightAnchor = bubbleAnchors["right"]
       
        _ = textView.anchor(top: self.topAnchor, left: bubbleView.leftAnchor, bottom: nil, right: bubbleView.rightAnchor, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        //self.frame.height wrong!!! every properties are reuseable!
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
