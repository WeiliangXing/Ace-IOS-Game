//
//  GuestViewController.swift
//  Ace2.0
//
//  Created by Weiliang Xing on 6/24/14.
//  Copyright (c) 2014 Weiliang Xing. All rights reserved.
//

//
//  MemberViewController.swift
//  Ace2.0
//
//  Created by Weiliang Xing on 6/24/14.
//  Copyright (c) 2014 Weiliang Xing. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class GuestViewController: UIViewController, FBLoginViewDelegate {
    
    @IBOutlet var loginView: FBLoginView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginView.readPermissions = ["public_profile", "email", "user_friends"]
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginViewFetchedUserInfo(loginView: FBLoginView?, user: FBGraphUser) {
        
        var FBemail = user.objectForKey("email") as NSString
        var FBusername = user.first_name + " " + user.last_name
        var FBpassword = "facebook"
        
        var url: NSURL = NSURL.URLWithString("https://graph.facebook.com/\(user.objectID)/picture?type=normal")
        var data: NSData = NSData.dataWithContentsOfURL(url, options: nil, error: nil)
        //imageShow.image = UIImage(data: data) as UIImage
        
        // reference to AppDelegate
        var appDel: AppDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        // get management infor from delegate
        var context: NSManagedObjectContext = appDel.managedObjectContext
        
        var newUser = NSEntityDescription.insertNewObjectForEntityForName("Account", inManagedObjectContext: context) as NSManagedObject
        newUser.setValue("" + FBusername, forKey:"username")
        newUser.setValue("" + FBpassword, forKey:"password")
        newUser.setValue("" + FBemail, forKey:"email")
        
        newUser.setValue(true, forKey:"checkTerm")
        newUser.setValue(true, forKey:"checkUpdate")
        
        
        newUser.setValue(String(accountSingle.info.rank), forKey: "rank")
        newUser.setValue(String(accountSingle.info.level), forKey: "level")
        newUser.setValue(String(accountSingle.info.win), forKey: "win")
        newUser.setValue(String(accountSingle.info.total), forKey: "total")
        newUser.setValue(String(accountSingle.info.money), forKey: "money")
        
        newUser.setValue(data, forKey: "portrait")
        context.save(nil)
        
        //        var newFBMarker = NSEntityDescription.insertNewObjectForEntityForName("Marker", inManagedObjectContext: context) as NSManagedObject
        //        newFBMarker.setValue(true, forKey: "isFBLogin")
        //
        //        context.save(nil)
        println("Object Saved.")
        
        accountSingle.addTask(username: FBusername, password: FBpassword, email: FBemail, checkUpdate: true, checkTerm: true, profileInfo: accountSingle.info)
        
        
        
    }

    
    func loginViewShowingLoggedInUser(loginView: FBLoginView?) {
        globalFBMarker = true
        self.performSegueWithIdentifier("MemberIdentifier", sender: self)
        
    }
    
    
}
