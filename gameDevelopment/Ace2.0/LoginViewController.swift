//
//  LoginViewController.swift
//  Ace2.0
//
//  Created by Weiliang Xing on 6/22/14.
//  Copyright (c) 2014 Weiliang Xing. All rights reserved.
//

import Foundation
import UIKit


//var loginView2: FBLoginView = FBLoginView()

class LoginViewController: UIViewController, FBLoginViewDelegate {
    
    //var fbl: FBLoginView = FBLoginView()
    
    @IBOutlet var loginView : FBLoginView
    @IBOutlet var profilePictureView : FBProfilePictureView
    @IBOutlet var userNameTxt : UILabel
    @IBOutlet var logStatusTxt : UILabel
    
    @IBOutlet var imageShow: UIImageView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //fbl.delegate = self
        //loginView.
        loginView.readPermissions = ["public_profile", "email", "user_friends"]
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginViewShowingLoggedInUser(loginView: FBLoginView) {
        //logStatusTxt.text = "You are logged in!"
        self.performSegueWithIdentifier("myidentifier", sender: self)
    }
    
    func loginViewFetchedUserInfo(loginView: FBLoginView?, user: FBGraphUser) {
        profilePictureView.profileID = user.objectID
        //userNameTxt.text = user.first_name + " " + user.last_name
        userNameTxt.text = user.objectForKey("email") as NSString
        
        var url: NSURL = NSURL.URLWithString("https://graph.facebook.com/\(user.objectID)/picture?type=normal")
        var data: NSData = NSData.dataWithContentsOfURL(url, options: nil, error: nil)
        imageShow.image = UIImage(data: data) as UIImage
    }
    
    func loginViewShowingLoggedOutUser(loginView: FBLoginView?) {
        profilePictureView.profileID = nil
        userNameTxt.text = ""
        logStatusTxt.text = "You are logged out!"
        
    }
    
    @IBAction func showLogin(segue: UIStoryboardSegue){
    
    }
}