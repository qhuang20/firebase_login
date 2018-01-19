//
//  ChatLogController+handler.swift
//  firebase_login
//
//  Created by Qichen Huang on 2018-01-17.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

extension ChatLogController {
    
    @objc func handleKeyboardWillShow(_ notification: Notification) {
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func handleKeyboardWillHide(_ notification: Notification) {
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        containerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func handleKeyboardDidShow() {
        if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }

    public func performZoomInForStartingImageView(_ startingImageView: UIImageView) {
        self.startingImageView = startingImageView
        startingImageView.isHidden = true
        inputTextField.resignFirstResponder()///

        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        guard let startingFrame = startingFrame else { return }
        
        let zoomingImageView = UIImageView(frame: startingFrame)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        
        blackBackgroundView = UIView(frame: keyWindow.frame)
        blackBackgroundView?.backgroundColor = UIColor.black
        blackBackgroundView?.alpha = 0
        keyWindow.addSubview(blackBackgroundView!)
        keyWindow.addSubview(zoomingImageView)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.blackBackgroundView?.alpha = 1
            
            let height = startingFrame.height / startingFrame.width * keyWindow.frame.width
            zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
            zoomingImageView.center = keyWindow.center
            
        }, completion: nil)
    }
    
    @objc func handleZoomOut(_ tapGesture: UITapGestureRecognizer) {
        guard let zoomOutImageView = tapGesture.view else { return }

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            zoomOutImageView.frame = self.startingFrame!
            self.blackBackgroundView?.alpha = 0
            
        }, completion: { (completed) in
            zoomOutImageView.removeFromSuperview()
            self.startingImageView?.isHidden = false
        })
    }
    
}





