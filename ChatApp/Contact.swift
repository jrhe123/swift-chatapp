//
//  Contact.swift
//  ChatApp
//
//  Created by Jiarong He on 2017-11-05.
//  Copyright © 2017 Jiarong He. All rights reserved.
//

import Foundation


class Contact {
    
    private var _name = "";
    private var _id = "";
    
    
    init(id: String, name: String){
        _id = id;
        _name = name;
    }
    
    
    // getter / setter
    var name: String{
        get {
            return _name;
        }
    }
    
    var id: String{
        get {
            return _id;
        }
    }
    
    
}

