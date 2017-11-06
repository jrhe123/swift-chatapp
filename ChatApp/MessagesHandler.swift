//
//  MessagesHandler.swift
//  ChatApp
//
//  Created by Jiarong He on 2017-11-05.
//  Copyright © 2017 Jiarong He. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

protocol MessageReceivedDelegate: class {
    
    func messageReceived(senderID: String, senderName: String, text: String);
    func mediaReceived(senderID: String, senderName: String, url: String);
}


class MessagesHandler{
    
    
    // delegate
    weak var delegate: MessageReceivedDelegate?;
    
    
    private static let _instance = MessagesHandler();
    
    private init(){}
    
    static var Instance: MessagesHandler{
        return _instance;
    }
    
    
    // send message
    func sendMessage(senderID: String, senderName: String, text: String){
     
        let data: Dictionary<String, Any> = [Constants.SENDER_ID: senderID, Constants.SENDER_NAME: senderName, Constants.TEXT: text];
        
        DBProvider.Instance.messagesRef.childByAutoId().setValue(data);
    }
    
    
    // send media
    func sendMedia(image: Data?, video: URL?, senderID: String, senderName: String){
        
        if image != nil{
            
            DBProvider.Instance.imageStorageRef.child(senderID + "\(NSUUID().uuidString).jpg").putData(image!, metadata: nil){
                
                (metadata: StorageMetadata?, err: Error?) in
                
                if err != nil {
                    // to-do: delegate inform user msg
                }else{
                    self.sendMediaMessage(senderID: senderID, senderName: senderName, url: String(describing: metadata!.downloadURL()!));
                }
            }
            
        }else{
            
            DBProvider.Instance.videoStorageRef.child(senderID + "\(NSUUID().uuidString)").putFile(from: video!, metadata: nil){
                
                (metadata: StorageMetadata?, err: Error?) in
                
                if err != nil {
                    // to-do: delegate inform user msg
                }else{
                    self.sendMediaMessage(senderID: senderID, senderName: senderName, url: String(describing: metadata!.downloadURL()!));
                }
            }
            
        }
    
    }
    
    func sendMediaMessage(senderID: String, senderName: String, url: String){
        
        let data: Dictionary<String, Any> = [Constants.SENDER_ID: senderID, Constants.SENDER_NAME: senderName, Constants.URL: url];
        
        DBProvider.Instance.mediaMessagesRef.childByAutoId().setValue(data);
    }
    
    
    // watch new messages
    func observerMessages(){
        
        DBProvider.Instance.messagesRef.observe(DataEventType.childAdded) {
            
            (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary{
                
                if let senderID = data[Constants.SENDER_ID] as? String{
                    
                    if let senderName = data[Constants.SENDER_NAME] as? String{
                        
                        if let text = data[Constants.TEXT] as? String{
                            
                            self.delegate?.messageReceived(senderID: senderID, senderName: senderName, text: text);
                        }
                    }
                }
            }
        }
    }
    
    
    // watch new media
    func oberverMediaMessages(){
        
        DBProvider.Instance.mediaMessagesRef.observe(DataEventType.childAdded) {
            
            (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary{
                
                if let senderID = data[Constants.SENDER_ID] as? String{
                    
                    if let senderName = data[Constants.SENDER_NAME] as? String{
                        
                        if let fileURL = data[Constants.URL] as? String{
                            
                            self.delegate?.mediaReceived(senderID: senderID, senderName: senderName, url: fileURL);
                        }
                    }
                }
            }
        }
    }
    
    
}

