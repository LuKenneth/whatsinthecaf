//
//  PostCell.swift
//  WhatsInTheCaf
//
//  Created by Luke Patterson on 4/30/17.
//  Copyright © 2017 Luke Patterson. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class PostCell : UITableViewCell {
    
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var voteUpButton: UIButton!
    @IBOutlet weak var voteDownButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    var post:Post!
    var upEnabled:Bool = true
    var downEnabled:Bool = true
    var table:UITableView!
    var ref: FIRDatabaseReference!
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        voteDownButton.isEnabled = downEnabled
        voteUpButton.isEnabled = upEnabled
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    @IBAction func voteUp(_ sender: Any) {
        ref = FIRDatabase.database().reference()
        if let user = (FIRAuth.auth()?.currentUser!.displayName!) {
        
            ref.child("Users").child(user).child("Likes").observe(.value, with: { (snapshot) in
                if(!snapshot.hasChild(self.post.key)) {
                    let childUpdates = ["Likes":self.post.likes+1]
                    self.post.ref?.updateChildValues(childUpdates)
                    
                    self.ref.child("Users").child(user).child("Likes").child(self.post.key).setValue(1)
                    self.upEnabled = false
                    self.table.reloadData()
                    
                    CafCredHandler.sharedInstance.updateCafCred(score: 1, pUser: (FIRAuth.auth()?.currentUser!.displayName!)!)
                    CafCredHandler.sharedInstance.updateCafCred(score: 2, pUser: self.post.user)
                }
            })
            
        }
    }
    
    @IBAction func voteDown(_ sender: Any) {
        ref = FIRDatabase.database().reference()
        if let user = (FIRAuth.auth()?.currentUser!.displayName!) {
        
            ref.child("Users").child(user).child("Likes").observe(.value, with: { (snapshot) in
                if(!snapshot.hasChild(self.post.key)) {

                    let childUpdates = ["Likes":self.post.likes-1]
                    self.post.ref?.updateChildValues(childUpdates)
               
                    self.ref.child("Users").child(user).child("Likes").child(self.post.key).setValue(-1)
                    self.downEnabled = false
                    self.table.reloadData()
                    
                    CafCredHandler.sharedInstance.updateCafCred(score: -1, pUser: self.post.user)
                    if(self.post.likes <= -4) {
                        self.ref.child("Posts").child(self.post.key).removeValue()
                        CafCredHandler.sharedInstance.updateCafCred(score: -20, pUser: self.post.user)
                        self.table.reloadData()
                    }
                }
            })
            
        }
    }
    
    
}
