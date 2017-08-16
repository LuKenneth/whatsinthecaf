//
//  CafCredController.swift
//  WhatsInTheCaf
//
//  Created by Luke Patterson on 8/13/17.
//  Copyright © 2017 Luke Patterson. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class CafCredController: UIViewController {
    
    @IBOutlet weak var cafCredLabel: UILabel!
    public var cc = "CC"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cafCredLabel.text = cc
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
