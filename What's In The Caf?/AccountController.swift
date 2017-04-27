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
        if let email = emailSignInField.text  {
            
            if let password = passwordSignInField.text {
                
                FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
                    
                    if let error = error {
                        self.presentAlert(title: "Error", message: error.localizedDescription, buttonTitle: "Okay", responder: nil, action: nil)
                    } else {
                        //sign in success
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
            
        }
        
    }
    
    @IBAction func signUpAction(_ sender: AnyObject) {
        
        if(validateEmail() && validatePassword()) {
            
            FIRAuth.auth()?.createUser(withEmail: emailSignUpField.text!, password: passwordSignUpField.text!) { (user, error) in
            
                if let error = error {
                    self.presentAlert(title: "Error", message: error.localizedDescription, buttonTitle: "Okay", responder: nil, action: nil)
                } else {
                    FIRAuth.auth()?.signIn(withEmail: self.emailSignUpField.text!, password: self.passwordSignUpField.text!) { (user, error) in
                        
                        if let error = error {
                            self.presentAlert(title: "Error", message: error.localizedDescription, buttonTitle: "Okay", responder: nil, action: nil)
                        } else {
                            //sign in success
                            //send email
                            if let newUser = user {
                                newUser.sendEmailVerification(completion: { (error) in
                                    if let error = error {
                                        print(error.localizedDescription)
                                    }
                                })
                                let changeRequest = newUser.profileChangeRequest()
                                let email:String = newUser.email!
                                let index = email.index(email.startIndex, offsetBy: email.characters.count-8)
                                changeRequest.displayName = email.substring(to: index)
                                
                                changeRequest.commitChanges(completion: { (error) in
                                    if error != nil {
                                        self.presentAlert(title: "Error", message: "Could not create a display name", buttonTitle: "Okay", responder: nil, action: nil)
                                    }
                                    
                                })
                            }
                            

                        }
                    }
                    let buttonAction = UIAlertAction(title: "Okay", style: .default, handler: { (action) in
                        self.dismiss(animated: true, completion: nil)
                    })
                    self.presentAlert(title: "Success", message: "Account successfully created. Please verify your email.", buttonTitle: "Okay", responder: nil, action: buttonAction)
                    
                }
            }
        }
    }
    
    func validateEmail() -> Bool{
        
        if(!(emailSignUpField.text?.contains("@jcu.edu"))!) {
            self.presentAlert(title: "Error", message: "Please register with a JCU affiliated email address (@jcu.edu)", buttonTitle: "Okay", responder: self.emailSignUpField, action: nil)
            emailSignUpField.text = "@jcu.edu"
        }
        return true
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
    
    func validatePassword() -> Bool {
        
        if let password = passwordSignUpField.text {
            if let confirm = confirmPasswordField.text {
                
                if(password==confirm) {
                    return true
                }
                
            }
        }
        return false
        
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
