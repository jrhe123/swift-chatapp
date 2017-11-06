//
//  ContactsVC.swift
//  ChatApp
//
//  Created by Jiarong He on 2017-11-05.
//  Copyright © 2017 Jiarong He. All rights reserved.
//

import UIKit

class ContactsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, FetchData {
    
    
    @IBOutlet weak var myTable: UITableView!
    
    
    
    // variables
    private let CELL_ID = "Cell";
    private let CHAT_SEGUE = "ChatSegue";
    // array of contacts
    private var contacts = [Contact]();
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Delegate
        DBProvider.Instance.delegate = self;
        // fetch
        DBProvider.Instance.getContacts();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    // logout
    @IBAction func logout(_ sender: Any) {
        
        if AuthProvider.Instance.logout() {
            
            dismiss(animated: true, completion: nil);
        }
    }
    
    
    // Delegate func(4): table
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contacts.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.CELL_ID, for: indexPath);
        cell.textLabel?.text = contacts[indexPath.row].name;
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: CHAT_SEGUE, sender: nil);
    }
    
    
    // Delegate: fetch data from firebase
    func dataReceived(contacts: [Contact]) {
        
        self.contacts = contacts;
        
        for contact in self.contacts{
            
            if contact.id == AuthProvider.Instance.userID(){
                
                AuthProvider.Instance.userName = contact.name;
            }
        }
        
        myTable.reloadData();
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

}
