//
//  AccountController.swift
//  WhatsInTheCaf
//
//  Created by Luke Patterson on 1/24/17.
//  Copyright © 2017 Luke Patterson. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class AccountController: UIViewController, UIAlertViewDelegate {
    
    @IBOutlet weak var emailSignInField: UITextField!
    @IBOutlet weak var passwordSignInField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var emailSignUpField: UITextField!
    @IBOutlet weak var passwordSignUpField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    var emailString:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        //emailSignInField.addTarget(self, action: #selector(AccountController.emailTextChanged), forControlEvents: UIControlEvents.EditingChanged)
        emailSignUpField.addTarget(self, action: #selector(AccountController.validateEmail), for: UIControlEvents.editingDidEnd)
        
    }
    
    @IBAction func signInTapped(_ sender: AnyObject) {
        
    }
    
    @IBAction func signUpAction(_ sender: AnyObject) {
    }
    
    func validateEmail() {
        
        if(!(emailSignUpField.text?.contains("@jcu.edu"))!) {
            let alertController: UIAlertController = UIAlertController(title: "Error", message: "Please register with a JCU affiliated email address (@jcu.edu)", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: { 
                self.emailSignUpField.becomeFirstResponder()
            })
            
        }
    }
    
    func emailTextChanged() {
        
        if(emailString.characters.count >= 8) {
            let index = emailString.characters.index(emailString.endIndex, offsetBy: -8)
            emailString = emailString.substring(to: index)
            print(emailString)
            emailSignInField.text = ""
            emailSignInField.text = emailString + "@jcu.edu"
        } else {
            emailString = emailSignInField.text! + "@jcu.edu"
            emailSignInField.text = emailString
        }
        
    }
    
}
