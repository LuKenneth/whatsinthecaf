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
    
    
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var likesTextView: UITextView!
    @IBOutlet weak var voteUpButton: UIButton!
    @IBOutlet weak var voteDownButton: UIButton!
    var post:Post!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    @IBAction func voteUp(_ sender: Any) {
        let childUpdates = ["Likes":post.likes+1]
        self.post.ref?.updateChildValues(childUpdates)
        //self.post.ref?.setValue(["Likes":post.likes+1])
    }
    
    @IBAction func voteDown(_ sender: Any) {
        let childUpdates = ["Likes":post.likes-1]
        self.post.ref?.updateChildValues(childUpdates)
        //self.post.ref?.setValue(["Likes":post.likes-1])
    }
    
    
}
