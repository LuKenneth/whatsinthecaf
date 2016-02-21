//
//  ComposeViewController.swift
//  What's In The Caf?
//
//  Created by Luke Patterson on 8/21/15.
//  Copyright (c) 2015 Luke Patterson. All rights reserved.
//

import UIKit


class ComposeViewController: UIViewController, UITextViewDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    var signUpViewController: PFSignUpViewController! = PFSignUpViewController()
    var logInViewController: PFLogInViewController! = PFLogInViewController()
    @IBOutlet weak var hideSwitch: UISwitch!
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet var charRemainingLabel: UILabel! = UILabel()
    var isReviewTooBig = false
    
    @IBOutlet weak var sendButton: UIBarButtonItem!
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if PFUser.currentUser() != nil{

        reviewTextView.layer.borderColor = UIColor.blackColor().CGColor
        reviewTextView.layer.borderWidth = 0.5
        reviewTextView.layer.cornerRadius = 5
        reviewTextView.delegate = self
        
        reviewTextView.becomeFirstResponder()
        // Do any additional setup after loading the view.
        }
        else{
            self.sendButton.enabled = false
            self.reviewTextView.text = "Sign in to post a review!"
            LogIn()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser() != nil{
            self.sendButton.enabled = true
            self.reviewTextView.text = ""
        }
        else{
            self.sendButton.enabled = false
            self.reviewTextView.text = "Sign in to post a review!"
        }
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

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendReview(sender: AnyObject) {
        
        if isReviewTooBig == false{
        let review:PFObject = PFObject(className: "reviews")
        review["content"] = reviewTextView.text
        review["reviewer"] = PFUser.currentUser()
        review["votes"] = 0
        
            if self.hideSwitch.on == true{
                review["hide"] = "true"
            }
            else{
                review["hide"] = "false"
            }
        
        review.saveInBackground()
        
        //self.navigationController!.popToRootViewControllerAnimated(true)
        let switchViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Reviews") as! TimelineTableViewController
        self.navigationController?.pushViewController(switchViewController, animated: true)
        }
        else{
            let tooLongAlert = UIAlertController(title: "Too Many Characters", message: "Please restrict your review to 140 characters.", preferredStyle: UIAlertControllerStyle.Alert)
            
            tooLongAlert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: { (action: UIAlertAction) in
                //do nothing
            }))
            
            presentViewController(tooLongAlert, animated: true, completion: nil)
        }
        reviewTextView.text = ""
    }

    
    func textViewDidChange(textView: UITextView){
        let newLength:Int = (textView.text as NSString).length
        let remainingChar:Int = 140 - newLength
        
        charRemainingLabel.text = "\(remainingChar)"
        if newLength > 140{
            isReviewTooBig = true
        }
        else if newLength <= 140{
            isReviewTooBig = false
        }
    }
    
    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
