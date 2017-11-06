//
//  DBProvider.swift
//  ChatApp
//
//  Created by Jiarong He on 2017-11-05.
//  Copyright © 2017 Jiarong He. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage



protocol FetchData: class{
    func dataReceived(contacts: [Contact]);
}



class DBProvider {
    
    private static let _instance = DBProvider();
    
    
    // delegate
    weak var delegate: FetchData?;
    
    
    private init(){}
    
    static var Instance: DBProvider {
        return _instance;
    }
    
    // 1. DB
    // ROOT_DB Ref
    var dbRef: DatabaseReference{
        return Database.database().reference();
    }
    
    // Contacts
    var contactsRef: DatabaseReference{
        return dbRef.child(Constants.CONTACTS);
    }
    
    // Messages
    var messagesRef: DatabaseReference{
        return dbRef.child(Constants.MESSAGES);
    }
    
    // Media Messages
    var mediaMessagesRef: DatabaseReference{
        return dbRef.child(Constants.MEDIA_MESSAGES);
    }
    
    
    // 2. STORAGE
    // ROOT_STORAGE Ref
    var storageRef: StorageReference{
        return Storage.storage().reference(forURL: "gs://swift-chatapp-df8a1.appspot.com");
    }

    // Image
    var imageStorageRef: StorageReference{
        return storageRef.child(Constants.IMAGE_STORAGE);
    }
    
    // Video
    var videoStorageRef: StorageReference{
        return storageRef.child(Constants.VIDEO_STORAGE);
    }
    
    
    // 3. func
    // save user
    func saveUser(withID: String, email: String, password: String){
        
        let data: Dictionary<String, Any> = [Constants.EMAIL: email, Constants.PASSWORD: password];
        contactsRef.child(withID).setValue(data);
    }
    
    
    // fetch contacts
    func getContacts(){
        
        contactsRef.observeSingleEvent(of: DataEventType.value) {
            
            (snapshot: DataSnapshot) in
            
            var contacts = [Contact]();
            
            if let myContacts = snapshot.value as? NSDictionary {
                
                for (key, value) in myContacts{
                    
                    if let contactData = value as? NSDictionary {
                        
                        if let email = contactData[Constants.EMAIL] as? String {
                            
                            let id = key as! String;
                            let newContact = Contact(id: id, name: email);
                            
                            // append it to array
                            contacts.append(newContact);
                        }
                    }
                }
            }
            self.delegate?.dataReceived(contacts: contacts);
        }
    }
    
    
    

    
    
} // class








