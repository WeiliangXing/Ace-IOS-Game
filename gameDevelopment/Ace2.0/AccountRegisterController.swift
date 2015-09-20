//
//  AccountRegisterController.swift
//  Ace1.0
//
//  Created by Weiliang Xing on 6/16/14.
//  Copyright (c) 2014 Weiliang Xing. All rights reserved.
//

import Foundation
import UIKit
import CoreData

var globalFBMarker = false

class AccountRegisterController: UIViewController, UITextFieldDelegate, FBLoginViewDelegate {
    
    
    @IBOutlet var loginView: FBLoginView!
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var buttonSignIn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        username.tag = 1
        password.tag = 2
        password.secureTextEntry = true
        password.enabled = false
        
        loginView.readPermissions = ["public_profile", "email", "user_friends"]
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // used to wipe the keyboard when touch or press the button
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        self.view.endEditing(true)
    }
    
    
    @IBAction func signIn_pressed(){
        
        // extra operation related to the sign in button is here

    }
    
    //UITextField Delegate
    func textFieldShouldReturn(textField: UITextField!) -> Bool{
        
        
        // used to wipe the keyboard when finishing using it
        switch textField.tag{
        case 1,2:textField.resignFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField!){
        var appDel: AppDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        // get management infor from delegate
        var context: NSManagedObjectContext = appDel.managedObjectContext
        
        var requestUsername = NSFetchRequest(entityName: "Account")
        requestUsername.returnsObjectsAsFaults = false
        
        
        switch textField.tag{
        case 1:
            requestUsername.predicate = NSPredicate(format: "username = %@","" + textField.text)
            var results:NSArray! = context.executeFetchRequest(requestUsername, error: nil)
            if(results.count > 0){
                
                password.enabled = true
                
            }else{
                generateAlert("The username doesn't exist!")
                username.text = ""
                password.text = ""
                buttonSignIn.enabled = false
            }
        case 2:
            requestUsername.predicate = NSPredicate(format: "password = %@","" + textField.text)
            var results:NSArray! = context.executeFetchRequest(requestUsername, error: nil)
            
            if(results.count > 0){
                
                var res = results[0] as NSManagedObject
                var passwordInCore = res.valueForKey("password") as String
                
                if(passwordInCore == password.text){
                    
                    buttonSignIn.enabled = true
                    
                    // get the attributes into local struct
                    accountSingle.addTask(username: username.text, password: password.text, email: res.valueForKey("email") as String, checkUpdate: res.valueForKey("checkUpdate") as Bool, checkTerm: res.valueForKey("checkTerm") as Bool, profileInfo: accountSingle.info)
                    
                    //println(accountSingle.tasks[accountSingle.tasks.count-1].password)
                    //println(res.valueForKey("portrait"))
                }
            }else{
                generateAlert("The password is wrong!")
                password.text = ""
                buttonSignIn.enabled = false
            }
            
        default:
            println("nothing")
        }
    
    }
    

    
    func generateAlert(message:String){
        var alert: UIAlertController = UIAlertController(title: "Warning", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title:"close", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
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

        println("Object Saved.")
        
        accountSingle.addTask(username: FBusername, password: FBpassword, email: FBemail, checkUpdate: true, checkTerm: true, profileInfo: accountSingle.info)

        
        
    }
    
    
    // Facebook applications
    func loginViewShowingLoggedInUser(loginView: FBLoginView) {
        //logStatusTxt.text = "You are logged in!"
        globalFBMarker = true
        self.performSegueWithIdentifier("LoginIdentifier", sender: self)
    }
    

}