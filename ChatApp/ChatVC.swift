//
//  ChatVC.swift
//  ChatApp
//
//  Created by Jiarong He on 2017-11-05.
//  Copyright © 2017 Jiarong He. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices
import AVKit
import SDWebImage


class ChatVC: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MessageReceivedDelegate {
    
    
    // variables
    private var messages = [JSQMessage]();
    
    let picker = UIImagePickerController();
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // delegate
        picker.delegate = self;
        MessagesHandler.Instance.delegate = self;
        
        
        self.senderId = AuthProvider.Instance.userID();
        self.senderDisplayName = AuthProvider.Instance.userName;
        
        
        // watch added messages
        MessagesHandler.Instance.observerMessages();
        MessagesHandler.Instance.oberverMediaMessages();
    }
    
    
    // Go back
    @IBAction func backBtn(_ sender: Any) {
        
        dismiss(animated: true, completion: nil);
    }
    
    
    // JSQ table delegate func(6)
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return messages.count;
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell;
        return cell;
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        
        return messages[indexPath.item];
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        
        // video player
        let msg = messages[indexPath.item];
        
        if msg.isMediaMessage {
            
            if let mediaItem = msg.media as? JSQVideoMediaItem{
                
                let player = AVPlayer(url: mediaItem.fileURL);
                let playerController = AVPlayerViewController();
                playerController.player = player;
                
                self.present(playerController, animated: true, completion: nil);
            }
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        // bubble msg
        let bubbleFactory = JSQMessagesBubbleImageFactory();
        let message = messages[indexPath.item];
        
        
        // msg role
        if message.senderId == self.senderId{
            return bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.red);
        }else{
            return bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.orange);
        }
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        // avatar
        return JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "avatar"), diameter: 30);
    }
    
    
    
    // message delegate: watch added message
    func messageReceived(senderID: String, senderName: String, text: String){
        
        messages.append(JSQMessage(senderId: senderID, displayName: senderName, text: text));
        collectionView.reloadData();
    }
    
    
    // send msg
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        
//        // append msg to array
//        messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text));
//        
//        // reload
//        collectionView.reloadData();
        
        
        // send msg to firebase
        MessagesHandler.Instance.sendMessage(senderID: senderId, senderName: senderDisplayName, text: text);
        
        // remove the text from text field
        finishSendingMessage();
    }
    
    
    
    // media delegate: watch added media
    func mediaReceived(senderID: String, senderName: String, url: String) {
        
        if let mediaURL = URL(string: url){
            
            do {
                
                let data = try Data(contentsOf: mediaURL);
                
                if let _ = UIImage(data: data){
                    
                    // 1. Image
                    
                    let _ = SDWebImageDownloader.shared().downloadImage(with: mediaURL, options: [], progress: nil, completed: {
                        
                        (image, data, error, finished) in
                        
                        DispatchQueue.main.async {
                            
                            let photo = JSQPhotoMediaItem(image: image);
                            
                            if senderID == self.senderId{
                                photo?.appliesMediaViewMaskAsOutgoing = true;
                            }else{
                                photo?.appliesMediaViewMaskAsOutgoing = false;
                            }
                            
                            
                            self.messages.append(JSQMessage(senderId: senderID, displayName: senderName, media: photo));
                            self.collectionView.reloadData();
                        }
                    })
                    
                }else{
                    
                    // 2. Video
                    
                    let video = JSQVideoMediaItem(fileURL: mediaURL, isReadyToPlay: true);
                    
                    if senderID == self.senderId{
                        video?.appliesMediaViewMaskAsOutgoing = true;
                    }else{
                        video?.appliesMediaViewMaskAsOutgoing = false;
                    }
                    
                    self.messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: video));
                    self.collectionView.reloadData();
                    
                }
                
            } catch {
                
            }
        }
        
    }
    
    
    
    // attach image / video
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        let alert = UIAlertController(title: "Media Messages", message: "Please Select A Media", preferredStyle: .actionSheet);
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil);
        
        let photos = UIAlertAction(title: "Photos", style: .default, handler: {
            
            (alert: UIAlertAction) in
            
            self.chooseMedia(type: kUTTypeImage);
        });
        
        let videos = UIAlertAction(title: "Videos", style: .default, handler: {
            
            (alert: UIAlertAction) in
            
            self.chooseMedia(type: kUTTypeMovie);
        });
        
        alert.addAction(photos);
        alert.addAction(videos);
        alert.addAction(cancel);
        present(alert, animated: true, completion: nil);
    }
    
    
    // picker func
    private func chooseMedia(type: CFString){
        
        picker.mediaTypes = [type as String];
        present(picker, animated: true, completion: nil);
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        if let pic = info[UIImagePickerControllerOriginalImage] as? UIImage{
            
//            let img = JSQPhotoMediaItem(image: pic);
//            self.messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: img));
            
            
            // send image to firebase
            let data = UIImageJPEGRepresentation(pic, 0.01);
            MessagesHandler.Instance.sendMedia(image: data, video: nil, senderID: senderId, senderName: senderDisplayName);
            
            
        }else if let vidURL = info[UIImagePickerControllerMediaURL] as? URL{
            
//            let video = JSQVideoMediaItem(fileURL: vidURL, isReadyToPlay: true);
//            self.messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: video));
            
            
            // send video to firebase
            MessagesHandler.Instance.sendMedia(image: nil, video: vidURL, senderID: senderId, senderName: senderDisplayName);
            
        }
        
        self.dismiss(animated: true, completion: nil);
        collectionView.reloadData();
    }
    
    
    
    
    
    
    
    
    
    
}
