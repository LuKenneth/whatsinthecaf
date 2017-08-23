//
//  DiscussViewController.swift
//  WhatsInTheCaf
//
//  Created by Luke Patterson on 1/13/17.
//  Copyright © 2017 Luke Patterson. All rights reserved.
//

import Foundation
import Firebase

class DiscussViewController: UIViewController, UITableViewDelegate, UITextFieldDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var composeText: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    var ref: FIRDatabaseReference!
    var posts:[Post] = []
    var sortedPosts:[Post] = []
    var postsToLoad:[Post] = []
    var activeField: UITextField!
    @IBOutlet weak var sortSwitch: UISegmentedControl!
    @IBOutlet weak var cafCredLabel: UILabel!
    var user: String!
    var refreshControl: UIRefreshControl!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var keyboardOriginRect: CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        composeText.delegate = self
        tableView.dataSource = self
        
        ref = FIRDatabase.database().reference()
        registerForKeyboardNotifications()
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        let ccTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.showCafCredScreen))
        cafCredLabel.addGestureRecognizer(ccTap)
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.reloadTable), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
    }

    override func viewDidAppear(_ animated: Bool) {
        self.continueWithLoad()
        let _ = FIRAuth.auth()?.addStateDidChangeListener() { (auth, user) in
            
            if FIRAuth.auth()?.currentUser != nil {
                if FIRAuth.auth()?.currentUser?.isEmailVerified == true {
                    //dont have to reload on viewDidAppear
                    //self.continueWithLoad()
                }
                else {
                    self.showEmailAlert()
                }
            } else {
                self.showSignUpAlert()
                
            }
        }

    }
    
    func reloadTable() {
        
        grabPosts{ (posts) in
            self.posts = posts
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    func showLogIn() {
        
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let accountVC:UIViewController = storyboard.instantiateViewController(withIdentifier: "account")
        self.present(accountVC, animated: true, completion: nil)
        
    }
    
    func showEmailAlert() {
        
        let emailAlert = UIAlertController(title: "Verify Email", message: "Please verify your email to continue. It may take a few minutes. (are you really a jcu student?)", preferredStyle: .alert)
        let fineAction = UIAlertAction(title: "Fine...", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
            
            
            if FIRAuth.auth()?.currentUser != nil {
                if FIRAuth.auth()?.currentUser?.isEmailVerified == true {
                    
                }
                else {
                    self.dismiss(animated: true, completion: nil)
                    if let tabBarVC = self.tabBarController {
                        tabBarVC.selectedIndex = 0
                    }
                }
            }
            
        })
        let helpAlert = UIAlertController(title: "Something Wrong?", message: "If there's something wrong with your account, please send an email to lpatterson18@jcu.edu or luke.k.patterson@gmail.com", preferredStyle: .alert)
        let helpButton = UIAlertAction(title: "Okay", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
            if let tabBarVC = self.tabBarController {
                tabBarVC.selectedIndex = 0
            }
        }
        helpAlert.addAction(helpButton)
        
        let helpAction = UIAlertAction(title: "Help!", style: .default) { (action) in
            self.present(helpAlert, animated: true, completion: nil)
        }
        
        let signOutAction = UIAlertAction(title: "Sign out", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
            self.signOut()
            if let tabBarVC = self.tabBarController {
                tabBarVC.selectedIndex = 0
            }
        }
        
        let resendAction = UIAlertAction(title: "Resend email", style: .default) { (action) in
            if let newUser = FIRAuth.auth()?.currentUser {
                newUser.sendEmailVerification(completion: { (error) in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                })
            }
            self.dismiss(animated: true, completion: nil)
            if let tabBarVC = self.tabBarController {
                tabBarVC.selectedIndex = 0
            }
        }
        
        emailAlert.addAction(fineAction)
        emailAlert.addAction(resendAction)
        emailAlert.addAction(signOutAction)
        emailAlert.addAction(helpAction)
        self.present(emailAlert, animated: true, completion: nil)
        
    }
    
    func showSignUpAlert() {
        
        let alert = UIAlertController(title: "Sign In / Sign Up!", message: "Join the discussion by signing up or signing in!", preferredStyle: .alert)
        let joinAction = UIAlertAction(title: "Join", style: .default, handler: { (action) in
            self.showLogIn()
        })
        let maybeLaterAction = UIAlertAction(title: "Later", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
            if let tabBarVC = self.tabBarController {
                tabBarVC.selectedIndex = 0
            }
        })
        
        alert.addAction(joinAction)
        alert.addAction(maybeLaterAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func continueWithLoad() {
        if let currentUser = FIRAuth.auth()?.currentUser {
            self.user = currentUser.displayName!
            self.getCafCred()
            self.listenForPosts()
        }
        
        self.activityIndicator.startAnimating()
        grabPosts{ (posts) in
            self.posts = posts
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
        }
        
    }
    
    func signOut() {
        
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    func presentAlert(title: String, message: String, buttonTitle: String, responder: UITextField?) {
        let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: { (action) in
            
            let _ = FIRAuth.auth()?.addStateDidChangeListener() { (auth, user) in
                
                if FIRAuth.auth()?.currentUser != nil {
                    FIRAuth.auth()?.currentUser?.reload(completion: { (error) in
                        if let loadError = error {
                            self.presentAlert(title: "Error", message: loadError.localizedDescription, buttonTitle: "Okay", responder: nil)
                        }
                        else {
                            if FIRAuth.auth()?.currentUser?.isEmailVerified == false {
                                self.presentAlert(title: title, message: message, buttonTitle: buttonTitle, responder: responder)
                            }
                        }
                    })
                    
                }
            }
            
            
        }))
        
        self.present(alertController, animated: true, completion: {
            if let responderField = responder  {
                responderField.becomeFirstResponder()
            }
            
        })
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if((textField.text?.characters.count)! <= 140) {
            let idPath = self.ref.child("Posts").childByAutoId()
            idPath.child("Message").setValue(textField.text!)
            idPath.child("Likes").setValue(0)
            idPath.child("User").setValue((FIRAuth.auth()?.currentUser!.displayName!)!)
            idPath.child("Date").setValue(Int(Date().timeIntervalSince1970))
            
            let usersIDPath = self.ref.child("Users").child((FIRAuth.auth()?.currentUser!.displayName!)!)
            usersIDPath.child("Posts").childByAutoId().setValue(textField.text!)
            CafCredHandler.sharedInstance.updateCafCred(score: 10, pUser: (FIRAuth.auth()?.currentUser!.displayName!)!)
            
            textField.text = ""
        }
        else {
            self.presentAlert(title: "Message Too Long", message: "Please limit your post to 140 characters", buttonTitle: "Okay", responder: nil, action: nil)
        }
        
        dismissKeyboard()
        return true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(sortSwitch.selectedSegmentIndex == 0) {
            postsToLoad = posts
        }
        else {
            
            postsToLoad = sortedPosts
        }
        
        
        let cell:PostCell = tableView.dequeueReusableCell(withIdentifier: "customcell", for: indexPath) as! PostCell
        let index = postsToLoad.count - 1 - indexPath.item >= 0 ? postsToLoad.count - indexPath.item - 1 : 0
        cell.messageLabel.text = postsToLoad[index].message
 
        cell.messageLabel.sizeToFit()
        let smallFont = UIFont(name: cell.messageLabel.font.fontName, size: 12.0)
        let bigFont = UIFont(name: cell.messageLabel.font.fontName, size: 16.0)
        
        if let messageText = cell.messageLabel.text {
            if messageText.characters.count < 40 {
                cell.messageLabel.font = bigFont
            }
            else if messageText.characters.count > 80 {
                cell.messageLabel.font = smallFont
            }
        }
        cell.sizeToFit()
        
        cell.likesLabel.text = String(postsToLoad[index].likes)
        let date = postsToLoad[index].date
        let dateSinceNow = Int(Date().timeIntervalSince1970) - date
        let dateToDisplay = getRelativeDate(dateSinceNow: dateSinceNow)
        
        let tooOld = Int(dateSinceNow / (3600 * 24)) >= 7
        if tooOld {
            self.ref.child("Posts").child(postsToLoad[index].key).removeValue(completionBlock: { (error, ref) in
                if error != nil {
                    print(error as Any)
                }
            })
        }
        
        cell.timeLabel.text = dateToDisplay
        cell.post = postsToLoad[index]
        cell.table = self.tableView
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(sortSwitch.selectedSegmentIndex == 0) {
            postsToLoad = posts
        }
        else {
            
            postsToLoad = sortedPosts
        }
        
        let index = postsToLoad.count - 1 - indexPath.item >= 0 ? postsToLoad.count - indexPath.item - 1 : 0
        
        if postsToLoad[index].message != "" {
            if postsToLoad[index].message.characters.count > 90 {
                return 90
            }
        }
        return 70
    }
    
    func grabPosts(callback: @escaping ([Post])->()) {
        ref.child("Posts").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            self.posts.removeAll()
            for child in snapshot.children {
                if let data = child as? FIRDataSnapshot {
                    let newPost:Post = Post(snapshot: data)
                    self.posts.append(newPost)
                }
            }
            callback(self.posts)
            // ...
        }) { (error) in
            print(error.localizedDescription)
            
        }
        
        
    }
    
    func listenForPosts() {
        ref.child("Posts").observe(.childChanged, with: { (snapshot) in
            self.grabPosts{ (posts) in
                self.posts = posts
                self.tableView.reloadData()
            }
        }) { (error) in
            print(error.localizedDescription)
            
        }

    }
    
    func registerForKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideKeyboard), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showKeyboard), name: .UIKeyboardWillShow, object: nil)
    }
    
    func hideKeyboard(notification: NSNotification) {
        
        guard let info: NSDictionary = notification.userInfo as NSDictionary? else {
            return
        }
        
        let kbRectEnd: CGRect = info.object(forKey: UIKeyboardFrameEndUserInfoKey) as! CGRect
        if let tabBar = tabBarController?.tabBar {
            composeText.frame = CGRect(x: composeText.frame.origin.x, y: kbRectEnd.origin.y - composeText.frame.height - tabBar.frame.height, width: composeText.frame.width, height: composeText.frame.height)
        }
        
    }
    
    func showKeyboard(notification: NSNotification) {
        guard let info: NSDictionary = notification.userInfo as NSDictionary? else {
            return
        }
        
        let kbRectEnd: CGRect = info.object(forKey: UIKeyboardFrameEndUserInfoKey) as! CGRect
        composeText.frame = CGRect(x: composeText.frame.origin.x, y: kbRectEnd.origin.y - composeText.frame.height, width: composeText.frame.width, height: composeText.frame.height)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        
        return true
    }
    
    func dismissKeyboard() {
        
        self.view.endEditing(true)
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
    @IBAction func changeSort(_ sender: Any) {
        
        if(sortSwitch.selectedSegmentIndex == 1) {
            sortPosts()
        }
        self.tableView.reloadData()
    }
    
    func sortPosts() {
        sortedPosts = posts
        var tempPost:Post!
        var swapped = true
        
        if(sortedPosts.count >= 2) {
        
            while(swapped) {
            
                swapped = false
                for index in 0...sortedPosts.count-2 {
                    
                    if sortedPosts[index].likes > sortedPosts[index+1].likes {
                        
                        tempPost = sortedPosts[index]
                        sortedPosts[index] = sortedPosts[index+1]
                        sortedPosts[index+1] = tempPost
                        swapped = true
                        
                    }
                }
            }
        }
    }
    
    func getRelativeDate(dateSinceNow: Int) -> String {
        
        if(dateSinceNow < 60) {
            let dateInSeconds = Int(dateSinceNow)
            let grammar = dateInSeconds > 1 ? "seconds" : "second"
            return "\(dateInSeconds) \(grammar) ago"
        }
        else if(dateSinceNow >= 60 && dateSinceNow < (60*60)) {
            let dateInMinutes = Int(dateSinceNow / 60)
            let grammar = dateInMinutes > 1 ? "minutes" : "minute"
            return "\(dateInMinutes) \(grammar) ago"
        }
        else if(dateSinceNow >= 3600 && dateSinceNow < (3600 * 24)){
            let dateInHours = Int(dateSinceNow / 3600)
            let grammar = dateInHours > 1 ? "hours" : "hour"
            return "\(dateInHours) \(grammar) ago"
        }
        else {
            let dateInDays = Int(dateSinceNow / (3600 * 24))
            let grammar = dateInDays > 1 ? "days" : "day"
            return "\(dateInDays) \(grammar) ago"
        }
        
    }
    
    func getCafCred() {
        
        ref.child("Users").child(self.user).child("CafCred").observe(.value, with: { (snapshot) in
            
            if let cc = snapshot.value as? Int {
                self.cafCredLabel.text = String(cc)
            }
            
        })
        
    }
    
    func showCafCredScreen() {
        
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let ccVC:CafCredController = storyboard.instantiateViewController(withIdentifier: "cafCred") as! CafCredController
        ccVC.cc = self.cafCredLabel.text! + " CC"
        self.present(ccVC, animated: true, completion: nil)
    }
    
    @IBAction func accountButton(_ sender: Any) {
        
        if let _ = FIRAuth.auth()?.currentUser {
            let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let accountVC:MyAccount = storyboard.instantiateViewController(withIdentifier: "me") as! MyAccount
            if let tabBarVC = self.tabBarController {
                accountVC.tabVC = tabBarVC
                self.present(accountVC, animated: true, completion: nil)
            }
            
        }
        
    }
    
}
