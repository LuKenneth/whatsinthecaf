//
//  reviewTableViewCell.swift
//  What's In The Caf?
//
//  Created by Luke Patterson on 8/20/15.
//  Copyright (c) 2015 Luke Patterson. All rights reserved.
//

import UIKit

class reviewTableViewCell: UITableViewCell {
    @IBOutlet weak var downIcon: UIButton!
    @IBOutlet weak var upIcon: UIButton!
    
    @IBOutlet weak var DeleteButtonButton: UIButton!
    
    @IBAction func DeleteButton(sender: AnyObject) {
        
        let reviewQuery: PFQuery = PFQuery(className: "reviews")
        reviewQuery.whereKey("content", equalTo: self.reviewTextView.text)
        reviewQuery.findObjectsInBackgroundWithBlock{
            (objects:[AnyObject]?, error:NSError?)->Void in
            
            if error == nil{
                for object in objects!{
                    let review:PFObject = object as! PFObject
                    review.delete()
                    self.reviewTextView.text = "Review deleted. Refresh to see changes"
                }
            }
        }
        
    }
    
    var thisReview = ""
    let defaults = NSUserDefaults.standardUserDefaults()
    var votesArray = [String]()
    var upVotesString: String = ""
    var downVotesString: String = ""
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var votes: UILabel!
    @IBAction func upVote(sender: AnyObject) {
    
        let reviewQuery: PFQuery = PFQuery(className: "reviews")
        reviewQuery.whereKey("content", equalTo: reviewTextView.text)
        reviewQuery.findObjectsInBackgroundWithBlock{
            (objects:[AnyObject]?, error:NSError?)->Void in
            print("hi")
            if error == nil{
                
                for object in objects!{
                    let review:PFObject = object as! PFObject
                    if self.defaults.valueForKey("upVotesString") == nil {self.defaults.setValue(review.objectId, forKey: "upVotesString")}
                    else{
                    self.upVotesString = self.defaults.objectForKey("upVotesString")! as! String
                    if self.upVotesString.rangeOfString(review.objectId as String!) != nil {}
                    else{
                    self.upVotesString = self.upVotesString + review.objectId! + ","
                    self.defaults.setValue(self.upVotesString, forKey: "upVotesString")
                    print(self.defaults.valueForKey("upVotesString"))
                    self.defaults.synchronize()
                        print("hi")
                    self.upVote()}}
                    
                }
            }
        }
    }
    
    @IBOutlet weak var downVoteButton: UIButton!
    @IBAction func downVote(sender: AnyObject) {
        
        let reviewQuery: PFQuery = PFQuery(className: "reviews")
        reviewQuery.whereKey("content", equalTo: reviewTextView.text)
        reviewQuery.findObjectsInBackgroundWithBlock{
            (objects:[AnyObject]?, error:NSError?)->Void in
            
            if error == nil{
                
                for object in objects!{
                    let review:PFObject = object as! PFObject
                    if self.defaults.valueForKey("downVotesString") == nil {self.defaults.setValue(review.objectId, forKey: "downVotesString")}
                    else{
                        self.downVotesString = self.defaults.objectForKey("downVotesString")! as! String
                        if self.downVotesString.rangeOfString(review.objectId as String!) != nil {}
                        else{
                            self.downVotesString = self.downVotesString + review.objectId! + ","
                            self.defaults.setValue(self.downVotesString, forKey: "downVotesString")
                            print(self.defaults.valueForKey("downVotesString"))
                            self.defaults.synchronize()
                            self.downVote()}}
                    
                }
            }
        }
    }
    

    @IBOutlet var usernameLabel: UILabel! = UILabel()
    @IBOutlet var timestampLabel: UILabel! = UILabel()
    @IBOutlet var reviewTextView: UITextView! = UITextView()
    
    func upVote(){
        let reviewQuery: PFQuery = PFQuery(className: "reviews")
        reviewQuery.whereKey("content", equalTo: reviewTextView.text)
        reviewQuery.findObjectsInBackgroundWithBlock{
            (objects:[AnyObject]?, error:NSError?)->Void in
            
            if error == nil{
                
                for object in objects!{
                    let review:PFObject = object as! PFObject
                    review.incrementKey("votes", byAmount: 1)
                    review.saveInBackgroundWithBlock{
                        (succeeded: Bool, error: NSError?) -> Void in
                        if error == nil{
                            var intVotes: Int = Int(self.votes.text!)!
                            intVotes = intVotes + 1
                            self.votes.text = String(intVotes)
                        }
                        else{
                            
                        }
                        
                    }
                }
            }
        }
        
    }
    
    func downVote() {
        let reviewQuery: PFQuery = PFQuery(className: "reviews")
        reviewQuery.whereKey("content", equalTo: reviewTextView.text)
        reviewQuery.findObjectsInBackgroundWithBlock{
            (objects:[AnyObject]?, error:NSError?)->Void in
            
            if error == nil{
                
                for object in objects!{
                    let review:PFObject = object as! PFObject
                    review.incrementKey("votes", byAmount: -1)
                    if review.objectForKey("votes") as! Int! <= -5{
                        review.deleteInBackground()
                    }
                    else{}
                    review.saveInBackgroundWithBlock{(succeeded: Bool, error: NSError?) -> Void in
                        if error == nil{
                            var intVotes: Int = Int(self.votes.text!)!
                            intVotes = intVotes - 1
                            self.votes.text = "\(intVotes)"
                        }
                        else{
                            
                        }
                    }
                }
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Initialization code
        //self.downVoteButton.transform = CGAffineTransformMakeRotation((180.0 * CGFloat(M_PI)) / 180.0)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //self.downVoteButton.transform = CGAffineTransformMakeRotation((180.0 * CGFloat(M_PI)) / 180.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        self.downVoteButton.transform = CGAffineTransformMakeRotation((180.0 * CGFloat(M_PI)) / 180.0)
        if defaults.valueForKey("upVotesString") == nil || defaults.valueForKey("downVotesString") == nil{}
        else{
        upVotesString = defaults.valueForKey("upVotesString") as! String
            downVotesString = defaults.valueForKey("downVotesString") as! String}
        defaults.synchronize()
        
    }

}
