//
//  DiscussViewController.swift
//  WhatsInTheCaf
//
//  Created by Luke Patterson on 1/13/17.
//  Copyright © 2017 Luke Patterson. All rights reserved.
//

import Foundation
import Firebase

class DiscussViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _ = FIRAuth.auth()?.addStateDidChangeListener() { (auth, user) in
            
            if FIRAuth.auth()?.currentUser != nil {
                self.continueWithLoad()
            } else {
                let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let accountVC:UIViewController = storyboard.instantiateViewController(withIdentifier: "account")
                self.present(accountVC, animated: true, completion: nil)
                
            }
        }
    }
    
    func continueWithLoad() {
        
        
    }
    
}
