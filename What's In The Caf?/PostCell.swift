//
//  PostCell.swift
//  WhatsInTheCaf
//
//  Created by Luke Patterson on 4/30/17.
//  Copyright © 2017 Luke Patterson. All rights reserved.
//

import Foundation
import UIKit

class PostCell : UITableViewCell {
    
    
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var likesTextView: UITextView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
}
