//
//  Settings.swift
//  What's In The Caf?
//
//  Created by Luke Patterson on 8/23/15.
//  Copyright (c) 2015 Luke Patterson. All rights reserved.
//

import Foundation
import UIKit

class Settings : UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    
    
    @IBOutlet weak var logoutButton: UIButton!
    
    var signUpViewController: PFSignUpViewController! = PFSignUpViewController()
    var logInViewController: PFLogInViewController! = PFLogInViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(PFUser.currentUser() == nil){
            logoutButton.setTitle("Login", forState: UIControlState.Normal)
        }
        else{
            logoutButton.setTitle("Logout", forState: UIControlState.Normal)
        }
    }
    
    @IBAction func logoutButton(sender: AnyObject) {
        print(logoutButton.titleLabel?.text)
        if(logoutButton.titleLabel?.text == "Logout"){
            print("testing")
            PFUser.logOut()
            let logoutAlert = UIAlertController(title: "Logged Out", message: "You have logged out. You will need to log back in to post reviews.", preferredStyle: UIAlertControllerStyle.Alert)
        
            logoutAlert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: { (action: UIAlertAction) in
                //do nothing
            }))
        
            presentViewController(logoutAlert, animated: true, completion: nil)
            logoutButton.setTitle("Login", forState: UIControlState.Normal)
        }
        else{
            LogIn()
            logoutButton.setTitle("Logout", forState: UIControlState.Normal)
        }
    }
    
    
    @IBAction func aboutButton(sender: AnyObject) {
        let aboutMessage = UIAlertController(title: "About", message: "Created by Luke Patterson '18. For use within the John Carroll University community as a tool to engage the community and enhance the dining experience for all. Reach me at: luke.k.patterson@gmail.com", preferredStyle: UIAlertControllerStyle.Alert)
        
        aboutMessage.addAction(UIAlertAction(title: "Okay", style: .Default, handler: { (action: UIAlertAction) in
            //do nothing
        }))
        
        presentViewController(aboutMessage, animated: true, completion: nil)
    }
    
    
    func LogIn(){
        if (PFUser.currentUser() == nil){
            
            self.logInViewController.fields = [PFLogInFields.UsernameAndPassword, PFLogInFields.LogInButton, PFLogInFields.SignUpButton, PFLogInFields.PasswordForgotten, PFLogInFields.DismissButton]
            
            let logInLogoTitle = UILabel()
            logInLogoTitle.text = "What's In The Caf?"
            
            self.logInViewController.logInView!.logo = logInLogoTitle
            
            self.logInViewController.delegate = self
            
            let SignUpLogoTitle = UILabel()
            SignUpLogoTitle.text = "What's In The Caf?"
            
            self.signUpViewController.signUpView!.logo = SignUpLogoTitle
            
            self.signUpViewController.delegate = self
            
            self.logInViewController.signUpController = self.signUpViewController
            
            self.presentViewController(self.logInViewController, animated: true, completion: nil)
        }
        
        
    }
    
    func logInViewController(logInController: PFLogInViewController, shouldBeginLogInWithUsername username: String, password: String) -> Bool{
        if (!username.isEmpty || !password.isEmpty) {
            return true
        }else {
            return false
        }
        
    }
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser: PFUser){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError: NSError?){
        
        let invalidCredentials = UIAlertController(title: "Invalid Credentials", message: "Incorrect username or password.", preferredStyle: UIAlertControllerStyle.Alert)
        
        invalidCredentials.addAction(UIAlertAction(title: "Okay", style: .Default, handler: { (action: UIAlertAction) in
            //do nothing
        }))
        
        logInViewController.presentViewController(invalidCredentials, animated: true, completion: nil)
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser: PFUser){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didFailToSignUpWithError: NSError?){
        
    }
    
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController) {
        print("dismissed")
    }
    
}