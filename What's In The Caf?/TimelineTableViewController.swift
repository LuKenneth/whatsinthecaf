//
//  TimelineTableViewController.swift
//  What's In The Caf?
//
//  Created by Luke Patterson on 8/21/15.
//  Copyright (c) 2015 Luke Patterson. All rights reserved.
//

import UIKit

class TimelineTableViewController: UITableViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {

    
    var signUpViewController: PFSignUpViewController! = PFSignUpViewController()
    var logInViewController: PFLogInViewController! = PFLogInViewController()
    var isNew = 1
    let refreshController = UIRefreshControl()
    //negative = hot
    @IBOutlet weak var hotButton: UISegmentedControl!
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBAction func hotButton(sender: AnyObject) {
        hotButtonPressed()
    }
    func hotButtonPressed(){
        isNew = isNew * -1
        if navigationBar.title == "My Reviews"{
            if(PFUser.currentUser() != nil){
                self.timelineData.removeAllObjects()
                loadData()
            }
        }
        else{
            self.timelineData.removeAllObjects()
            loadData()
        }
        
    }
    
    var timelineData:NSMutableArray! = NSMutableArray()

    @IBOutlet weak var navigationBar: UINavigationItem!
    override init(style: UITableViewStyle) {
        super.init(style: style)
        // Custom initialization
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    
    func loadData(){
            print("loadData")
            let findTimelineData: PFQuery = PFQuery(className: "reviews")
            
            if navigationBar.title == "My Reviews"{
                if (PFUser.currentUser() != nil){
                findTimelineData.whereKey("reviewer", equalTo : PFUser.currentUser()!)
                if isNew == -1{
                    timelineData.removeAllObjects()
                    findTimelineData.orderByAscending("votes")}
                
                else{
                    timelineData.removeAllObjects()
                    findTimelineData.orderByAscending("createdAt")
                }
                }
                else{
                    //LogIn()
                }
            }
            
            else{
                
                if isNew == -1{
                    timelineData.removeAllObjects()
                    findTimelineData.orderByAscending("votes")
                }
                else{
                    timelineData.removeAllObjects()
                    findTimelineData.orderByAscending("createdAt")
                }
                
            }

            findTimelineData.findObjectsInBackgroundWithBlock{
                (objects:[AnyObject]?, error:NSError?)->Void in
                
                if error == nil{
                    
                    for object in objects!{
                        let review:PFObject = object as! PFObject
                        self.timelineData.addObject(review)
                    }
                    
                    let array:NSArray = self.timelineData.reverseObjectEnumerator().allObjects
                    self.timelineData = NSMutableArray(array: array)
                    
                    self.tableView.reloadData()
                }
                else{print("ERRORO@@@@@@@@@@@")}
                
            }
        if (PFUser.currentUser() == nil){
            if navigationBar.title == "My Reviews"{
                self.messageLabel.hidden = false
                self.messageLabel.text = "Sign in to see your reviews!"
            }
        }
        
    }

      override func viewDidAppear(animated: Bool) {
        print("viewDidAppear")
        self.loadData()
        if navigationBar.title == "My Reviews"{
            if(PFUser.currentUser() != nil){
                self.loadData()
                print("what")
            }
            else{
                self.timelineData.removeAllObjects()
            }
        }
        else{
            self.loadData()
        }
        
        isNew = 1
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        refreshController.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
        tableView.addSubview(refreshController)
        if navigationBar.title == "My Reviews"{
            if (PFUser.currentUser() != nil){
            }
            else{
                LogIn()
                messageLabel.hidden = false
                messageLabel.text = "Sign in to see your reviews!"
            }
        }
        
    }
    func refresh(sender:AnyObject)
    {
        if navigationBar.title == "My Reviews"{
            if(PFUser.currentUser() != nil){
                self.timelineData.removeAllObjects()
                loadData()
                self.refreshController.endRefreshing()
            }
        }
        else{
            self.timelineData.removeAllObjects()
            loadData()
            self.refreshController.endRefreshing()
        }
        self.refreshController.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // #pragma mark - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return timelineData.count
    }

    
   override func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell {
        let cell:reviewTableViewCell = tableView!.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath!) as! reviewTableViewCell
        //print(indexPath!.row)
    
    if indexPath!.row < self.timelineData.count{
        let review:PFObject = self.timelineData.objectAtIndex(indexPath!.row) as! PFObject
    
      
        if navigationBar.title == "My Reviews"{
            if(PFUser.currentUser() == nil){
                cell.hidden = true
            }
            else{
                cell.hidden = false
            }
            cell.DeleteButtonButton.hidden = false}
        cell.reviewTextView.alpha = 0
        cell.timestampLabel.alpha = 0
        cell.usernameLabel.alpha = 0
        cell.votes.alpha = 0
        
        cell.reviewTextView.text = review.objectForKey("content") as! String
        cell.votes.text = String(review.objectForKey("votes") as! Int)
        
        
        let dataFormatter:NSDateFormatter = NSDateFormatter()
        //dataFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dataFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dataFormatter.timeStyle = .ShortStyle
        cell.timestampLabel.text = dataFormatter.stringFromDate(review.createdAt!)
        
        let findreviewer:PFQuery = PFUser.query()!
        findreviewer.whereKey("objectId", equalTo: review.objectForKey("reviewer")!.objectId!!)
        
        findreviewer.findObjectsInBackgroundWithBlock{
            (objects:[AnyObject]?, error:NSError?)->Void in
            if error == nil{
                let user:PFUser = (objects! as NSArray).lastObject as! PFUser
                if review.objectForKey("hide") as! String == "true"{
                    cell.usernameLabel.text = "Anonymous"}
                else{
                    if user.username == "What's In The Caf?"{
                        let adminText = user.username
                        let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: (adminText as String?)!)
                        attributedText.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(20)], range: NSRange(location: 0, length: 18))
                        cell.usernameLabel.attributedText = attributedText
                    }
                    else{
                        cell.usernameLabel.text = user.username}}
                
                UIView.animateWithDuration(0.5, animations: {
                    cell.reviewTextView.alpha = 1
                    cell.timestampLabel.alpha = 1
                    cell.usernameLabel.alpha = 1
                    cell.votes.alpha = 1
                })
            }
        }
        
        
        
    
    }
    
    else{
        print("index out of bounds")
    }
  
    

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView?, canEditRowAtIndexPath indexPath: NSIndexPath?) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView?, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath?) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView?, moveRowAtIndexPath fromIndexPath: NSIndexPath?, toIndexPath: NSIndexPath?) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView?, canMoveRowAtIndexPath indexPath: NSIndexPath?) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
