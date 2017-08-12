//
//  MyAccountController.swift
//  WhatsInTheCaf
//
//  Created by Luke Patterson on 8/12/17.
//  Copyright © 2017 Luke Patterson. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class MyAccount : UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var signOutButton: UIButton!
    
    var ref: FIRDatabaseReference!
    public var tabVC: UITabBarController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        if let currentUser = FIRAuth.auth()?.currentUser {
         
            let displayName = currentUser.displayName!
            self.displayNameLabel.text = displayName
            
        }
    }
    
    @IBAction func close(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func signOut(_ sender: Any) {
        
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            tabVC.selectedIndex = 0
            self.dismiss(animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
    }
    
    
    @IBAction func resetPasswordButton(_ sender: Any) {
        self.resetPassword()
    }
    
    
    func resetPassword() {
        
        if let email = FIRAuth.auth()?.currentUser?.email {
            
            FIRAuth.auth()?.sendPasswordReset(withEmail: email) { (error) in
                if let error = error {
                    self.presentAlert(title: "Error", message: "Error: \(String(describing: error.localizedDescription))", buttonTitle: "Bummer", responder: nil, action: nil)
                }
                else {
                    self.presentAlert(title: "Success", message: "Check your email for instructions to reset your password", buttonTitle: "Okay", responder: nil, action: nil)
                }
            }
        }
    }
    
    
    func presentAlert(title: String, message: String, buttonTitle: String, responder: UITextField?, action: UIAlertAction?) {
        let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let buttonAction = action {
            alertController.addAction(buttonAction)
        }else {
            alertController.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: nil))
        }
        
        
        self.present(alertController, animated: true, completion: {
            if let responderField = responder  {
                responderField.becomeFirstResponder()
            }
            
        })
        
        
    }
    
    
}
