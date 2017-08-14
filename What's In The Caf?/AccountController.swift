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
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emailSignInField: UITextField!
    @IBOutlet weak var passwordSignInField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var emailSignUpField: UITextField!
    @IBOutlet weak var passwordSignUpField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    var emailString:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailSignUpField.addTarget(self, action: #selector(AccountController.validateEmail), for: UIControlEvents.editingDidEnd)
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    @IBAction func signInTapped(_ sender: AnyObject) {
        if let email = emailSignInField.text  {
            
            if let password = passwordSignInField.text {
                self.activityIndicator.startAnimating()
                
                FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
                    
                    if let error = error {
                        self.presentAlert(title: "Error", message: error.localizedDescription, buttonTitle: "Okay", responder: nil, action: nil)
                    } else {
                        //sign in success
                        self.dismiss(animated: true, completion: nil)
                    }
                    self.activityIndicator.stopAnimating()
                }
            }
            
        }
        
    }
    
    @IBAction func signUpAction(_ sender: AnyObject) {
        
        if(validateEmail() && validatePassword()) {
            
            self.activityIndicator.startAnimating()
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
                self.activityIndicator.stopAnimating()
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
    
    func dismissKeyboard() {
        
        self.view.endEditing(true)
    }
    
    @IBAction func cancel(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        
        if let email = emailSignInField.text {
            if email.contains("@jcu.edu") {
                self.activityIndicator.startAnimating()
                FIRAuth.auth()?.sendPasswordReset(withEmail: email) { (error) in
                    if let error = error {
                        self.presentAlert(title: "Error", message: "Error: \(String(describing: error.localizedDescription))", buttonTitle: "Bummer", responder: nil, action: nil)
                    }
                    else {
                        self.presentAlert(title: "Success", message: "Check your email for instructions to reset your password", buttonTitle: "Okay", responder: nil, action: nil)
                    }
                    self.activityIndicator.stopAnimating()
                }
            }
            else {
                self.presentAlert(title: "Email", message: "Please type your email address in the field above. An email will be sent to reset your password", buttonTitle: "Okay", responder: nil, action: nil)
            }
        }
        
    }
    
    
}
