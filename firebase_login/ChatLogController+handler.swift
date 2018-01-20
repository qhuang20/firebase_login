//
//  ChatLogController+handler.swift
//  firebase_login
//
//  Created by Qichen Huang on 2018-01-17.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

extension ChatLogController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func handleUploadTap() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoFileUrl = info[UIImagePickerControllerMediaURL] as? URL {
            uploadToFirebaseStorageWith(videoFileUrl: videoFileUrl)
        }
        
        if let selectedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            uploadToFirebaseStorageWith(image: selectedImage, completionHandler: { (imageUrl) in
                self.sendMessageToDatabaseWith(imageUrl: imageUrl, image: selectedImage)
            })
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    private func uploadToFirebaseStorageWith(videoFileUrl: URL) {
        let filename = UUID().uuidString + ".mov"
        let uploadTask = Storage.storage().reference().child("message_movies").child(filename).putFile(from: videoFileUrl, metadata: nil, completion: { (metadata, error) in
            
            if error != nil {
                print("uploadToFirebaseStorageWith: ", error!)
                return
            }
            
            guard let storageUrl = metadata?.downloadURL()?.absoluteString else {return}
            guard let thumbnailImage = self.thumbnailImageFor(fileUrl: videoFileUrl) else { return }
            self.uploadToFirebaseStorageWith(image: thumbnailImage, completionHandler: { (imageUrl) in
               
                self.sendMessageToDatabaseWith(videoUrl: storageUrl, imageUrl: imageUrl, thumbnailImage: thumbnailImage)
            })
            
        })
        
        uploadTask.observe(.progress) { (snapshot) in
            if let completedUnitCount = snapshot.progress?.completedUnitCount {
                self.navigationItem.title = String(completedUnitCount)
            }
        }
        
        uploadTask.observe(.success) { (snapshot) in
            self.navigationItem.title = self.user?.name
        }
        
    }
    
    private func uploadToFirebaseStorageWith(image: UIImage, completionHandler: @escaping (String) -> ()) {
        let imageName = UUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            ref.putData(uploadData, metadata: nil, completion: { (metedata, error) in
                if error != nil {
                    print("uploadToFirebaseStorageWith: ", error!)
                    return
                }
                
                if let imageUrl = metedata?.downloadURL()?.absoluteString {
                    completionHandler(imageUrl)
                }
                
            })
        }
    }
    
    
    
    private func sendMessageToDatabaseWith(videoUrl: String, imageUrl: String, thumbnailImage: UIImage) {
        let properties: [String: Any] = ["imageUrl": imageUrl, "imageWidth": thumbnailImage.size.width, "imageHeight": thumbnailImage.size.height, "videoUrl": videoUrl]
        
        sendMessageToDatabaseWith(properties: properties)
    }
    
    private func sendMessageToDatabaseWith(imageUrl: String, image: UIImage) {
        let properties: [String: Any] = ["imageUrl": imageUrl, "imageWidth": image.size.width, "imageHeight": image.size.height]
        sendMessageToDatabaseWith(properties: properties)
    }
    
    private func sendMessageToDatabaseWith(properties: [String: Any]) {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = Auth.auth().currentUser!.uid
        let timestamp = Int(Date().timeIntervalSince1970)
        
        var values: [String: Any] = ["toId": toId, "fromId": fromId, "timestamp": timestamp]
        
        properties.forEach({values[$0] = $1})
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print("sendMessageToDatabaseWith: ", error!)
                return
            }
            
            self.inputTextField.text = nil
            
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
            
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
            recipientUserMessagesRef.updateChildValues([messageId: 1])
        }
        
    }
    
    private func thumbnailImageFor(fileUrl: URL) -> UIImage? {///
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
            
        } catch let err {
            print(err)
        }
        
        return nil
    }
    
    @objc func handleSend() {
        let properties = ["text": inputTextField.text!]
        sendMessageToDatabaseWith(properties: properties)
    }
    
    
    
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





