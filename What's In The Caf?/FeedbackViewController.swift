//
//  FeedbackViewController.swift
//  WhatsInTheCaf
//
//  Created by Luke Patterson on 9/28/16.
//  Copyright © 2016 Luke Patterson. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

class FeedbackViewController: UIViewController {
    
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    let alert = UIAlertView()
    var names:[String] = []
    var emails:[String] = []
    var ref: FIRDatabaseReference!
    @IBOutlet weak var feedbackLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTextView.becomeFirstResponder()
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        ref = FIRDatabase.database().reference()
        
        self.ref.child("FeedbackMessage").observe(.value, with: { (snapshot) in
            self.feedbackLabel.text = snapshot.value as? String
        })
    }

    func dismissKeyboard() {
        
        self.view.endEditing(true)
    }
    
    func getEmails(_ completion: @escaping ([String],[String]) ->Void) {
        let ref = FIRDatabase.database().reference()
        var names:[String] = []
        var emails:[String] = []
        let _ = ref.child("emails").observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            
            for child in snapshot.children {
                names.append((child as AnyObject).key!!)
                emails.append((child as AnyObject).value!)
            }
            completion(names, emails)
        })
    }
    
    @IBAction func send(_ sender: AnyObject) {
        
        getEmails { (names, emails) in
            self.names = names
            self.emails = emails
        
        
        
        let smtpSession = MCOSMTPSession()
        smtpSession.hostname = "smtp.gmail.com"
        smtpSession.username = "whatsinthecaf@gmail.com"
        smtpSession.password = "witcnewpassword123"
        smtpSession.port = 465
        smtpSession.authType = MCOAuthType.saslPlain
        smtpSession.connectionType = MCOConnectionType.TLS
        smtpSession.connectionLogger = {(connectionID, type, data) in
            if data != nil {
                if let string = NSString(data: data!, encoding: String.Encoding.utf8.rawValue){
                    NSLog("Connectionlogger: \(string)")
                }
            }
        }
        
        let builder = MCOMessageBuilder()
        builder.header.bcc = [MCOAddress(displayName: "Luke", mailbox: "luke.k.patterson@gmail.com")]
        for index in 0...self.names.count-1 {
            builder.header.bcc.append(MCOAddress(displayName: names[index], mailbox: emails[index]))
        }
        print(builder.header.bcc, terminator: "")
    
        builder.header.from = MCOAddress(displayName: "JCU Student", mailbox: "whatsinthecaf@gmail.com")
        builder.header.subject = "JCU Dining: Feedback"
        builder.htmlBody = self.messageTextView.text
        
        let rfc822Data = builder.data()
        let sendOperation = smtpSession.sendOperation(with: rfc822Data)
        sendOperation?.start { (error) -> Void in
            if (error != nil) {
                NSLog("Error sending email: \(error)")
                self.alert.title = "Error"
                self.alert.message = "Something went wrong! Please notify me (Luke Patterson) to fix it!"
            } else {
                NSLog("Successfully sent email!")
                self.alert.title = "Thank you!"
                self.alert.message = "Thank you! Your feedback has been recorded!"
                self.messageTextView.text = ""
            }
            self.alert.addButton(withTitle: "Okay")
            self.alert.show()
        }
     }
    }
}
