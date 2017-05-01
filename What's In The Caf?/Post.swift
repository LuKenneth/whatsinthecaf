//
//  Post.swift
//  WhatsInTheCaf
//
//  Created by Luke Patterson on 4/27/17.
//  Copyright © 2017 Luke Patterson. All rights reserved.
//

import Foundation
import Firebase

class Post {
    
    
    init(){
        self.likes = 0
        self.message = "Message"
        self.user = "User"
        self.key = ""
    }
    
    var likes: Int
    
    var message: String
    
    var user: String
    
    var ref: FIRDatabaseReference?
    var key: String
    
    init(pLikes:Int, pMessage:String, pUser:String){
        self.likes = pLikes
        self.message = pMessage
        self.user = pUser
        self.ref = nil
        self.key = ""
    }
    
    init(snapshot: FIRDataSnapshot) {
        
        key = snapshot.key
        if let data = snapshot.value as? NSDictionary {
            self.likes = data["Likes"] as! Int
            self.message = data["Message"] as! String
            self.user = data["User"] as! String
            
        } else {
            
            self.likes = 0
            self.message = ""
            self.user = ""

        }
        ref = snapshot.ref
    }
    
    func toAnyObject()->[String:AnyObject]{
        return ["Likes":self.likes as AnyObject,
                "Message":self.message as AnyObject,
                "User":self.user as AnyObject]
        
    }
    
    
    
    
    
    
}
