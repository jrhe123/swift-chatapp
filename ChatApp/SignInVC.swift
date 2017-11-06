//
//  SignInVC.swift
//  ChatApp
//
//  Created by Jiarong He on 2017-11-05.
//  Copyright © 2017 Jiarong He. All rights reserved.
//

import UIKit

class SignInVC: UIViewController {
    
    // Variables
    private let CONTACTS_SEGUE = "ContactsSegue";
    
    
    @IBOutlet weak var emailTextfield: UITextField!
    
    @IBOutlet weak var passwordTextfield: UITextField!
    

    // Life cycle method
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Check already logged in
        if AuthProvider.Instance.isLoggedIn() {
            performSegue(withIdentifier: self.CONTACTS_SEGUE, sender: nil);
        }
    }

    
    // login
    @IBAction func login(_ sender: Any) {
        
        if emailTextfield.text != "" && passwordTextfield.text != "" {
            
            AuthProvider.Instance.login(withEmail: emailTextfield.text!, password: passwordTextfield.text!, loginHandler: {

                (message) in
                
                if message != nil {
                    
                    self.alertTheUser(title: "Problem With Authentication", message: message!);
                }else{
                    
                    self.emailTextfield.text = "";
                    self.passwordTextfield.text = "";
                    
                    self.performSegue(withIdentifier: self.CONTACTS_SEGUE, sender: nil);
                }
            })

        }else{
            
            self.alertTheUser(title: "Email And Password Are Required", message: "Please enter and password in the text fields");
        }
    }
    
    
    // sign up
    @IBAction func signUp(_ sender: Any) {
        
        if emailTextfield.text != "" && passwordTextfield.text != "" {
            
            AuthProvider.Instance.signup(withEmail: emailTextfield.text!, password: passwordTextfield.text!, loginHandler: {
                
                (message) in
                
                if message != nil {
                    
                    self.alertTheUser(title: "Problem With Creating A New User", message: message!);
                }else{
                    
                    self.emailTextfield.text = "";
                    self.passwordTextfield.text = "";
                    
                    self.performSegue(withIdentifier: self.CONTACTS_SEGUE, sender: nil);
                }
            })
            
        }else{
            
            self.alertTheUser(title: "Email And Password Are Required", message: "Please enter and password in the text fields");
        }
    }
    
    
    // alert func
    private func alertTheUser(title: String, message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil);
        
        alert.addAction(ok);
        present(alert, animated: true, completion: nil);
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
