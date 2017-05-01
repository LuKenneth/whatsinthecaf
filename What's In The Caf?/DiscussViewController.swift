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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        composeText.delegate = self
        tableView.dataSource = self
        
        ref = FIRDatabase.database().reference()
        
        //signOut()
        
        let _ = FIRAuth.auth()?.addStateDidChangeListener() { (auth, user) in
            
            if FIRAuth.auth()?.currentUser != nil {
                if FIRAuth.auth()?.currentUser?.isEmailVerified == true {
                    self.continueWithLoad()
                }
                else {
                    self.presentAlert(title: "Verify Email", message: "Please verify your email to continue", buttonTitle: "Fine...", responder: nil)
                }
            } else {
                let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let accountVC:UIViewController = storyboard.instantiateViewController(withIdentifier: "account")
                self.present(accountVC, animated: true, completion: nil)
                
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let _ = FIRAuth.auth()?.addStateDidChangeListener() { (auth, user) in
            
            if FIRAuth.auth()?.currentUser != nil {
                if FIRAuth.auth()?.currentUser?.isEmailVerified == true {
                    //dont have to reload on viewDidAppear
                    self.continueWithLoad()
                }
                else {
                    self.presentAlert(title: "Verify Email", message: "Please verify your email to continue", buttonTitle: "Fine...", responder: nil)
                }
            } else {
                let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let accountVC:UIViewController = storyboard.instantiateViewController(withIdentifier: "account")
                self.present(accountVC, animated: true, completion: nil)
                
            }
        }

    }
    
    func continueWithLoad() {
        grabPosts{ (posts) in
            self.posts = posts
            for post in posts {
                print(post.message)
            }
            self.tableView.reloadData()
        }
        
        listenForPosts{ (posts) in
            self.posts = posts
            for post in posts {
                print(post.message)
            }
            self.tableView.reloadData()
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
        let idPath = self.ref.child("Posts").childByAutoId()
        idPath.child("Message").setValue(textField.text!)
        idPath.child("Likes").setValue(0)
        idPath.child("User").setValue((FIRAuth.auth()?.currentUser!.displayName!)!)
        return true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:PostCell = tableView.dequeueReusableCell(withIdentifier: "customcell", for: indexPath) as! PostCell
        cell.messageTextView.text = posts[indexPath.item].message
        cell.likesTextView.text = String(posts[indexPath.item].likes)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
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
    
    func listenForPosts(callback: @escaping ([Post])->()) {
        ref.child("Posts").observe(.childChanged, with: { (snapshot) in
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
    
}
